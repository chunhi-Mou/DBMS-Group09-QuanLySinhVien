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
    -- 1. STUDENT REGISTRATION RULES
    -- =========================================================================

    -- Test 1.1: Đăng ký thành công (B23DCCE077 chưa có LHP 2)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE077', 2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('1.1 Đăng ký thành công', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    -- Test 1.2: Đăng ký lớp đầy (LHP 4 siso 2, đã có 2 SV 76, 77)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE075', 4);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('1.2 Đăng ký lớp đầy', 'Đã đầy', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã đầy', 'PASS', 'FAIL'));
    END;

    -- Test 1.3: Đăng ký trùng lịch (SV 75 có LHP 2 ở T1,N1,K1. LHP 5 cũng T1,N1,K1)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE075', 5);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('1.3 Đăng ký trùng lịch', 'Trùng lịch', COALESCE(v_msg, 'OK'), IF(v_msg = 'Trùng lịch', 'PASS', 'FAIL'));
    END;

    -- Test 1.4: Đăng ký môn đã qua (SV 75 đã qua CSDL LHP 1, thử đăng ký CSDL LHP 3)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE075', 3);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('1.4 Đăng ký môn đã qua', 'Đã qua', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã qua', 'PASS', 'FAIL'));
    END;

    -- Test 1.5: Hủy đăng ký và đăng ký lại (Reactivation)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE v_id INT;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        SELECT id INTO v_id FROM DangKyHoc WHERE sinhvien_id = 'B23DCCE075' AND lophocphan_id = 2;
        CALL sp_HuyDangKyHoc(v_id, 'B23DCCE075');
        CALL sp_DangKyHoc('B23DCCE075', 2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('1.5 Hủy và đăng ký lại', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    -- Test 1.6: Đăng ký trùng môn (SV 76 có LHP 4 môn MMT, thử đăng ký LHP 5 môn MMT)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE076', 5);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('1.6 Đăng ký trùng môn', 'Đã đăng ký', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã đăng ký', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 2. GRADE FINALIZATION RULES
    -- =========================================================================

    -- Test 2.1: Nhập điểm sau khi chốt (LHP 1 đã chốt trong seed)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE v_dkh_id INT;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        SELECT id INTO v_dkh_id FROM DangKyHoc WHERE lophocphan_id = 1 AND sinhvien_id = 'B23DCCE075' LIMIT 1;
        CALL sp_LuuDiemThanhPhan(2, v_dkh_id, 1, 10.0);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('2.1 Nhập điểm sau khi chốt', 'Đã chốt điểm', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã chốt điểm', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 3. ADMIN: CATALOG & STRUCTURE
    -- =========================================================================

    -- Test 3.1: Xóa môn có dependency (Môn 1 có LHP 1)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_DeleteMonHoc(1);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('3.1 Xóa môn có dependency', 'Đã có dữ liệu học vụ', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã có dữ liệu học vụ', 'PASS', 'FAIL'));
    END;

    -- Test 3.2: Đổi môn/kỳ khi có SV (LHP 2 có SV 75)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        -- Thử đổi LHP 2 (môn 2, kỳ 2) sang môn/kỳ khác (ví dụ môn 1 kỳ 1 id=1)
        CALL sp_Admin_UpdateLopHocPhan(2, 'JAVA-UPDATE', 1, 0, 45, 1);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('3.2 Đổi môn/kỳ khi có SV', 'Không thể đổi môn/kỳ khi đã có đăng ký', COALESCE(v_msg, 'OK'), IF(v_msg = 'Không thể đổi môn/kỳ khi đã có đăng ký', 'PASS', 'FAIL'));
    END;

    -- Test 3.3: Giảm sức chứa quá mức (LHP 4 có 2 SV active, thử giảm xuống 1)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_UpdateLopHocPhan(4, 'MMT-FULL', 1, 0, 1, 4);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('3.3 Giảm sức chứa quá mức', 'Sĩ số mới nhỏ hơn số SV đang đăng ký', COALESCE(v_msg, 'OK'), IF(v_msg = 'Sĩ số mới nhỏ hơn số SV đang đăng ký', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 4. ADMIN: SCHEDULE & BUOI HOC
    -- =========================================================================

    -- Test 4.1: Tạo buổi học trùng phòng (LHP 2 có buổi ở T1,N1,K1,Ph1. Thử LHP 3 vào đó)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateBuoiHoc(3, 1, 1, 1, 1, 2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('4.1 Tạo buổi học trùng phòng', 'Trùng phòng', COALESCE(v_msg, 'OK'), IF(v_msg = 'Trùng phòng', 'PASS', 'FAIL'));
    END;

    -- Test 4.2: Tạo buổi học trùng lịch giảng viên (GV 2 bận LHP 2 ở T1,N1,K1. Thử LHP 3 ở T1,N1,K1, Ph3)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateBuoiHoc(3, 1, 1, 1, 3, 2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('4.2 Tạo buổi học trùng lịch GV', 'Trùng lịch giảng viên', COALESCE(v_msg, 'OK'), IF(v_msg = 'Trùng lịch giảng viên', 'PASS', 'FAIL'));
    END;

    -- Test 4.3: Tạo buổi học khi lớp đã có sinh viên (LHP 4 đã có SV)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_CreateBuoiHoc(4, 1, 4, 4, 3, 3);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('4.3 Tạo buổi học khi lớp đã có SV', 'Đã có sinh viên', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã có sinh viên', 'PASS', 'FAIL'));
    END;

    -- Test 4.4: Xóa buổi học khi lớp đã có sinh viên (LHP 4 có SV, thử xóa buổi học id 4 của nó)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_DeleteBuoiHoc(4);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('4.4 Xóa buổi học có SV', 'Đã có sinh viên', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã có sinh viên', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 5. ADMIN: GRADE CONFIG
    -- =========================================================================

    -- Test 5.1: Sửa cấu hình điểm khi môn có điểm (Môn 1 đã chốt LHP 1)
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_AssignMonHocDauDiem(1, 1, 0.2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('5.1 Sửa cấu hình điểm có điểm', 'Đã có điểm', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã có điểm', 'PASS', 'FAIL'));
    END;

    -- Test 5.2: Xóa cấu hình điểm khi môn có điểm
    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_Admin_DeleteMonHocDauDiem(1, 1);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('5.2 Xóa cấu hình điểm có điểm', 'Đã có điểm', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã có điểm', 'PASS', 'FAIL'));
    END;

    -- =========================================================================
    -- 6. FINAL SUMMARY
    -- =========================================================================

    SELECT test_name, expected, actual, status FROM phase1_sp_test_result ORDER BY id;
    SELECT COUNT(*) AS total_tests, SUM(status = 'PASS') AS passed, SUM(status = 'FAIL') AS failed FROM phase1_sp_test_result;
END //
DELIMITER ;

CALL run_phase1_sp_tests();
DROP PROCEDURE IF EXISTS run_phase1_sp_tests;
