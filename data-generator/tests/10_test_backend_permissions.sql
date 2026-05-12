-- TEST BACKEND PERMISSIONS
-- This script should be run by user: qlsv_app
-- Expected behavior: ONLY the CALL statements should succeed. 
-- All SELECT, INSERT, UPDATE, DELETE should fail with "command denied".
-- 
-- Run instruction: 
-- mysql -u qlsv_app -pchange-this-password --force sinhvien < data-generator/tests/10_test_backend_permissions.sql

USE sinhvien;

SELECT '--- 1. TEST CALL PROCEDURE (EXPECT SUCCESS) ---' AS info;
CALL sp_GetDanhSachKiHoc();

SELECT '--- 2. TEST SELECT (EXPECT DENIED) ---' AS info;
SELECT * FROM SinhVien LIMIT 1;

SELECT '--- 3. TEST INSERT (EXPECT DENIED) ---' AS info;
INSERT INTO Truong(ten, mota) VALUES ('Hack', 'Hack');

SELECT '--- 4. TEST UPDATE (EXPECT DENIED) ---' AS info;
UPDATE Truong SET ten = 'Hack' WHERE id = 1;

SELECT '--- 5. TEST DELETE (EXPECT DENIED) ---' AS info;
DELETE FROM Truong WHERE id = 1;
