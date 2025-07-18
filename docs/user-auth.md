# User Authentication

---

## POST `/auth/register` — User Registration

Registers a new user with an email, password, and display username.

> **Username Format**
> `^[^@]{1,64}$`

### Request Body

| Field      | Type   | Required | Description                                   |
|------------|--------|----------|-----------------------------------------------|
| `email`    | String | Yes      | The user's email address                      |
| `password` | String | Yes      | Plain-text password (should be 6+ characters) |
| `username` | String | Yes      | Display name shown in the app                 |

Example:

```json
{
    "email": "user@example.com",
    "password": "yourPassword123",
    "username": "CoolTeaMaster"
}
```

### Success Response

**Status Code:** `201 Created`
Returns the ID of the newly created user.

```json
{
    "id": "UUID of the new user"
}
```

### Error Responses

| Status Code | Reason      | Description                                |
| ----------- | ----------- | ------------------------------------------ |
| `400`       | Bad Request | Malformed or missing fields in the request |
| `409`       | Conflict    | A user with the same email already exists  |

**Example 400 Response**

```json
{
    "error": true,
    "reason": "Missing email or password"
}
```

**Example 409 Response**

```json
{
    "error": true,
    "reason": "User already exists"
}
```

### Example HTTP Request and Response

**Request**

```http
POST /auth/register HTTP/1.1
Host: api.tea-charlie.makabaka1880.xyz
Content-Type: application/json
Accept: application/json

{
    "email": "evereen2023@gmail.com",
    "password": "Evereen2023",
    "username": "Admin (ABloom)"
}
```

**Response**

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
    "id": "19A278A1-4E43-4B42-86E7-116CF0D5B609"
}
```

---

## POST `/auth/login` — User Login

Authenticates a user and returns a login session token.
Supports login via **email**, **username**, or **user UUID**.

### Request Body

| Field        | Type   | Required | Description                                                |
| ------------ | ------ | -------- | ---------------------------------------------------------- |
| `identifier` | String | Yes      | User identifier: email, username, or user ID (UUID string) |
| `password`   | String | Yes      | Plain-text password for verification                       |

**Example:**

```json
{
    "identifier": "makabaka1880@outlook.com",
    "password": "s08lineflow"
}
```

---

### Success Response

**Status Code:** `200 OK`
Returns the login session token.

**Note:** A user can have **up to 3 active login sessions** at a time.

```json
{
    "id": "UUID for the login session"
}
```

---

### Error Responses

| Status Code | Reason            | Description                                                              |
| ----------- | ----------------- | ------------------------------------------------------------------------ |
| `400`       | Bad Request       | Malformed or missing fields in the request body                          |
| `403`       | Forbidden         | Failed to authenticate: incorrect credentials or user not found          |
| `429`       | Too Many Requests | User already has the maximum number of active login sessions (default 3) |

**Example 400 Response**

```json
{
    "error": true,
    "reason": "Malformed request body"
}
```

**Example 403 Response**

```json
{
    "error": true,
    "reason": "Invalid credentials"
}
```

**Example 429 Response**

```json
{
    "error": true,
    "reason": "Maximum number of logged-in devices reached."
}
```

---

### Example HTTP Request and Response

**Request**

```http
POST /auth/login HTTP/1.1
Host: api.tea-charlie.makabaka1880.xyz
User-Agent: curl/8.2.1
Accept: */*
Content-Type: application/json

{
    "identifier": "makabaka1880@outlook.com",
    "password": "s08lineflow"
}
```

**Response**

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
    "id": "CF156B92-B9E0-4CBF-9D62-2F1B806CFEFE"
}
```

---

## POST `/auth/logout` — User Logout

Revokes a login session token.

### Request Body

| Field | Type   | Required | Description    |
|-------|--------|----------|----------------|
| `id`  | String | Yes      | The session id |

Example:

```json
{
	"id": "01234567-ABCD-EF12-3456-7890ABCDEF12"
}
```

### Success Response

**Status Code:** `204 No Content`  
Indicates successful logout. No body is returned.

### Error Responses

| Status Code | Reason      | Description                                        |
|-------------|-------------|----------------------------------------------------|
| `400`       | Bad Request | Malformed or missing fields in the request         |
| `404`       | Not Found   | Session corresponding to the provided id not found |

**Example 400 Response**
```json
{
	"error": true,
	"reason": "Malformed request body"
}
```
```json
{
	"error": true,
	"reason": "Missing logout session key"
}
```

**Example 404 Response**
```json
{
    "error": true,
    "reason": "Session not found."
}
```

### Example HTTP Request and Response

**Request**

```http
POST /auth/logout HTTP/1.1
Host: api.tea-charlie.makabaka1880.xyz
User-Agent: curl/8.2.1
Accept: */*
Content-Type: application/json
Content-Length: 52

{
    "id": "19A278A1-4E43-4B42-86E7-116CF0D5B609"
}
```

**Response**

```http
HTTP/1.1 204 No Content
Content-Type: application/json
```

