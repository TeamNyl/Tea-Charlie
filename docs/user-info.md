# User Info Retrieval

---

## GET `/user/position` — Get User Position

Retrieves user position.

### Request Header
| Field       | Type     | Required | Description         |
|-------------|----------|----------|---------------------|
| `Authorize` | `Bearer` | Yes      | Login session token |

Example:
```http
Authorize: Bearer 01234567-ABCD-EF12-3456-7890ABCDEF12
```

### Success Response

**Status Code:** `200 OK`
Returns the Cartesian coordinate of the user

```json
{
    "x": 0,
	"y": 0
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
GET /user/position HTTP/1.1
host: api.tea-charlie.makabaka1880.xyz
user-agent: curl/8.2.1
accept: */*
x-api-key: Bearer 19A278A1-4E43-4B42-86E7-116CF0D5B609
```

**Response**

```http
HTTP/1.1 201 OK
Content-Type: application/json

{
    "x": 0,
	"y": 0
}
```

---

## GET `/user/coins` — Get User Coins

Retrieves user coin count.

### Request Header
| Field       | Type     | Required | Description         |
|-------------|----------|----------|---------------------|
| `Authorize` | `Bearer` | Yes      | Login session token |

Example:
```http
Authorize: Bearer 01234567-ABCD-EF12-3456-7890ABCDEF12
```

### Success Response

**Status Code:** `200 OK`
Returns the user’s current coin count

```json
{
    "coins": 400
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
GET /user/coins HTTP/1.1
host: api.tea-charlie.makabaka1880.xyz
user-agent: curl/8.2.1
accept: */*
x-api-key: Bearer 19A278A1-4E43-4B42-86E7-116CF0D5B609
```

**Response**

```http
HTTP/1.1 201 OK
Content-Type: application/json

{
    "coins": 400
}
```