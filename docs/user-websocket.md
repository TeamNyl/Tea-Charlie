# User WebSocket

---

## WS `/user/position/ws` — Real-time Position Updates

Establishes a WebSocket connection for real-time user position tracking and updates.

### Connection Requirements

**Protocol:** WebSocket (ws:// or wss://)  
**Endpoint:** `/user/position/ws`

Example:
```
ws://api.tea-charlie.makabaka1880.xyz/user/position/ws
```

### Message Format

All messages must be sent as JSON text. Binary messages are not supported.

**Client Message Structure:**

| Field      | Type         | Required    | Description                             |
|------------|--------------|-------------|-----------------------------------------|
| `type`     | String       | Yes         | Message type: "auth" or "position"      |
| `token`    | String       | Conditional | Session token (required for "auth")     |
| `position` | Object       | Conditional | Position data (required for "position") |

**Position Object:**

| Field | Type  | Required | Description    |
|-------|-------|----------|----------------|
| `x`   | Float | Yes      | X coordinate   |
| `y`   | Float | Yes      | Y coordinate   |

### Authentication Message

Must be sent first to authenticate the WebSocket connection.

**Message:**
```json
{
    "type": "auth",
    "token": "CF156B92-B9E0-4CBF-9D62-2F1B806CFEFE"
}
```

### Success Response

**WebSocket Response:**
```json
{
    "success": true,
    "message": "Authenticated successfully",
    "position": null
}
```

### Error Responses

| Status       | Reason           | Description                    |
|--------------|------------------|--------------------------------|
| `Error`      | Missing Token    | Token field not provided       |
| `Error`      | Invalid Token    | Token is expired or invalid    |

**Example Error Response**
```json
{
    "success": false,
    "message": "Invalid token",
    "position": null
}
```

### Example WebSocket Authentication

**Client Message:**
```json
{
    "type": "auth",
    "token": "19A278A1-4E43-4B42-86E7-116CF0D5B609"
}
```

**Server Response:**
```json
{
    "success": true,
    "message": "Authenticated successfully",
    "position": null
}
```

---

## Position Update Message

Updates the user's position in real-time. Requires prior authentication.

### Request Message

| Field      | Type   | Required | Description                        |
|------------|--------|----------|------------------------------------|
| `type`     | String | Yes      | Must be "position"                 |
| `position` | Object | Yes      | Position coordinates (x, y)        |

Example:
```json
{
    "type": "position",
    "position": {
        "x": 10.5,
        "y": 20.3
    }
}
```

### Success Response

**WebSocket Response:**
```json
{
    "success": true,
    "message": "Position updated successfully",
    "position": {
        "x": 10.5,
        "y": 20.3
    }
}
```

### Error Responses

| Status       | Reason              | Description                         |
|--------------|---------------------|-------------------------------------|
| `Error`      | Authentication      | Not authenticated or invalid token  |
| `Error`      | Missing Position    | Position field not provided         |
| `Error`      | Database Error      | Failed to save position to database |

**Example Authentication Error**
```json
{
    "success": false,
    "message": "Token required",
    "position": null
}
```

**Example Database Error**
```json
{
    "success": false,
    "message": "Failed to update position",
    "position": null
}
```

### Example WebSocket Position Update

**Client Message:**
```json
{
    "type": "position",
    "position": {
        "x": 0,
        "y": 0
    }
}
```

**Server Response:**
```json
{
    "success": true,
    "message": "Position updated successfully",
    "position": {
        "x": 0,
        "y": 0
    }
}
```

---

## Common Error Messages

**Invalid Message Format:**
```json
{
    "success": false,
    "message": "Invalid message format",
    "position": null
}
```

**Unknown Message Type:**
```json
{
    "success": false,
    "message": "Unknown message type",
    "position": null
}
```

**Binary Not Supported:**
```json
{
    "success": false,
    "message": "Binary messages not supported",
    "position": null
}
```