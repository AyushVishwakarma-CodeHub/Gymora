# 🏋️ Gymora Backend API Documentation

**Base URL:** `https://gymora-backend-yk6z.onrender.com/api`

> ⚠️ **Note:** First request may take ~30 seconds (free tier cold start). All subsequent requests are fast.

---

## 🔐 Authentication

All endpoints (except Auth) require this header:
```
Authorization: Bearer <accessToken>
```

### POST `/auth/register`
Register a new user.
```json
{
  "fullName": "Ayush Gym",
  "email": "gym@gmail.com",
  "password": "123456",
  "phone": "1234567890",
  "role": "GYM_ADMIN",
  "address": "LPU Campus"
}
```
**Roles:** `MEMBER`, `TRAINER`, `GYM_ADMIN`, `SUPER_ADMIN`

**Response (201):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "user": {
      "id": 1,
      "email": "gym@gmail.com",
      "fullName": "Ayush Gym",
      "role": "GYM_ADMIN"
    }
  }
}
```

---

### POST `/auth/login`
Login with email and password.
```json
{
  "email": "gym@gmail.com",
  "password": "123456"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "user": {
      "id": 1,
      "email": "gym@gmail.com",
      "fullName": "Ayush Gym",
      "role": "GYM_ADMIN"
    }
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

---

### POST `/auth/refresh`
Refresh an expired access token.
```json
{
  "refreshToken": "eyJhbGci..."
}
```

---

### GET `/auth/me`
Get current logged-in user info. Requires `Authorization` header.

---

## 🏢 Gyms

### GET `/gyms`
List all gyms.

### GET `/gyms/active`
List all approved/active gyms.

### GET `/gyms/{id}`
Get gym by ID.

### GET `/gyms/admin/{adminId}`
Get gym owned by a specific admin user.

### GET `/gyms/pending`
List all pending gym applications. *(SUPER_ADMIN only)*

### PATCH `/gyms/{id}/status`
Approve or reject a gym. *(SUPER_ADMIN only)*
```json
{
  "status": "APPROVED"
}
```
**Statuses:** `PENDING`, `APPROVED`, `REJECTED`

---

## 👥 Users

### GET `/users`
List all users.

### GET `/users/{id}`
Get user by ID.

### GET `/users/role/{role}`
Get users by role (e.g., `/users/role/GYM_ADMIN`).

### PUT `/users/{id}`
Update user profile.

### PATCH `/users/{id}/fcm-token`
Update FCM push notification token.

### DELETE `/users/{id}`
Delete a user.

---

## 🏋️ Gym Owner

### POST `/gym-owner/{gymId}/members`
Add a member to the gym.

### POST `/gym-owner/{gymId}/trainers`
Add a trainer to the gym.

### PATCH `/gym-owner/trainers/{trainerId}/approve`
Approve a trainer application.

---

## 💪 Trainers

### POST `/trainers`
Register a new trainer.

### GET `/trainers/{id}`
Get trainer by ID.

### GET `/trainers/user/{userId}`
Get trainer profile by user ID.

### GET `/trainers/gym/{gymId}`
List all trainers in a gym.

### PUT `/trainers/{id}`
Update trainer profile.

---

## 🧑 Customers (Members)

### POST `/customers`
Register a new customer/member.

### GET `/customers/{id}`
Get customer by ID.

### GET `/customers/user/{userId}`
Get customer by user ID.

### GET `/customers/gym/{gymId}`
List all customers in a gym.

### GET `/customers/trainer/{trainerId}`
List all customers assigned to a trainer.

### PUT `/customers/{id}`
Update customer profile.

### PATCH `/customers/{id}/trainer`
Assign a trainer to a customer.

---

## 🎫 Memberships

### POST `/memberships`
Create a new membership.

### GET `/memberships/customer/{customerId}`
Get memberships for a customer.

### GET `/memberships/gym/{gymId}`
Get all memberships in a gym.

### PUT `/memberships/{id}`
Update a membership.

---

## 🏃 Workout Plans

### POST `/workout-plans`
Create a workout plan.

### GET `/workout-plans/{id}`
Get workout plan by ID.

### GET `/workout-plans/customer/{customerId}`
List all workout plans for a customer.

### GET `/workout-plans/customer/{customerId}/active`
Get active workout plan for a customer.

### PUT `/workout-plans/{id}`
Update a workout plan.

### DELETE `/workout-plans/{id}`
Delete a workout plan.

---

## 🥗 Diet Plans

### POST `/diet-plans`
Create a diet plan.

### GET `/diet-plans/customer/{customerId}`
List all diet plans for a customer.

### GET `/diet-plans/customer/{customerId}/active`
Get active diet plan for a customer.

### PUT `/diet-plans/{id}`
Update a diet plan.

---

## 💳 Payments

### POST `/payments`
Record a payment.

### GET `/payments/customer/{customerId}`
List payments for a customer.

### GET `/payments/gym/{gymId}`
List payments for a gym.

---

## 📊 Activity Logs

### POST `/activity-logs`
Create an activity log entry.

### GET `/activity-logs/customer/{customerId}`
Get all activity logs for a customer.

### GET `/activity-logs/customer/{customerId}/range`
Get activity logs within a date range. Query params: `start`, `end`.

### GET `/activity-logs/customer/{customerId}/recent`
Get recent activity logs.

---

## 🔔 Notifications

### GET `/notifications/user/{userId}`
Get all notifications for a user.

### GET `/notifications/user/{userId}/unread`
Get unread notifications.

### GET `/notifications/user/{userId}/unread-count`
Get count of unread notifications.

### PATCH `/notifications/{id}/read`
Mark a notification as read.

### PATCH `/notifications/user/{userId}/read-all`
Mark all notifications as read.

### POST `/notifications/send`
Send a notification.

---

## 📈 Analytics *(SUPER_ADMIN only)*

### GET `/analytics/overview`
Get platform-wide analytics (total users, gyms, revenue, etc.).

### GET `/analytics/gyms/{gymId}`
Get analytics for a specific gym.

---

## 🗄️ Database Tables (Supabase)

| Table | Description |
|-------|-------------|
| `users` | All registered users (members, trainers, gym admins, super admins) |
| `gyms` | Registered gyms |
| `trainers` | Trainer profiles |
| `customers` | Member/customer profiles |
| `memberships` | Gym membership records |
| `workout_plans` | Workout plans (exercises stored as JSONB) |
| `diet_plans` | Diet plans (meals stored as JSONB) |
| `payments` | Payment records |
| `activity_logs` | User activity tracking |
| `notifications` | Push notifications |

---

## 🔑 Supabase Connection Info

- **Project:** Gymora-db (`xvlvpqmrtxvxxzkpxhqs`)
- **Direct URL:** `db.xvlvpqmrtxvxxzkpxhqs.supabase.co:5432`
- **Pooler URL:** `aws-1-ap-south-1.pooler.supabase.com:6543`
- **Database:** `postgres`
- **Username:** `postgres` (direct) / `postgres.xvlvpqmrtxvxxzkpxhqs` (pooler)

---

*Generated on May 12, 2026 | Gymora Backend v1.0.0*
