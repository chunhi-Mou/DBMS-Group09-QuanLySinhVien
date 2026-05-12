USE sinhvien;

DROP PROCEDURE IF EXISTS run_phase1_sp_tests;
DELIMITER //
CREATE PROCEDURE run_phase1_sp_tests()
BEGIN
    DROP TEMPORARY TABLE IF EXISTS phase1_sp_test_result;
    CREATE TEMPORARY TABLE phase1_sp_test_result (
        id INT AUTO_INCREMENT PRIMARY KEY,
        test_name VARCHAR(120) NOT NULL,
        expected VARCHAR(255) NOT NULL,
        actual VARCHAR(255) NOT NULL,
        status VARCHAR(10) NOT NULL
    );

    -- =========================================================================
    -- 1. COMMON & STUDENT & TEACHER
    -- =========================================================================

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_GetAuthUserByUsername('sv_test');
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetAuthUserByUsername', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_GetDanhSachKiHoc();
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetDanhSachKiHoc', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_LuuDiemThanhPhan(2, 2, 1, 8.75);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_LuuDiemThanhPhan hợp lệ', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_LuuDiemThanhPhan(3, 2, 1, 8.75);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_LuuDiemThanhPhan sai giảng viên', 'Không có quyền', COALESCE(v_msg, 'OK'), IF(v_msg = 'Không có quyền', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 2. ADMIN: INSTITUTIONAL STRUCTURE
    -- =========================================================================

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateTruong('Trường Test', 'Mô tả test');
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_CreateTruong', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE v_id INT;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        SELECT id INTO v_id FROM Truong WHERE ten = 'Trường Test' LIMIT 1;
        CALL sp_Admin_DeleteTruong(v_id);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_DeleteTruong', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateLopHanhChinh('CNTT01', 1);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_CreateLopHanhChinh trùng tên', 'Tên lớp đã tồn tại', COALESCE(v_msg, 'OK'), IF(v_msg = 'Tên lớp đã tồn tại', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 3. ADMIN: ACADEMIC CATALOG
    -- =========================================================================

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateMonHoc('IT_NEW_01', 'Môn Học Mới', 3, 'Mô tả', 1);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_CreateMonHoc hợp lệ', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateMonHoc('IT_NEW_01', 'Trùng Mã', 3, 'Mô tả', 1);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_CreateMonHoc trùng mã', 'Mã môn đã tồn tại', COALESCE(v_msg, 'OK'), IF(v_msg = 'Mã môn đã tồn tại', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE v_id INT;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        SELECT id INTO v_id FROM MonHoc WHERE mamh = 'IT_NEW_01';
        CALL sp_Admin_DeleteMonHoc(v_id);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_DeleteMonHoc hợp lệ', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_DeleteMonHoc(9999);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_DeleteMonHoc không tồn tại', 'Không tồn tại', COALESCE(v_msg, 'OK'), IF(v_msg = 'Không tồn tại', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 4. ADMIN: TRAINING & LHP
    -- =========================================================================

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_UpdateLopHocPhan(2, 'Lớp Test Update', 1, 0, 45, 2); -- Change monhockihoc_id while having registrations
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_UpdateLopHocPhan đổi môn khi có SV', 'Không thể đổi môn/kỳ khi đã có đăng ký', COALESCE(v_msg, 'OK'), IF(v_msg = 'Không thể đổi môn/kỳ khi đã có đăng ký', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_DeleteLopHocPhan(2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_DeleteLopHocPhan có SV', 'Đã có dữ liệu phụ thuộc', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã có dữ liệu phụ thuộc', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateBuoiHoc(1, 1, 1, 1, 1, 3); -- GV 3 not assigned to LHP 1
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_CreateBuoiHoc GV chưa phân công', 'Giảng viên chưa được phân công cho lớp này', COALESCE(v_msg, 'OK'), IF(v_msg = 'Giảng viên chưa được phân công cho lớp này', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateBuoiHoc(2, 1, 1, 1, 1, 2); -- Room 1, Tuan 1, Ngay 1, Kip 1 is occupied
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_CreateBuoiHoc trùng phòng', 'Trùng phòng', COALESCE(v_msg, 'OK'), IF(v_msg = 'Trùng phòng', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 5. ADMIN: GRADE CONFIG
    -- =========================================================================

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_AssignMonHocDauDiem(1, 1, 0.5); -- Mon 1 has grades
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_AssignMonHocDauDiem môn đã có điểm', 'Môn đã có điểm hoặc kết quả, không thể sửa cấu hình', COALESCE(v_msg, 'OK'), IF(v_msg = 'Môn đã có điểm hoặc kết quả, không thể sửa cấu hình', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_AssignMonHocDauDiem(3, 1, 1.2); -- Total > 1.0
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_Admin_AssignMonHocDauDiem vượt tỉ lệ', 'Tổng tỉ lệ vượt quá 1.0', COALESCE(v_msg, 'OK'), IF(v_msg = 'Tổng tỉ lệ vượt quá 1.0', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 6. FINAL SUMMARY
    -- =========================================================================

    SELECT test_name, expected, actual, status
      FROM phase1_sp_test_result
     ORDER BY id;

    SELECT COUNT(*) AS total_tests,
           SUM(status = 'PASS') AS passed,
           SUM(status = 'FAIL') AS failed
      FROM phase1_sp_test_result;
END //
DELIMITER ;

CALL run_phase1_sp_tests();
DROP PROCEDURE IF EXISTS run_phase1_sp_tests;
