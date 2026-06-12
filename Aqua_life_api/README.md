# AquaLife Ecommerce API

Aquatic product ecommerce backend authentication API.

## Quick start

```bash
npm install
npm run dev
```

Environment variables are loaded from `config/config.env` and `.env`.

## Postman base URL

```txt
http://localhost:3000/api/v1
```

## Authentication endpoints

### Register

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "fullName": "Kiran Rana",
  "email": "kiran@example.com",
  "username": "kiranr",
  "password": "password123",
  "phoneNumber": "+9779801234567"
}
```

Response includes a JWT token:

```json
{
  "success": true,
  "token": "jwt-token",
  "data": {
    "id": "user-id",
    "fullName": "Kiran Rana",
    "email": "kiran@example.com",
    "username": "kiranr",
    "role": "user"
  }
}
```

### Login

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "kiran@example.com",
  "password": "password123"
}
```

### Protected request header

```http
Authorization: Bearer <jwt-token>
```

## Demo users

```bash
node seed-data.js -i
```

Demo credentials use password `password123`:

- `demo@aqualife.com`
- `admin@aqualife.com`
