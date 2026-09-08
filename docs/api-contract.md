# AgroSense AI — Backend API Contract (v1)

This specification defines the REST API contract between the Django backend and the Flutter mobile client.

**Base URL**: `{API_BASE_URL}/api/v1`  
**Authentication Header**: `Authorization: Bearer <token>`  
**Data Format**: JSON (`Content-Type: application/json; charset=utf-8`)  
**Error Payload Shape**:
```json
{
  "detail": "Human-readable error description"
}
```

---

## 1. Allowed Enums

- **Health**: `good`, `watch`, `actNow`
- **Water**: `good`, `low`, `actNow`
- **Pest**: `good`, `watch`, `actNow`
- **Crop**: `rice`, `wheat`, `cotton`, `sugarcane`, `soybean`, `other`

---

## 2. Authentication

### `POST /auth/otp/request`
Requests an OTP code for phone login.

**Request**:
```json
{
  "phone": "+919876543210"
}
```

**Response** (`200 OK`):
```json
{
  "detail": "OTP sent successfully"
}
```

---

### `POST /auth/otp/verify`
Verifies OTP code and returns session token.

> **Development Note**: For local development and testing, verify accepts code `"1234"`.

**Request**:
```json
{
  "phone": "+919876543210",
  "code": "1234"
}
```

**Response** (`200 OK`):
```json
{
  "token": "sample-session-token-xyz",
  "profile_complete": false
}
```

---

## 3. Farmer Profile

### `GET /me`
Retrieves authenticated farmer's profile.

**Response** (`200 OK`):
```json
{
  "phone": "+919876543210",
  "name": "Ramesh",
  "village": "Baramati",
  "crop": "sugarcane"
}
```

---

### `PUT /me`
Updates farmer profile information.

**Request**:
```json
{
  "name": "Ramesh Patil",
  "village": "Baramati",
  "crop": "sugarcane"
}
```

**Response** (`200 OK`):
```json
{
  "name": "Ramesh Patil",
  "village": "Baramati",
  "crop": "sugarcane"
}
```

---

## 4. Fields & Telemetry

### `GET /fields`
Returns all registered fields for the farmer.

**Response** (`200 OK`):
```json
[
  {
    "id": "field_001",
    "name": "Main field",
    "crop": "wheat",
    "lat": 18.5204,
    "lng": 73.8567,
    "village": "Baramati",
    "health": "good"
  }
]
```

---

### `POST /fields`
Registers a new field.

**Request**:
```json
{
  "name": "River Corner",
  "crop": "wheat",
  "lat": 18.5204,
  "lng": 73.8567
}
```

**Response** (`201 Created`):
```json
{
  "id": "field_002",
  "name": "River Corner",
  "crop": "wheat",
  "lat": 18.5204,
  "lng": 73.8567,
  "village": "Baramati",
  "health": "good"
}
```

---

### `GET /fields/{id}`
Retrieves single field metadata.

**Response** (`200 OK`):
```json
{
  "id": "field_001",
  "name": "Main field",
  "crop": "wheat",
  "lat": 18.5204,
  "lng": 73.8567,
  "village": "Baramati",
  "health": "watch"
}
```

---

### `GET /fields/{id}/status`
Retrieves crop telemetry and satellite health status for a field.

**Response** (`200 OK`):
```json
{
  "health": "watch",
  "water": "low",
  "pest": "good",
  "overlay_hint": "right",
  "summary_key": "water_low"
}
```

---

## 5. Home Dashboard

### `GET /home`
Aggregated home screen snapshot.

**Response** (`200 OK`):
```json
{
  "temperature_c": 32,
  "rain_mm": 0,
  "wind_kmh": 12,
  "field_id": "field_001",
  "health": "good",
  "summary_key": "all_good",
  "alert_count": 1
}
```

---

## 6. Alerts

### `GET /alerts`
Active action items for farmer's fields (sorted worst-first: `actNow` before `watch`).

**Response** (`200 OK`):
```json
[
  {
    "id": "alert_001",
    "field_id": "field_001",
    "kind": "water",
    "severity": "actNow",
    "created_label": "Today",
    "seen": false
  }
]
```

---

### `GET /alerts/{id}`
Retrieves a single alert.

**Response** (`200 OK`):
```json
{
  "id": "alert_001",
  "field_id": "field_001",
  "kind": "water",
  "severity": "actNow",
  "created_label": "Today",
  "seen": false
}
```

---

### `POST /alerts/{id}/seen`
Marks an alert as acknowledged/seen.

**Response** (`200 OK`):
```json
{
  "id": "alert_001",
  "seen": true
}
```
