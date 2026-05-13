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
        CALL sp_GetLopHocPhanGiangVien(2, 2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetLopHocPhanGiangVien', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_GetLopHocPhanKhaDung('B23DCCE075', 2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetLopHocPhanKhaDung', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_GetBangDiemSinhVien('B23DCCE075', 1);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetBangDiemSinhVien', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_GetDashboardSinhVien('B23DCCE075');
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetDashboardSinhVien', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_GetTeacherGradeRoster(2, 2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetTeacherGradeRoster', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_GetBaoCaoHocLuc(1);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetBaoCaoHocLuc', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
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

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_LuuDiemThanhPhan(2, 2, 1, 11);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_LuuDiemThanhPhan điểm sai', 'Điểm không hợp lệ', COALESCE(v_msg, 'OK'), IF(v_msg = 'Điểm không hợp lệ', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_ChotDiemMonHoc(2, 2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_ChotDiemMonHoc hợp lệ', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_ChotDiemMonHoc(2, 3);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_ChotDiemMonHoc sai giảng viên', 'Không có quyền', COALESCE(v_msg, 'OK'), IF(v_msg = 'Không có quyền', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_TongKetHocKy(2);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_TongKetHocKy hợp lệ', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_TongKetHocKy(999);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_TongKetHocKy kỳ không tồn tại', 'Không tồn tại', COALESCE(v_msg, 'OK'), IF(v_msg = 'Không tồn tại', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE075', 4);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_DangKyHoc lớp đầy', 'Đã đầy', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã đầy', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE075', 3);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_DangKyHoc môn đã qua', 'Đã qua', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã qua', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE075', 5);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_DangKyHoc trùng lịch', 'Trùng lịch', COALESCE(v_msg, 'OK'), IF(v_msg = 'Trùng lịch', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE v_new_id INT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_DangKyHoc('B23DCCE076', 2);
        SELECT id INTO v_new_id
          FROM DangKyHoc
         WHERE sinhvien_id = 'B23DCCE076'
           AND lophocphan_id = 2
           AND trangthai <> 'Đã hủy'
         ORDER BY id DESC
         LIMIT 1;
        IF v_msg IS NULL AND v_new_id IS NOT NULL THEN
            CALL sp_HuyDangKyHoc(v_new_id, 'B23DCCE076');
        END IF;
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_DangKyHoc + sp_HuyDangKyHoc hợp lệ', 'OK', COALESCE(v_msg, 'OK'), IF(v_msg IS NULL, 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_HuyDangKyHoc(2, 'B23DCCE076');
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_HuyDangKyHoc sai chủ sở hữu', 'Không có quyền', COALESCE(v_msg, 'OK'), IF(v_msg = 'Không có quyền', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_HuyDangKyHoc(2, 'B23DCCE075');
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_HuyDangKyHoc đã có điểm', 'Đã có điểm', COALESCE(v_msg, 'OK'), IF(v_msg = 'Đã có điểm', 'PASS', 'FAIL'));
    END;

    BEGIN
        DECLARE v_msg TEXT DEFAULT NULL;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT; END;
        CALL sp_GetTeacherGradeRoster(2, 3);
        INSERT INTO phase1_sp_test_result(test_name, expected, actual, status)
        VALUES ('sp_GetTeacherGradeRoster sai giảng viên', 'Không có quyền', COALESCE(v_msg, 'OK'), IF(v_msg = 'Không có quyền', 'PASS', 'FAIL'));
    END;

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
