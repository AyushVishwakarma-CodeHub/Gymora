package com.gymora.config;

import com.gymora.model.enums.GymStatus;
import com.gymora.repository.GymRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

@Configuration
@RequiredArgsConstructor
public class DevDataInitializer implements CommandLineRunner {

    private final GymRepository gymRepository;
    private final org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    @Override
    @Transactional
    public void run(String... args) {
        // Sync schema manually for Cloud DB
        syncSchema();

        // Auto-approve all pending gyms for development
        gymRepository.findAll().stream()
                .filter(gym -> gym.getStatus() == GymStatus.PENDING)
                .forEach(gym -> {
                    // Fix missing address to avoid validation crash
                    if (gym.getAddress() == null || gym.getAddress().isBlank()) {
                        gym.setAddress("LPU Campus");
                    }
                    gym.setStatus(GymStatus.APPROVED);
                    gymRepository.save(gym);
                });
    }

    private void syncSchema() {
        try {
            System.out.println("Starting Cloud Database Schema sync...");
            
            // Users Table - Fix the "enabled" constraint mismatch
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS enabled BOOLEAN DEFAULT TRUE");
            jdbcTemplate.execute("ALTER TABLE users ALTER COLUMN enabled SET DEFAULT TRUE");
            jdbcTemplate.execute("UPDATE users SET enabled = TRUE WHERE enabled IS NULL");

            // Drop old 'password' column if it exists (we use 'password_hash' instead)
            try {
                jdbcTemplate.execute("ALTER TABLE users DROP COLUMN IF EXISTS password");
            } catch (Exception ignored) {}

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
