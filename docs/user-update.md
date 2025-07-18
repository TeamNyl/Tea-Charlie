# User Info Updating

---

## PUT `/user/move` — Update User Position

Updates user’s position backup

### Request Header
| Field       | Type     | Required | Description         |
|-------------|----------|----------|---------------------|
| `Authorize` | `Bearer` | Yes      | Login session token |

Example:
```http
Authorize: Bearer 01234567-ABCD-EF12-3456-7890ABCDEF12
```

### Request Body

| Field | Type  | Required | Description                       |
|-------|-------|----------|-----------------------------------|
| `x`   | Float | Yes      | The user's x coord after updating |
| `y`   | Float | Yes      | The user’s y coord after updating |

Example:
```json
{
    "x": 5,
	"y": 5
}
```

### Success Response

**Status Code:** `200 OK`
Returns the updated coordinate.

```json
{
    "x": x-coord,
	"y": y-coord
}
```

### Error Responses

| Status Code | Reason       | Description                    |
|-------------|--------------|--------------------------------|
| `401`       | Unauthorized | Session key not provided       |
| `403`       | Forbidden    | Invalid or expired session key |

**Example 401 Response**

```json
{
    "error": true,
    "reason": "Session key not provided"
}
```

**Example 403 Response**

```json
{
    "error": true,
    "reason": "Invalid Session key"
}
```

### Example HTTP Request and Response

**Request**

```http
PUT /user/move HTTP/1.1
Host: api.tea-charlie.makabaka1880.xyz
User-Agent: curl/8.2.1
Accept: */*
Authorization: Bearer D16A519F-E52A-4767-A006-EE91DC15D8EB
Content-Type: application/json
Content-Length: 26

{
    "x": 0,
    "y": 0
}
```

**Response**

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
    "x": 0,
	"y": 0
}
```

---

## PUT `/user/coins` — Update User Coins

Updates a user’s coin count

### Request Header
| Field       | Type     | Required | Description         |
|-------------|----------|----------|---------------------|
| `Authorize` | `Bearer` | Yes      | Login session token |

Example:
```http
Authorize: Bearer 01234567-ABCD-EF12-3456-7890ABCDEF12
```

### Request Body

| Field   | Type | Required | Description                          |
|---------|------|----------|--------------------------------------|
| `coins` | Int  | Yes      | The user's coin count after updating |

Example:
```json
{
    "coins": 500
}
```

### Success Response

**Status Code:** `200 OK`
Returns the updated coin count.

```json
{
    "coins": 500
}
```

### Error Responses

| Status Code | Reason       | Description                    |
|-------------|--------------|--------------------------------|
| `401`       | Unauthorized | Session key not provided       |
| `403`       | Forbidden    | Invalid or expired session key |

**Example 401 Response**

```json
{
    "error": true,
    "reason": "Session key not provided"
}
```

**Example 403 Response**

```json
{
    "error": true,
    "reason": "Invalid Session key"
}
```

### Example HTTP Request and Response

**Request**

```http
PUT /user/coins HTTP/1.1
Host: api.tea-charlie.makabaka1880.xyz
User-Agent: curl/8.2.1
Accept: */*
Authorization: Bearer C6E3FED7-D74B-46BB-B227-2F719D130A37
Content-Type: application/json
Content-Length: 20

{
    "coins": 500
}
```

**Response**

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
    "coins": 500
}
```
