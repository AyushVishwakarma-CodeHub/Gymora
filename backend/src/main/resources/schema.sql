-- Gymora Database Schema
-- PostgreSQL 16

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    role VARCHAR(20) NOT NULL CHECK (role IN ('SUPER_ADMIN', 'GYM_ADMIN', 'TRAINER', 'CUSTOMER')),
    fcm_token TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Gyms Table
CREATE TABLE IF NOT EXISTS gyms (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100),
    phone VARCHAR(20),
    logo_url TEXT,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED')),
    admin_id BIGINT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trainers Table
CREATE TABLE IF NOT EXISTS trainers (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id),
    gym_id BIGINT NOT NULL REFERENCES gyms(id),
    specialization VARCHAR(255),
    experience_years INTEGER,
    bio TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id),
    gym_id BIGINT NOT NULL REFERENCES gyms(id),
    trainer_id BIGINT REFERENCES trainers(id),
    date_of_birth DATE,
    gender VARCHAR(10),
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    goal VARCHAR(30) CHECK (goal IN ('WEIGHT_LOSS', 'MUSCLE_GAIN', 'GENERAL_FITNESS', 'ENDURANCE', 'FLEXIBILITY')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Memberships Table
CREATE TABLE IF NOT EXISTS memberships (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    gym_id BIGINT NOT NULL REFERENCES gyms(id),
    plan_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_type VARCHAR(20) NOT NULL CHECK (duration_type IN ('MONTHLY', 'QUARTERLY', 'HALF_YEARLY', 'YEARLY')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments Table
CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    membership_id BIGINT NOT NULL REFERENCES memberships(id),
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED')),
    transaction_id VARCHAR(255),
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Workout Plans Table
CREATE TABLE IF NOT EXISTS workout_plans (
    id BIGSERIAL PRIMARY KEY,
    trainer_id BIGINT NOT NULL REFERENCES trainers(id),
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    exercises JSONB,
    plan_type VARCHAR(20) NOT NULL CHECK (plan_type IN ('DAILY', 'WEEKLY', 'MONTHLY')),
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Diet Plans Table
CREATE TABLE IF NOT EXISTS diet_plans (
    id BIGSERIAL PRIMARY KEY,
    trainer_id BIGINT NOT NULL REFERENCES trainers(id),
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    meals JSONB,
    target_calories INTEGER,
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activity Logs Table
CREATE TABLE IF NOT EXISTS activity_logs (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    log_date DATE NOT NULL,
    weight_kg DECIMAL(5,2),
    bmi DECIMAL(4,2),
    calories_consumed INTEGER,
    calories_burned INTEGER,
    steps INTEGER,
    water_ml INTEGER,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('MEMBERSHIP_EXPIRY', 'WORKOUT_REMINDER', 'PAYMENT', 'PLAN_ASSIGNED', 'GENERAL')),
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== INDEXES ====================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_gyms_admin_id ON gyms(admin_id);
CREATE INDEX IF NOT EXISTS idx_gyms_status ON gyms(status);
CREATE INDEX IF NOT EXISTS idx_trainers_user_id ON trainers(user_id);
CREATE INDEX IF NOT EXISTS idx_trainers_gym_id ON trainers(gym_id);
CREATE INDEX IF NOT EXISTS idx_customers_user_gym ON customers(user_id, gym_id);
CREATE INDEX IF NOT EXISTS idx_customers_trainer_id ON customers(trainer_id);
CREATE INDEX IF NOT EXISTS idx_memberships_customer_status ON memberships(customer_id, status);
CREATE INDEX IF NOT EXISTS idx_memberships_end_date ON memberships(end_date);
CREATE INDEX IF NOT EXISTS idx_memberships_gym_id ON memberships(gym_id);
CREATE INDEX IF NOT EXISTS idx_payments_customer_id ON payments(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_membership_id ON payments(membership_id);
CREATE INDEX IF NOT EXISTS idx_workout_plans_trainer_id ON workout_plans(trainer_id);
CREATE INDEX IF NOT EXISTS idx_workout_plans_customer_id ON workout_plans(customer_id);
CREATE INDEX IF NOT EXISTS idx_diet_plans_trainer_id ON diet_plans(trainer_id);
CREATE INDEX IF NOT EXISTS idx_diet_plans_customer_id ON diet_plans(customer_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_customer_date ON activity_logs(customer_id, log_date);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read);

-- ==================== SEED DATA ====================

-- Insert Super Admin user (password: admin123)
INSERT INTO users (email, password_hash, full_name, phone, role, is_active)
VALUES ('admin@gymora.com', '$2a$10$8K1p/a0dN7IRH5ioXfXI6OC5YVbMnnOAh9GvlPHZSNIzTJ7q7J6bq', 'Super Admin', '+919876543210', 'SUPER_ADMIN', true)
ON CONFLICT (email) DO NOTHING;
