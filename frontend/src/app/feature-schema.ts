export type Feature = {
  name: string;
  label: string;
  kind: 'number' | 'category';
  required: boolean;
  options?: string[];
  min?: number;
  max?: number;
};

// Generated from the trained model: 36 raw input fields, in model order.
export const FEATURES: Feature[] = [
  {"name": "Start_Lat", "label": "Start Lat", "kind": "number", "required": true, "min": 24.55, "max": 49.0},
  {"name": "Start_Lng", "label": "Start Lng", "kind": "number", "required": true, "min": -124.54, "max": -68.67},
  {"name": "State", "label": "State", "kind": "category", "required": true, "options": ["AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]},
  {"name": "Timezone", "label": "Timezone", "kind": "category", "required": true, "options": ["US/Central", "US/Eastern", "US/Mountain", "US/Pacific"]},
  {"name": "Temperature(F)", "label": "Temperature(F)", "kind": "number", "required": true, "min": -45.0, "max": 162.0},
  {"name": "Wind_Chill(F)", "label": "Wind Chill(F)", "kind": "number", "required": true, "min": -63.0, "max": 162.0},
  {"name": "Humidity(%)", "label": "Humidity(%)", "kind": "number", "required": true, "min": 1.0, "max": 100.0},
  {"name": "Pressure(in)", "label": "Pressure(in)", "kind": "number", "required": true, "min": 19.36, "max": 58.39},
  {"name": "Visibility(mi)", "label": "Visibility(mi)", "kind": "number", "required": true, "min": 0.0, "max": 80.0},
  {"name": "Wind_Direction", "label": "Wind Direction", "kind": "category", "required": true, "options": ["CALM", "E", "ENE", "ESE", "N", "NE", "NNE", "NNW", "NW", "S", "SE", "SSE", "SSW", "SW", "VAR", "W", "WNW", "WSW"]},
  {"name": "Wind_Speed(mph)", "label": "Wind Speed(mph)", "kind": "number", "required": true, "min": 0.0, "max": 185.0},
  {"name": "Precipitation(in)", "label": "Precipitation(in)", "kind": "number", "required": true, "min": 0.0, "max": 3.19},
  {"name": "Weather_Condition", "label": "Weather Condition", "kind": "category", "required": true, "options": ["Blowing Dust", "Blowing Dust / Windy", "Blowing Snow", "Blowing Snow / Windy", "Cloudy", "Cloudy / Windy", "Drifting Snow / Windy", "Drizzle", "Drizzle and Fog", "Fair", "Fair / Windy", "Fog", "Fog / Windy", "Freezing Drizzle", "Freezing Rain", "Freezing Rain / Windy", "Hail", "Haze", "Haze / Windy", "Heavy Drizzle", "Heavy Rain", "Heavy Rain / Windy", "Heavy Snow", "Heavy Snow / Windy", "Heavy T-Storm", "Heavy T-Storm / Windy", "Light Drizzle", "Light Drizzle / Windy", "Light Freezing Drizzle", "Light Freezing Rain", "Light Freezing Rain / Windy", "Light Rain", "Light Rain / Windy", "Light Rain Shower", "Light Rain with Thunder", "Light Sleet", "Light Sleet / Windy", "Light Snow", "Light Snow / Windy", "Light Snow Shower", "Light Snow Shower / Windy", "Light Snow and Sleet", "Light Snow and Sleet / Windy", "Light Snow with Thunder", "Mist", "Mostly Cloudy", "Mostly Cloudy / Windy", "N/A Precipitation", "Partly Cloudy", "Partly Cloudy / Windy", "Patches of Fog", "Rain", "Rain / Windy", "Rain Shower", "Shallow Fog", "Showers in the Vicinity", "Sleet", "Sleet / Windy", "Small Hail", "Smoke", "Smoke / Windy", "Snow", "Snow / Windy", "Snow and Sleet", "Snow and Sleet / Windy", "Snow and Thunder", "Squalls", "T-Storm", "T-Storm / Windy", "Thunder", "Thunder / Windy", "Thunder / Wintry Mix", "Thunder and Hail", "Thunder in the Vicinity", "Tornado", "Widespread Dust / Windy", "Wintry Mix", "Wintry Mix / Windy"]},
  {"name": "Amenity", "label": "Amenity (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Bump", "label": "Bump (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Crossing", "label": "Crossing (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Give_Way", "label": "Give Way (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Junction", "label": "Junction (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "No_Exit", "label": "No Exit (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Railway", "label": "Railway (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Roundabout", "label": "Roundabout (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Station", "label": "Station (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Stop", "label": "Stop (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Traffic_Calming", "label": "Traffic Calming (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Traffic_Signal", "label": "Traffic Signal (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Turning_Loop", "label": "Turning Loop (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Sunrise_Sunset", "label": "Sunrise Sunset", "kind": "category", "required": true, "options": ["Day", "Night"]},
  {"name": "Civil_Twilight", "label": "Civil Twilight", "kind": "category", "required": true, "options": ["Day", "Night"]},
  {"name": "Nautical_Twilight", "label": "Nautical Twilight", "kind": "category", "required": true, "options": ["Day", "Night"]},
  {"name": "Astronomical_Twilight", "label": "Astronomical Twilight", "kind": "category", "required": true, "options": ["Day", "Night"]},
  {"name": "Month", "label": "Month", "kind": "number", "required": true, "min": 1.0, "max": 12.0},
  {"name": "Hour", "label": "Hour", "kind": "number", "required": true, "min": 0.0, "max": 23.0},
  {"name": "DayOfWeek", "label": "DayOfWeek", "kind": "number", "required": true, "min": 0.0, "max": 6.0},
  {"name": "Is_Weekend", "label": "Is Weekend (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1},
  {"name": "Season", "label": "Season", "kind": "category", "required": true, "options": ["Fall", "Spring", "Summer", "Winter"]},
  {"name": "Is_Rush_Hour", "label": "Is Rush Hour (0 or 1)", "kind": "number", "required": true, "min": 0, "max": 1}
];
