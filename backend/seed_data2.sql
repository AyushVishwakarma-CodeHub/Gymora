-- Diet Plan (correct columns: target_calories, meals is jsonb)
INSERT INTO diet_plans (trainer_id, customer_id, title, description, meals, target_calories, start_date, end_date, is_active, created_at)
VALUES
  (3, 6, 'Muscle Building Diet', 'High protein diet plan for muscle gain', '[{"meal":"Breakfast","time":"8:00 AM","items":["Oatmeal with berries","Protein shake","2 boiled eggs"],"cal":450},{"meal":"Lunch","time":"1:00 PM","items":["Grilled chicken breast","Brown rice","Mixed vegetables"],"cal":650},{"meal":"Snack","time":"4:00 PM","items":["Greek yogurt","Almonds","Apple"],"cal":250},{"meal":"Dinner","time":"7:30 PM","items":["Salmon fillet","Quinoa","Steamed broccoli"],"cal":550}]', 1900, '2026-05-01', '2026-06-01', true, NOW());

-- Membership (correct columns: plan_name, price)
INSERT INTO memberships (customer_id, gym_id, plan_name, price, duration_type, start_date, end_date, status, created_at)
VALUES (6, 2, 'Premium Monthly', 2999.00, 'MONTHLY', '2026-05-01', '2026-06-01', 'ACTIVE', NOW());
