param([switch]$Force)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path 'backend')) { throw 'Run this from the project root (the folder that contains backend).' }

function Write-File([string]$Path, [string]$Content, [switch]$Overwrite) {
    $full = Join-Path (Get-Location).Path $Path
    if ((Test-Path $full) -and -not ($Overwrite -or $Force)) { Write-Host "skip (exists)  $Path"; return }
    New-Item -ItemType Directory -Force -Path (Split-Path $full) | Out-Null
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $text = (($Content -replace "`r`n", "`n") + "`n")
    [System.IO.File]::WriteAllText($full, $text, $utf8)
    Write-Host "created        $Path"
}

Write-File 'backend/requirements.txt' @'
flask
requests
pytest
scikit-learn==1.6.1
pandas==2.2.3
numpy==2.1.3
joblib==1.6.0
'@

Write-File 'backend/make_payload.py' @'
from pathlib import Path
import json
import joblib
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
bundle = joblib.load(ROOT / "backend/models/model_bundle.joblib")
features = bundle["features"]

df = pd.read_csv(ROOT / "data/sample_inputs.csv", nrows=1)
missing = [f for f in features if f not in df.columns]
if missing:
    raise ValueError(f"Sample CSV missing columns: {missing}")

row = df.loc[0, features]
payload = {}
for key, value in row.items():
    payload[key] = (None if pd.isna(value) else
                    value.item() if hasattr(value, "item") else value)

out = ROOT / "backend/test_payload.json"
out.write_text(json.dumps(payload, indent=2), encoding="utf-8")
print(f"Created {out} with {len(payload)} features")
'@

Write-File 'backend/test_pipeline.py' @'
from pathlib import Path
import json
import joblib
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
bundle = joblib.load(ROOT / "backend/models/model_bundle.joblib")
with (ROOT / "backend/test_payload.json").open(encoding="utf-8") as f:
    payload = json.load(f)

features = bundle["features"]
assert set(features) == set(payload), "Payload keys must match features"
frame = pd.DataFrame([[payload[f] for f in features]], columns=features)
model = bundle["pipeline"]
print("Prediction:", model.predict(frame).tolist())
if hasattr(model, "predict_proba"):
    print("Probabilities:", model.predict_proba(frame).tolist())
print("PASS: local inference")
'@

Write-File 'backend/app.py' @'
from pathlib import Path
import joblib
import pandas as pd
from flask import Flask, jsonify, request

BASE = Path(__file__).resolve().parent
BUNDLE = joblib.load(BASE / "models/model_bundle.joblib")
MODEL = BUNDLE["pipeline"]
FEATURES = BUNDLE["features"]
TASK = BUNDLE.get("task", "classification")

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify(status="ok", features=len(FEATURES), task=TASK)


@app.post("/predict")
def predict():
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify(error="Expected a JSON object"), 400
    missing = [f for f in FEATURES if f not in data]
    extra = [f for f in data if f not in FEATURES]
    if missing or extra:
        return jsonify(error="Input schema mismatch",
                       missing=missing, extra=extra), 400
    frame = pd.DataFrame([[data[f] for f in FEATURES]], columns=FEATURES)
    try:
        prediction = MODEL.predict(frame)[0]
        prediction = (prediction.item() if hasattr(prediction, "item")
                      else prediction)
        result = {"prediction": prediction, "task": TASK,
                  "disclaimer": "Research/teaching prototype only."}
        if TASK == "classification" and hasattr(MODEL, "predict_proba"):
            result["probabilities"] = MODEL.predict_proba(frame)[0].tolist()
        return jsonify(result)
    except (ValueError, TypeError) as exc:
        return jsonify(error="Invalid input", detail=str(exc)), 400
    except Exception:
        app.logger.exception("Prediction failed")
        return jsonify(error="Prediction processing failed"), 500


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=False)
'@

Write-File 'backend/test_api.py' @'
from pathlib import Path
import json
import requests

BASE = Path(__file__).resolve().parent
payload = json.loads((BASE / "test_payload.json").read_text(encoding="utf-8"))

with requests.Session() as session:
    session.trust_env = False  # avoids inherited proxy for localhost
    response = session.post("http://127.0.0.1:5000/predict",
                            json=payload, timeout=60)
    print("HTTP Status:", response.status_code)
    print("Response:", response.text)
    response.raise_for_status()
print("PASS: API request")
'@

Write-File 'backend/tests/test_api.py' @'
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "backend"))
from app import app, FEATURES

PAYLOAD = json.loads((ROOT / "backend/test_payload.json").read_text(encoding="utf-8"))


def test_health():
    response = app.test_client().get("/health")
    assert response.status_code == 200
    assert response.get_json()["features"] == len(FEATURES)


def test_predict_valid():
    response = app.test_client().post("/predict", json=PAYLOAD)
    assert response.status_code == 200, response.get_json()
    assert "prediction" in response.get_json()


def test_predict_missing_feature():
    incomplete = dict(PAYLOAD)
    incomplete.pop(FEATURES[0])
    response = app.test_client().post("/predict", json=incomplete)
    assert response.status_code == 400


def test_predict_invalid_json():
    response = app.test_client().post("/predict", data="not-json",
                                      content_type="application/json")
    assert response.status_code == 400
'@

Write-Host ''
Write-Host 'Backend files ready. Next: pip install -r backend\requirements.txt'