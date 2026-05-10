-- Fix passwords for test accounts
UPDATE users 
SET password_hash = '$2a$10$Lkuo.oyZbIsYTkEQtP8xU.b/hSQQrbdlDNKgFDbBgu7LxkTfjY/1O' 
WHERE email IN ('owner@gymora.com', 'trainer@gymora.com', 'ayushthesweetdabang@gmail.com', 'admin@gymora.com');
