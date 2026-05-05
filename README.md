# Gymora - Gym Management & Tracking Platform

<p align="center">
  <strong>🏋️ Your Fitness Journey Starts Here</strong>
</p>

A production-level gym management and fitness tracking platform with a Flutter mobile app and Spring Boot backend.

## 🧱 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) + Material Design |
| Backend | Spring Boot 3 (Java 17) |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| Auth | JWT (jjwt) |
| API Docs | Swagger (SpringDoc OpenAPI) |
| Deployment | Docker + Docker Compose |

## 🚀 Getting Started

### Prerequisites
- Java 17+
- Maven 3.9+
- Flutter 3.19+
- Docker & Docker Compose (optional)

### Backend Setup

```bash
# Start infrastructure
docker-compose up -d postgres redis

# Run backend
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### Flutter Setup

```bash
cd gymora_app
flutter pub get
flutter run
```

### Full Stack with Docker

```bash
docker-compose up --build -d
```

## 📱 Features

- **Role-Based Access**: Super Admin, Gym Admin, Trainer, Customer
- **Activity Tracking**: Weight, BMI, Calories with FL Chart visualizations
- **Workout & Diet Plans**: Trainer-assigned plans with daily tracking
- **Membership Management**: Plans, payments, expiry alerts
- **Real-time Notifications**: Firebase Cloud Messaging
- **Analytics Dashboard**: Revenue, member stats, trends

## 🔐 Default Login

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@gymora.com | admin123 |

## 📖 API Documentation

Access Swagger UI at: `http://localhost:8080/api/swagger-ui.html`

## 📁 Project Structure

```
Gymora/
├── backend/                 # Spring Boot API
│   ├── src/main/java/com/gymora/
│   │   ├── config/         # Security, Redis, Swagger, CORS
│   │   ├── controller/     # REST Controllers
│   │   ├── service/        # Business Logic
│   │   ├── repository/     # JPA Repositories
│   │   ├── model/          # Entities, DTOs, Enums
│   │   ├── security/       # JWT Auth
│   │   └── exception/      # Error Handling
│   └── src/main/resources/ # Config, Schema
├── gymora_app/             # Flutter Mobile App
│   └── lib/
│       ├── app/            # Theme, Routes
│       ├── core/           # Network, Storage, Utils
│       ├── features/       # Feature modules (MVVM)
│       └── shared/         # Reusable widgets
├── docker-compose.yml
└── README.md
```

## 📄 License

MIT License
