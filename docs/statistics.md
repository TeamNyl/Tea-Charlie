# Statistics API

---

## GET `/stats/users` — Get User and Session Statistics

Retrieves application statistics including total user count and active session count.

### Request

**Method:** `GET`  
**Endpoint:** `/stats/users`  
**Authentication:** Not required

*No request body or headers required.*

### Success Response

**Status Code:** `200 OK`  
Returns statistics about users and active sessions.

```json
{
    "user": 15,
    "tokens": 8
}
```

**Response Fields:**

| Field    | Type    | Description                                                    |
|----------|---------|----------------------------------------------------------------|
| `user`   | Integer | Total number of registered users in the system                |
| `tokens` | Integer | Number of active login sessions (tokens) created within the TTL period |

**Note:** Active tokens are counted based on the `LOGIN_TOKEN_TTL` environment variable (default: 7 days). Only tokens created within this time window are considered active.

### Error Responses

| Status Code | Reason            | Description                        |
|-------------|-------------------|------------------------------------|
| `500`       | Internal Error    | Database connection or query error |

**Example 500 Response**

```json
{
    "error": true,
    "reason": "Internal server error"
}
```

### Example HTTP Request and Response

**Request**

```http
GET /stats/users HTTP/1.1
Host: api.tea-charlie.makabaka1880.xyz
User-Agent: curl/8.2.1
Accept: application/json
```

**Response**

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
    "user": 15,
    "tokens": 8
}
```

---

## Implementation Details

### Active Session Calculation

The statistics endpoint calculates active sessions by:

1. Getting the current time
2. Subtracting the TTL period (from `LOGIN_TOKEN_TTL` environment variable)
3. Counting all tokens with `createdAt` timestamp greater than the calculated threshold

```swift
let ttlTime = Double(SecretsManager.get(.loginTokenTTL)!)!
let ttl = Date().addingTimeInterval(-ttlTime * 24 * 60 * 60)
let tokenCount = try await Token.query(on: req.db)
    .filter(\.$createdAt > ttl)
    .count()
```

### Use Cases

- **Monitoring**: Track application usage and growth
- **Analytics**: Understand user engagement patterns
- **Capacity Planning**: Monitor active session load
- **Health Checks**: Basic application metrics for monitoring systems