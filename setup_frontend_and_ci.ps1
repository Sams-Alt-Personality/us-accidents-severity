param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [switch]$Force
)
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

if (-not (Test-Path 'frontend\package.json')) { throw 'frontend not found. Run: ng new frontend --routing --style=css --skip-git --defaults' }
if (-not (Test-Path 'frontend\src\app\feature-schema.ts')) { throw 'Copy feature-schema.ts into frontend\src\app first.' }

Write-File 'backend/tests/test_structure.py' @'
from pathlib import Path


def test_source_files_exist():
    root = Path(__file__).resolve().parents[2]
    assert (root / "backend/app.py").exists()
    assert (root / "frontend/package.json").exists()
    assert (root / "README.md").exists()
'@

Write-File 'frontend/proxy.conf.json' @'
{
  "/api": {
    "target": "http://127.0.0.1:5000",
    "secure": false,
    "changeOrigin": true,
    "pathRewrite": { "^/api": "" }
  }
}
'@

Write-File 'frontend/src/app/prediction.service.ts' @'
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface PredictionResponse {
  prediction: string | number;
  task: string;
  probabilities?: number[];
  disclaimer?: string;
}

@Injectable({ providedIn: 'root' })
export class PredictionService {
  private http = inject(HttpClient);
  predict(payload: Record<string, string | number>): Observable<PredictionResponse> {
    return this.http.post<PredictionResponse>('/api/predict', payload);
  }
}
'@

Write-File -Overwrite 'frontend/src/app/app.ts' @'
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FEATURES, Feature } from './feature-schema';
import { PredictionService, PredictionResponse } from './prediction.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  readonly fields = FEATURES;
  readonly deployedStatic = !['localhost', '127.0.0.1']
    .includes(window.location.hostname);
  values: Record<string, string | number | null> = {};
  loading = false;
  error = '';
  result: PredictionResponse | null = null;
  private api = inject(PredictionService);

  constructor() {
    for (const field of this.fields) this.values[field.name] = null;
  }

  trackField(_index: number, field: Feature) { return field.name; }

  submit() {
    this.error = ''; this.result = null;
    if (this.deployedStatic) {
      this.error = 'Static GitHub Pages demo: start Angular + Flask locally for predictions.';
      return;
    }
    const payload: Record<string, string | number> = {};
    for (const field of this.fields) {
      const value = this.values[field.name];
      if (value === null || value === '') {
        this.error = `Enter a value for ${field.label}`; return;
      }
      if (field.kind === 'number') {
        const numeric = Number(value);
        if (!Number.isFinite(numeric)) {
          this.error = `Invalid number for ${field.label}`; return;
        }
        if ((field.min !== undefined && numeric < field.min) ||
            (field.max !== undefined && numeric > field.max)) {
          this.error = `Out-of-range value for ${field.label}`; return;
        }
        payload[field.name] = numeric;
      } else {
        payload[field.name] = String(value);
      }
    }
    this.loading = true;
    this.api.predict(payload).subscribe({
      next: result => { this.result = result; this.loading = false; },
      error: err => {
        this.error = `API error ${err.status || ''}: ` +
          (err.error?.error || err.message || 'Check Flask terminal');
        this.loading = false;
      },
    });
  }
}
'@

Write-File -Overwrite 'frontend/src/app/app.html' @'
<main class="shell">
  <header><h1>US Accident Severity Prediction</h1>
    <p>Teaching prototype - Random Forest on the US Accidents dataset</p></header>
  @if (deployedStatic) {
    <aside class="notice">Static GitHub Pages demonstration only.
      Predictions require Flask and Angular running locally.</aside>
  }
  <form (ngSubmit)="submit()">
    <h2>Model input features ({{fields.length}})</h2>
    <div class="grid">
      @for (field of fields; track field.name) {
        <label>{{field.label}}
          @if (field.kind === 'number') {
            <input type="number" step="any" [name]="field.name"
              [min]="field.min ?? null" [max]="field.max ?? null"
              [(ngModel)]="values[field.name]" [required]="field.required" />
          } @else {
            <select [name]="field.name" [(ngModel)]="values[field.name]"
              [required]="field.required">
              <option [ngValue]="null">Select a value</option>
              @for (option of field.options ?? []; track option) {
                <option [ngValue]="option">{{option}}</option>
              }
            </select>
          }
        </label>
      }
    </div>
    <button type="submit" [disabled]="loading || deployedStatic">
      {{loading ? 'Predicting...' : 'Run local prediction'}}
    </button>
  </form>
  @if (error) { <p class="error" role="alert">{{error}}</p> }
  @if (result) {
    <section class="result"><h2>Predicted severity</h2>
      <p><strong>{{result.prediction}}</strong></p>
      @if (result.probabilities) {
        <p>Class probabilities (Severity 1, 2, 3, 4): {{result.probabilities.join(', ')}}</p>
      }
      <p>{{result.disclaimer}}</p>
    </section>
  }
</main>
'@

Write-File -Overwrite 'frontend/src/app/app.css' @'
* { box-sizing: border-box; }
.shell { max-width: 960px; margin: 32px auto; padding: 24px;
  font-family: Arial, sans-serif; color: #19304a; }
header { border-bottom: 3px solid #2a6a9c; margin-bottom: 24px; }
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
  gap: 18px; margin: 20px 0; }
label { display: grid; gap: 7px; font-weight: 600; }
input, select { padding: 11px; border: 1px solid #a8b9c7; border-radius: 6px; }
button { background: #17659a; color: white; border: 0; border-radius: 7px;
  padding: 12px 20px; cursor: pointer; }
button:disabled { opacity: .55; cursor: not-allowed; }
.notice { background: #fff4d6; padding: 14px; border-radius: 6px; }
.error { color: #a01728; font-weight: bold; }
.result { margin-top: 24px; background: #edf6fc; padding: 18px; border-radius: 8px; }
'@

Write-File '.github/workflows/ci.yml' @'
name: Full-stack CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: pip
          cache-dependency-path: backend/requirements.txt
      - run: python -m pip install -r backend/requirements.txt
      - run: python -m pytest -q backend/tests/test_structure.py
      # Model-dependent tests (test_api.py) run locally only: the model file
      # is not tracked in Git, so the CI runner cannot load it.

  frontend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: frontend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
          cache: npm
          cache-dependency-path: frontend/package-lock.json
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: angular-build
          path: frontend/dist/
'@

$pages = @'
name: Deploy Angular to GitHub Pages
on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: github-pages
  cancel-in-progress: true

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
          cache: npm
          cache-dependency-path: frontend/package-lock.json
      - run: npm ci
        working-directory: frontend
      - run: npx ng build --configuration production --base-href /YOUR_REPO/
        working-directory: frontend
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: frontend/dist/frontend/browser
      - id: deployment
        uses: actions/deploy-pages@v4
'@
Write-File '.github/workflows/pages.yml' ($pages.Replace('YOUR_REPO', $Repo))

# Add provideHttpClient() to the generated app.config.ts (keeps its other providers)
$cfg = 'frontend\src\app\app.config.ts'
$t = [System.IO.File]::ReadAllText((Join-Path (Get-Location).Path $cfg))
if ($t -notmatch 'provideHttpClient') {
    $t = "import { provideHttpClient } from '@angular/common/http';`n" + $t
    $t = $t -replace 'providers:\s*\[', "providers: [`n    provideHttpClient(),"
    [System.IO.File]::WriteAllText((Join-Path (Get-Location).Path $cfg), $t, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "patched        $cfg"
} else { Write-Host "skip (already patched) $cfg" }

# .gitignore additions (appended once; negations re-include the small files we want tracked)
$gi = '.gitignore'
$marker = '# --- full-stack manual additions ---'
if (-not (Test-Path $gi) -or -not (Select-String -Path $gi -SimpleMatch $marker -Quiet)) {
    $block = @(
        '', $marker,
        '.venv/', '__pycache__/', '*.py[cod]', '.pytest_cache/', '.env', '.env.*',
        'frontend/node_modules/', 'frontend/dist/', 'frontend/.angular/',
        '.DS_Store', 'Thumbs.db', '*.log', '*.zip',
        '!data/sample_inputs.csv', '!docs/model_results_deployable.csv'
    )
    Add-Content -Path $gi -Value $block
    Write-Host "updated        .gitignore"
}

# Model size check (GitHub rejects files over 100 MB)
$m = 'backend\models\model_bundle.joblib'
if (Test-Path $m) {
    $mb = [math]::Round((Get-Item $m).Length / 1MB, 1)
    Write-Host "model_bundle.joblib = $mb MB"
    if ($mb -gt 95) {
        Add-Content -Path $gi -Value 'backend/models/'
        Write-Host 'Model is too big for GitHub: added backend/models/ to .gitignore (CI does not load the model anyway).'
    }
}

Write-Host ''
Write-Host 'Frontend + CI files ready.'