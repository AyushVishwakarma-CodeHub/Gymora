# Gymora Backend

## Prerequisites
- Java 17+
- Maven 3.9+
- PostgreSQL 16
- Redis 7

## Running Locally

```bash
# Start PostgreSQL and Redis with Docker
docker-compose up -d postgres redis

# Run the Spring Boot application
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

## Running with Docker

```bash
# Build and start all services
docker-compose up --build -d

# View logs
docker-compose logs -f backend
```

## API Documentation

Once running, access Swagger UI at:
- http://localhost:8080/api/swagger-ui.html

## Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@gymora.com | admin123 |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| DB_HOST | localhost | PostgreSQL host |
| DB_PORT | 5432 | PostgreSQL port |
| DB_NAME | gymora_db | Database name |
| DB_USERNAME | gymora_user | DB username |
| DB_PASSWORD | gymora_pass | DB password |
| REDIS_HOST | localhost | Redis host |
| JWT_SECRET | - | JWT signing key |
