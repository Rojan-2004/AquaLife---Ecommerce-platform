# Aqua Life eCommerce Unified Backend

This is the unified backend server for the Aqua Life eCommerce system. It is designed to serve both the **Web Application** and the **Flutter Mobile App** simultaneously using a single database, unified model definitions, and a consolidated authentication flow.

## Unified Features
1. **Single Database Connection:** Unifies the web database and the mobile database connection parameters.
2. **Dual-Client Authentication:** The authorization middleware checks:
   - HttpOnly cookies (`accessToken` and `token` and `refreshToken`) for browser clients.
   - `Authorization: Bearer <JWT_TOKEN>` headers for mobile clients.
3. **Data Field Reconciliation:** Automatically maps between `firstName`/`lastName` (Web) and `fullName`/`name` (Mobile) on registration.
4. **Token Refresh Rotation:** Implements `/refresh-token` endpoint supporting JWT token rotation for increased security.

## Setup Instructions

### 1. Install Dependencies
Navigate to the backend directory and install all consolidated dependencies:
```bash
cd aqua_life_backend
npm install
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env` and adjust the variables:
```bash
cp .env.example .env
```

Ensure your MongoDB instance is running locally at `mongodb://127.0.0.1:27017/` (or update `LOCAL_DATABASE_URI` in `.env` to point to your cloud/custom instance).

### 3. Seed Database
Seed default users (`demo@aqualife.com` and `admin@aqualife.com`) with the script:
```bash
npm run seed:import
```

To clear seeded users:
```bash
npm run seed:delete
```

### 4. Run the Server
* **Development Mode (with live reload):**
  ```bash
  npm run dev
  ```
* **Production Mode:**
  ```bash
  npm run start
  ```

---

## API Routes Reference

### Authentication (`/api/v1/auth`)
* `POST /register` — Public. Registers a new account.
  * Supports Web payloads (`firstName`, `lastName`, `email`, `username`, `password`)
  * Supports Mobile payloads (`fullName`, `name`, `email`, `username`, `password`, `phoneNumber`, `profilePicture`)
* `POST /login` — Public. Authenticates user and returns JWT access + refresh tokens, and sets HttpOnly cookies.
* `POST /refresh-token` — Public. Rotates and issues a new access token using a valid refresh token.
* `GET /me` or `GET /profile` — Private. Retrieves the current logged-in user profile.
* `POST /logout` — Private. Cleans user refresh token in DB and clears client cookies.

### Categories (`/api/v1/categories`)
* `GET /` — Public. Returns all active categories.
* `GET /:id` — Public. Returns a specific category.
* `POST /` — Private. Creates a new category.
* `PUT /:id` — Private. Updates a category.
* `DELETE /:id` — Private. Deletes a category.
