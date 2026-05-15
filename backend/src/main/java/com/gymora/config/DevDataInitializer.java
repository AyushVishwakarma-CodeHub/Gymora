package com.gymora.config;

import com.gymora.model.entity.*;
import com.gymora.model.enums.*;
import com.gymora.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Configuration
@RequiredArgsConstructor
public class DevDataInitializer implements CommandLineRunner {

    private final GymRepository gymRepository;
    private final CustomerRepository customerRepository;
    private final MembershipRepository membershipRepository;
    private final org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        // Sync schema manually for Cloud DB
        syncSchema();

        // DEBUG: Print memberships columns
        try {
            System.out.println("--- MEMBERSHIPS TABLE COLUMNS ---");
            jdbcTemplate.queryForList("SELECT column_name, is_nullable FROM information_schema.columns WHERE table_name = 'memberships'")
                .forEach(System.out::println);
            System.out.println("---------------------------------");
        } catch (Exception e) {
            System.err.println("Could not query information_schema: " + e.getMessage());
        }

        // DEBUG: Print membership_plans columns
        try {
            System.out.println("--- MEMBERSHIP_PLANS TABLE COLUMNS ---");
            jdbcTemplate.queryForList("SELECT column_name, is_nullable FROM information_schema.columns WHERE table_name = 'membership_plans'")
                .forEach(System.out::println);
            System.out.println("---------------------------------");
        } catch (Exception e) {
            System.err.println("Could not query information_schema for plans: " + e.getMessage());
        }

        // DEBUG: Print activity_logs columns
        try {
            System.out.println("--- ACTIVITY_LOGS TABLE COLUMNS ---");
            jdbcTemplate.queryForList("SELECT column_name, is_nullable FROM information_schema.columns WHERE table_name = 'activity_logs'")
                .forEach(System.out::println);
            System.out.println("---------------------------------");
        } catch (Exception e) {
            System.err.println("Could not query information_schema for logs: " + e.getMessage());
        }

        // DEBUG: Print all users and customers
        try {
            System.out.println("--- USERS ---");
            jdbcTemplate.queryForList("SELECT id, full_name, email, role FROM users")
                .forEach(System.out::println);
            System.out.println("--- CUSTOMERS ---");
            jdbcTemplate.queryForList("SELECT id, user_id, gym_id FROM customers")
                .forEach(System.out::println);
            System.out.println("---------------------------------");
        } catch (Exception e) {
            System.err.println("Could not query users/customers: " + e.getMessage());
        }

        // 1. Create gyms for GYM_ADMIN users who don't have one
        jdbcTemplate.queryForList("SELECT id, full_name, address FROM users WHERE role = 'GYM_ADMIN'")
                .forEach(row -> {
                    Long userId = (Long) row.get("id");
                    String fullName = (String) row.get("full_name");
                    String address = (String) row.get("address");

                    Long count = jdbcTemplate.queryForObject(
                            "SELECT count(*) FROM gyms WHERE admin_id = ?", Long.class, userId);

                    if (count == 0) {
                        System.out.println("Creating missing gym for owner: " + fullName);
                        jdbcTemplate.update(
                                "INSERT INTO gyms (name, address, location, admin_id, owner_id, status, approved, setup_complete, created_at) VALUES (?, ?, ?, ?, ?, 'APPROVED', TRUE, TRUE, CURRENT_TIMESTAMP)",
                                fullName + "'s Gym", address != null ? address : "LPU Campus", address != null ? address : "LPU Campus", userId, userId
                        );
                    }
                });

        // 2. Auto-approve all pending gyms for development
        gymRepository.findAll().stream()
                .filter(gym -> gym.getStatus() == GymStatus.PENDING)
                .forEach(gym -> {
                    if (gym.getAddress() == null || gym.getAddress().isBlank()) {
                        gym.setAddress("LPU Campus");
                    }
                    gym.setStatus(GymStatus.APPROVED);
                    gymRepository.save(gym);
                });

        // 3. Seed Ayush Data
        seedAyushData();
    }

    private void seedAyushData() {
        try {
            System.out.println("Seeding Ayush (Member) Data...");
            
            // 1. Create User if not exists
            String email = "ayush@gmail.com";
            Long userId;
            try {
                userId = jdbcTemplate.queryForObject("SELECT id FROM users WHERE email = ?", Long.class, email);
                jdbcTemplate.update("UPDATE users SET role = 'CUSTOMER' WHERE id = ?", userId);
            } catch (Exception e) {
                // BCrypt for '123456'
                String passHash = "$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.7uSyLnS"; 
                jdbcTemplate.update(
                    "INSERT INTO users (full_name, email, password_hash, role, is_active, approved, enabled, created_at) VALUES (?, ?, ?, 'CUSTOMER', TRUE, TRUE, TRUE, CURRENT_TIMESTAMP)",
                    "Ayush Vishwakarma", email, passHash
                );
                userId = jdbcTemplate.queryForObject("SELECT id FROM users WHERE email = ?", Long.class, email);
            }

            // 0. Ensure all gyms are APPROVED for registration demo
            try {
                jdbcTemplate.update("UPDATE gyms SET status = 'APPROVED'");
                List<Map<String, Object>> gyms = jdbcTemplate.queryForList("SELECT id, name, status FROM gyms");
                System.out.println("--- DIAGNOSTIC: ALL GYMS IN DB ---");
                for (Map<String, Object> g : gyms) {
                    System.out.println("Gym: ID=" + g.get("id") + ", Name=" + g.get("name") + ", Status=" + g.get("status"));
                }
                if (gyms.isEmpty()) {
                    System.out.println("No gyms found! Forcing one...");
                    jdbcTemplate.update("INSERT INTO users (full_name, email, password_hash, role, approved, enabled) VALUES ('Admin', 'admin@gymora.com', 'pass', 'SUPER_ADMIN', true, true)");
                    Long adminId = jdbcTemplate.queryForObject("SELECT id FROM users LIMIT 1", Long.class);
                    jdbcTemplate.update("INSERT INTO gyms (name, address, city, phone, status, admin_id) VALUES ('Default Gym', '123 St', 'City', '123', 'APPROVED', ?)", adminId);
                    System.out.println("Forced gym insertion complete.");
                }
                System.out.println("---------------------------------");
            } catch (Exception e) {
                System.err.println("Diagnostic Error: " + e.getMessage());
            }

            // 1. Get or Create Ayush (User/Customer)
            Long gymId;
            try {
                gymId = jdbcTemplate.queryForObject("SELECT gym_id FROM customers WHERE user_id = ?", Long.class, userId);
            } catch (Exception e) {
                try {
                    gymId = jdbcTemplate.queryForObject("SELECT id FROM gyms LIMIT 1", Long.class);
                } catch (Exception ex) {
                    // Create a default gym if none exists
                    Long ownerId;
                    try {
                        ownerId = jdbcTemplate.queryForObject("SELECT id FROM users WHERE role = 'GYM_ADMIN' LIMIT 1", Long.class);
                    } catch (Exception ex2) {
                        jdbcTemplate.update("INSERT INTO users (full_name, email, password_hash, role, approved, enabled, created_at) VALUES (?, ?, ?, 'GYM_ADMIN', TRUE, TRUE, CURRENT_TIMESTAMP)", "Default Owner", "owner@gymora.com", "$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.7uSyLnS");
                        ownerId = jdbcTemplate.queryForObject("SELECT id FROM users WHERE role = 'GYM_ADMIN' LIMIT 1", Long.class);
                    }
                    jdbcTemplate.update("INSERT INTO gyms (name, address, city, phone, status, admin_id, created_at) VALUES (?, ?, ?, ?, 'APPROVED', ?, CURRENT_TIMESTAMP)", "Central Gym", "LPU Campus", "Phagwara", "9876543210", ownerId);
                    gymId = jdbcTemplate.queryForObject("SELECT id FROM gyms LIMIT 1", Long.class);
                }
            }

            Long trainerId;
            try {
                trainerId = jdbcTemplate.queryForObject("SELECT id FROM trainers WHERE gym_id = ? LIMIT 1", Long.class, gymId);
            } catch (Exception e) {
                // Create a default trainer
                String trainerEmail = "trainer@gymora.com";
                Long trainerUserId;
                try {
                    trainerUserId = jdbcTemplate.queryForObject("SELECT id FROM users WHERE email = ?", Long.class, trainerEmail);
                } catch (Exception ex) {
                    jdbcTemplate.update("INSERT INTO users (full_name, email, password_hash, role, approved, enabled, created_at) VALUES (?, ?, ?, 'TRAINER', TRUE, TRUE, CURRENT_TIMESTAMP)", "Professional Trainer", trainerEmail, "$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.7uSyLnS");
                    trainerUserId = jdbcTemplate.queryForObject("SELECT id FROM users WHERE email = ?", Long.class, trainerEmail);
                }
                jdbcTemplate.update("INSERT INTO trainers (user_id, gym_id, specialization, experience_years, is_approved, created_at) VALUES (?, ?, 'Bodybuilding', 5, TRUE, CURRENT_TIMESTAMP)", trainerUserId, gymId);
                trainerId = jdbcTemplate.queryForObject("SELECT id FROM trainers WHERE gym_id = ? LIMIT 1", Long.class, gymId);
            }

            // 3. Create Customer profile if not exists
            Long customerId;
            try {
                customerId = jdbcTemplate.queryForObject("SELECT id FROM customers WHERE user_id = ?", Long.class, userId);
            } catch (Exception e) {
                jdbcTemplate.update(
                    "INSERT INTO customers (user_id, gym_id, trainer_id, gender, weight_kg, height_cm, goal, is_approved, created_at) VALUES (?, ?, ?, 'MALE', 75.5, 178.0, 'MUSCLE_GAIN', TRUE, CURRENT_TIMESTAMP)",
                    userId, gymId, trainerId
                );
                customerId = jdbcTemplate.queryForObject("SELECT id FROM customers WHERE user_id = ?", Long.class, userId);
            }

            // 4. Add Membership (2 days left)
            try {
                System.out.println("DEBUG: Seeding membership for Ayush. customerId=" + customerId + ", gymId=" + gymId);
                jdbcTemplate.update("DELETE FROM memberships WHERE customer_id = ?", customerId);
                
                // Get a valid plan_id or create one
                Long planIdFinal;
                try {
                    planIdFinal = jdbcTemplate.queryForObject("SELECT id FROM membership_plans LIMIT 1", Long.class);
                } catch (Exception e) {
                    // Create a dummy plan if none exists (using discovered schema)
                    jdbcTemplate.update("INSERT INTO membership_plans (name, price, duration_months, active, created_at) VALUES ('PREMIUM', 12000, 12, TRUE, CURRENT_TIMESTAMP)");
                    planIdFinal = jdbcTemplate.queryForObject("SELECT id FROM membership_plans LIMIT 1", Long.class);
                }

                // Exhaustive insert matching the discovered schema
                jdbcTemplate.update(
                    "INSERT INTO memberships (customer_id, member_id, gym_id, plan_id, plan_name, price, duration_type, start_date, end_date, status, created_at) " +
                    "VALUES (?, ?, ?, ?, 'PREMIUM', 12000.0, 'MONTHLY', CURRENT_DATE - INTERVAL '28 days', CURRENT_DATE + INTERVAL '2 days', 'ACTIVE', CURRENT_TIMESTAMP)",
                    customerId, customerId, gymId, planIdFinal
                );
                System.out.println("Membership seeded with SCHEMA-PERFECT SQL: 2 days left.");
            } catch (Exception e) {
                System.err.println("Warning: Could not seed Membership: " + e.getMessage());
                e.printStackTrace();
            }

            // 5. Add Workout Plan
            try {
                jdbcTemplate.update("DELETE FROM workout_plans WHERE customer_id = ?", customerId);
                String exercises = "[{\"name\": \"Bench Press\", \"sets\": \"4x10\", \"notes\": \"Heavy\"}, {\"name\": \"Squats\", \"sets\": \"3x12\", \"notes\": \"Focus on form\"}, {\"name\": \"Deadlift\", \"sets\": \"3x5\", \"notes\": \"Keep back straight\"}]";
                jdbcTemplate.update(
                    "INSERT INTO workout_plans (title, description, exercises, customer_id, member_id, trainer_id, plan_type, start_date, end_date, is_active, created_at) VALUES (?, ?, ?::jsonb, ?, ?, ?, 'DAILY', CURRENT_DATE, CURRENT_DATE + INTERVAL '3 months', TRUE, CURRENT_TIMESTAMP)",
                    "Elite Strength Program", "Focus on compound movements and progressive overload.", exercises, customerId, customerId, trainerId
                );
                System.out.println("Workout plan seeded successfully (DAILY).");
            } catch (Exception e) {
                System.err.println("Warning: Could not seed Workout Plan: " + e.getMessage());
            }

            // 6. Add Diet Plan
            try {
                jdbcTemplate.update("DELETE FROM diet_plans WHERE customer_id = ?", customerId);
                String meals = "[" +
                    "{\"meal\": \"Breakfast\", \"time\": \"08:00 AM\", \"items\": [\"Oats with Berries\", \"4 Egg Whites\"], \"cal\": 450}," +
                    "{\"meal\": \"Lunch\", \"time\": \"01:30 PM\", \"items\": [\"Grilled Chicken\", \"Brown Rice\", \"Broccoli\"], \"cal\": 750}," +
                    "{\"meal\": \"Evening Snacks\", \"time\": \"05:00 PM\", \"items\": [\"Protein Shake\", \"Handful of Almonds\"], \"cal\": 350}," +
                    "{\"meal\": \"Dinner\", \"time\": \"08:30 PM\", \"items\": [\"Grilled Salmon\", \"Sweet Potato\", \"Salad\"], \"cal\": 650}" +
                    "]";
                jdbcTemplate.update(
                    "INSERT INTO diet_plans (title, description, meals, customer_id, member_id, trainer_id, target_calories, start_date, end_date, is_active, created_at) VALUES (?, ?, ?::jsonb, ?, ?, ?, 2800, CURRENT_DATE, CURRENT_DATE + INTERVAL '3 months', TRUE, CURRENT_TIMESTAMP)",
                    "Elite Bulk Diet", "High protein and clean carbs for lean muscle growth.", meals, customerId, customerId, trainerId
                );
                System.out.println("Diet plan seeded with 4 meals.");
            } catch (Exception e) {
                System.err.println("Warning: Could not seed Diet Plan: " + e.getMessage());
            }

            // 7. Add Activity Logs (Last 10 days)
            try {
                jdbcTemplate.update("DELETE FROM activity_logs WHERE customer_id = ?", customerId);
                // Seed data for last 10 days to ensure it shows in range
                for (int i = 9; i >= 0; i--) {
                    jdbcTemplate.update(
                        "INSERT INTO activity_logs (customer_id, log_date, weight_kg, calories_consumed, calories_burned, steps, water_ml, bmi, created_at) " +
                        "VALUES (?, CURRENT_DATE - (INTERVAL '1 day' * ?), ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)",
                        customerId, i, 75.5 - (i * 0.1), 2400 + (i * 50), 500 + (i * 20), 8000 + (i * 200), 3000, 24.5
                    );
                }
                System.out.println("Activity logs seeded for last 10 days.");
            } catch (Exception e) {
                System.err.println("Warning: Could not seed Activity Logs: " + e.getMessage());
                e.printStackTrace();
            }

            System.out.println("Ayush data seeded successfully!");
        } catch (Exception e) {
            System.err.println("Warning: Could not seed Ayush data (maybe tables not ready?): " + e.getMessage());
        }
    }

    private void syncSchema() {
        try {
            System.out.println("Starting Cloud Database Schema sync...");
            
            // Users Table - Fix the "enabled" constraint mismatch
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS enabled BOOLEAN DEFAULT TRUE");
            jdbcTemplate.execute("ALTER TABLE users ALTER COLUMN enabled SET DEFAULT TRUE");
            jdbcTemplate.execute("UPDATE users SET enabled = TRUE WHERE enabled IS NULL");

            // Synchronization Protocol: Ensure columns exist but DO NOT drop 'password' anymore
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS password VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(255)");

            // Drop outdated role check constraint (friend's web app may have different role names)
            try {
                jdbcTemplate.execute("ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check");
            } catch (Exception ignored) {}
            
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE");
            jdbcTemplate.execute("ALTER TABLE users ALTER COLUMN is_active SET DEFAULT TRUE");
            jdbcTemplate.execute("UPDATE users SET is_active = TRUE WHERE is_active IS NULL");

            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS address VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");

            // Trainers Table
            jdbcTemplate.execute("ALTER TABLE trainers ADD COLUMN IF NOT EXISTS specialization VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE trainers ADD COLUMN IF NOT EXISTS experience_years INTEGER");
            jdbcTemplate.execute("ALTER TABLE trainers ADD COLUMN IF NOT EXISTS bio TEXT");
            jdbcTemplate.execute("ALTER TABLE trainers ADD COLUMN IF NOT EXISTS is_approved BOOLEAN DEFAULT FALSE");
            jdbcTemplate.execute("ALTER TABLE trainers ADD COLUMN IF NOT EXISTS certifications TEXT");
            jdbcTemplate.execute("ALTER TABLE trainers ADD COLUMN IF NOT EXISTS social_links TEXT");
            jdbcTemplate.execute("ALTER TABLE trainers ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE");
            jdbcTemplate.execute("ALTER TABLE trainers ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");

            // Gyms Table
            jdbcTemplate.execute("ALTER TABLE gyms ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING'");
            jdbcTemplate.execute("ALTER TABLE gyms ADD COLUMN IF NOT EXISTS logo_url VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE gyms ADD COLUMN IF NOT EXISTS description TEXT");
            jdbcTemplate.execute("ALTER TABLE gyms ADD COLUMN IF NOT EXISTS admin_id BIGINT");
            jdbcTemplate.execute("ALTER TABLE gyms ADD COLUMN IF NOT EXISTS city VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE gyms ADD COLUMN IF NOT EXISTS phone VARCHAR(255)");
            // Workout Plans - fix exercises column type
            try {
                jdbcTemplate.execute("ALTER TABLE workout_plans ALTER COLUMN exercises TYPE jsonb USING exercises::jsonb");
            } catch (Exception ignored) {}

            // Diet Plans - fix meals column type
            try {
                jdbcTemplate.execute("ALTER TABLE diet_plans ALTER COLUMN meals TYPE jsonb USING meals::jsonb");
            } catch (Exception ignored) {}

            System.out.println("Cloud Database Schema synced successfully!");
        } catch (Exception e) {
            System.err.println("Error syncing schema: " + e.getMessage());
        }
    }
}
