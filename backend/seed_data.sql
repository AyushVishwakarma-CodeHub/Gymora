-- Workout Plans for customer 6 (ayushthesweetdabang@gmail.com)
INSERT INTO workout_plans (trainer_id, customer_id, title, description, exercises, plan_type, start_date, end_date, is_active, created_at)
VALUES 
  (3, 6, 'Chest and Triceps', '45 min upper body push', '[{"name":"Bench Press","sets":"4x12","rest":"90s"},{"name":"Incline Dumbbell Press","sets":"3x12","rest":"60s"},{"name":"Cable Flyes","sets":"3x15","rest":"60s"},{"name":"Tricep Pushdowns","sets":"3x12","rest":"60s"},{"name":"Overhead Extension","sets":"3x12","rest":"60s"}]', 'WEEKLY', '2026-05-01', '2026-06-01', true, NOW()),
  (3, 6, 'Back and Biceps', '50 min upper body pull', '[{"name":"Deadlifts","sets":"4x10","rest":"120s"},{"name":"Pull-ups","sets":"3x10","rest":"60s"},{"name":"Barbell Rows","sets":"3x12","rest":"60s"},{"name":"Dumbbell Curls","sets":"3x12","rest":"60s"},{"name":"Hammer Curls","sets":"3x12","rest":"60s"}]', 'WEEKLY', '2026-05-01', '2026-06-01', true, NOW()),
  (3, 6, 'Leg Day', '55 min lower body', '[{"name":"Squats","sets":"4x12","rest":"120s"},{"name":"Leg Press","sets":"3x12","rest":"90s"},{"name":"Lunges","sets":"3x12","rest":"60s"},{"name":"Leg Curls","sets":"3x12","rest":"60s"},{"name":"Calf Raises","sets":"4x15","rest":"45s"}]', 'WEEKLY', '2026-05-01', '2026-06-01', true, NOW());

-- Diet Plans for customer 6
INSERT INTO diet_plans (trainer_id, customer_id, title, description, meals, total_calories, start_date, end_date, is_active, created_at)
VALUES
  (3, 6, 'Muscle Building Diet', 'High protein diet plan for muscle gain', '[{"meal":"Breakfast","time":"8:00 AM","items":["Oatmeal with berries","Protein shake","2 boiled eggs"],"cal":450},{"meal":"Lunch","time":"1:00 PM","items":["Grilled chicken breast","Brown rice","Mixed vegetables"],"cal":650},{"meal":"Snack","time":"4:00 PM","items":["Greek yogurt","Almonds","Apple"],"cal":250},{"meal":"Dinner","time":"7:30 PM","items":["Salmon fillet","Quinoa","Steamed broccoli"],"cal":550}]', 1900, '2026-05-01', '2026-06-01', true, NOW());

-- Memberships for customer 6
INSERT INTO memberships (customer_id, gym_id, membership_type, duration_type, start_date, end_date, amount, status, created_at)
VALUES (6, 2, 'Premium', 'MONTHLY', '2026-05-01', '2026-06-01', 2999.00, 'ACTIVE', NOW());

-- Activity Logs for customer 6 (last 10 days)
INSERT INTO activity_logs (customer_id, log_date, weight_kg, calories_consumed, calories_burned, steps, water_ml, notes, created_at)
VALUES
  (6, '2026-04-30', 73.0, 2200, 350, 6500, 2000, 'Morning run + chest workout', NOW()),
  (6, '2026-05-01', 72.8, 2100, 420, 7200, 2500, 'Back and biceps day', NOW()),
  (6, '2026-05-02', 72.6, 1950, 280, 5000, 2200, 'Rest day - light walk', NOW()),
  (6, '2026-05-03', 72.5, 2300, 500, 8500, 2800, 'Leg day - intense', NOW()),
  (6, '2026-05-04', 72.7, 2050, 380, 6000, 2100, 'Shoulders and abs', NOW()),
  (6, '2026-05-05', 72.4, 1800, 450, 9000, 3000, 'Cardio + HIIT', NOW()),
  (6, '2026-05-06', 72.3, 2400, 200, 3500, 1800, 'Active recovery', NOW()),
  (6, '2026-05-07', 72.1, 2000, 480, 7800, 2600, 'Chest and triceps', NOW()),
  (6, '2026-05-08', 72.0, 2150, 400, 6200, 2400, 'Back workout', NOW()),
  (6, '2026-05-09', 71.8, 1900, 350, 5500, 2000, 'Morning cardio', NOW());
