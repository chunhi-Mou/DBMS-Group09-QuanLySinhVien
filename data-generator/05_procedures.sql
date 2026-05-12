USE sinhvien;

-- Xóa các SP cũ để tránh xung đột naming mới
DROP PROCEDURE IF EXISTS sp_GetAuthUserByUsername;
DROP PROCEDURE IF EXISTS sp_GetDanhSachKiHoc;
DROP PROCEDURE IF EXISTS sp_GetLopHocPhanGiangVien;
DROP PROCEDURE IF EXISTS sp_GetBaoCaoHocLuc;
DROP PROCEDURE IF EXISTS sp_GetTeacherGradeRoster;
DROP PROCEDURE IF EXISTS sp_GetDashboardSinhVien;
DROP PROCEDURE IF EXISTS sp_GetBangDiemSinhVien;
DROP PROCEDURE IF EXISTS sp_GetLopHocPhanKhaDung;
DROP PROCEDURE IF EXISTS sp_TongKetHocKy;
DROP PROCEDURE IF EXISTS sp_ChotDiemMonHoc;
DROP PROCEDURE IF EXISTS sp_LuuDiemThanhPhan;
DROP PROCEDURE IF EXISTS sp_HuyDangKyHoc;
DROP PROCEDURE IF EXISTS sp_DangKyHoc;

-- Admin procedures (Ensure clean slate)
DROP PROCEDURE IF EXISTS sp_Admin_CreateTruong;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateTruong;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteTruong;
DROP PROCEDURE IF EXISTS sp_Admin_CreateKhoa;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateKhoa;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteKhoa;
DROP PROCEDURE IF EXISTS sp_Admin_CreateBoMon;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateBoMon;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteBoMon;
DROP PROCEDURE IF EXISTS sp_Admin_CreateNganh;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateNganh;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteNganh;
DROP PROCEDURE IF EXISTS sp_Admin_AssignMonHocNganh;
DROP PROCEDURE IF EXISTS sp_Admin_CreateLopHanhChinh;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateLopHanhChinh;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteLopHanhChinh;
DROP PROCEDURE IF EXISTS sp_Admin_CreateMonHoc;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateMonHoc;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteMonHoc;
DROP PROCEDURE IF EXISTS sp_Admin_CreateNamHoc;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateNamHoc;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteNamHoc;
DROP PROCEDURE IF EXISTS sp_Admin_CreateHocKi;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateHocKi;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteHocKi;
DROP PROCEDURE IF EXISTS sp_Admin_CreateKiHoc;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteKiHoc;
DROP PROCEDURE IF EXISTS sp_Admin_AssignMonHocKiHoc;
DROP PROCEDURE IF EXISTS sp_Admin_CreateLopHocPhan;
DROP PROCEDURE IF EXISTS sp_Admin_UpdateLopHocPhan;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteLopHocPhan;
DROP PROCEDURE IF EXISTS sp_Admin_AssignGiangVienLopHocPhan;
DROP PROCEDURE IF EXISTS sp_Admin_UnassignGiangVienLopHocPhan;
DROP PROCEDURE IF EXISTS sp_Admin_CreateBuoiHoc;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteBuoiHoc;
DROP PROCEDURE IF EXISTS sp_Admin_AssignMonHocDauDiem;
DROP PROCEDURE IF EXISTS sp_Admin_DeleteMonHocDauDiem;

DELIMITER //

-- =============================================================================
-- 1. AUTH & COMMON PROCEDURES
-- =============================================================================

CREATE PROCEDURE sp_GetAuthUserByUsername(IN p_username VARCHAR(255))
BEGIN
    SELECT
        tv.id AS thanhvien_id,
        tv.username,
        tv.password,
        tv.vaitro,
        TRIM(CONCAT(COALESCE(tv.hodem, ''), ' ', tv.ten)) AS hoTen,
        tv.email,
        sv.masv,
        gv.thanhvien_id AS giangvien_id,
        nv.thanhvien_id AS nhanvien_id
    FROM ThanhVien tv
    LEFT JOIN SinhVien sv ON sv.thanhvien_id = tv.id
    LEFT JOIN GiangVien gv ON gv.thanhvien_id = tv.id
    LEFT JOIN NhanVien nv ON nv.thanhvien_id = tv.id
    WHERE tv.username = p_username
    LIMIT 1;
END //

CREATE PROCEDURE sp_GetDanhSachKiHoc()
BEGIN
    SELECT
        ki.id AS kihoc_id,
        CONCAT(nh.ten, ' - ', hk.ten) AS ten_ki,
        nh.ten AS nam_hoc,
        hk.ten AS hoc_ki
    FROM KiHoc ki
    JOIN NamHoc nh ON nh.id = ki.namhoc_id
    JOIN HocKi hk ON hk.id = ki.hocki_id
    ORDER BY ki.id;
END //

-- =============================================================================
-- 2. STUDENT PROCEDURES
-- =============================================================================

CREATE PROCEDURE sp_GetLopHocPhanKhaDung(
    IN p_sinhvien_id VARCHAR(50),
    IN p_kihoc_id INT
)
BEGIN
    SELECT
        lhp.id AS lophocphan_id,
        lhp.ten AS ten_lop,
        mh.id AS monhoc_id,
        mh.ten AS ten_mon_hoc,
        mh.sotc,
        lhp.nhom,
        lhp.tothuchanh,
        lhp.sisotoida,
        COUNT(DISTINCT CASE WHEN dkh_all.trangthai <> 'Đã hủy' THEN dkh_all.id END) AS sisohientai,
        lhp.sisotoida - COUNT(DISTINCT CASE WHEN dkh_all.trangthai <> 'Đã hủy' THEN dkh_all.id END) AS cho_trong,
        COALESCE((
            SELECT nhm.loai
              FROM SinhVien_Nganh sn
              JOIN NganhHoc_MonHoc nhm ON nhm.nganh_id = sn.nganh_id
             WHERE sn.sinhvien_id = p_sinhvien_id
               AND nhm.monhoc_id = mh.id
             LIMIT 1
        ), 'TC') AS loai,
        CASE
            WHEN COUNT(DISTINCT CASE WHEN dkh_all.trangthai <> 'Đã hủy' THEN dkh_all.id END) >= lhp.sisotoida
            THEN 1 ELSE 0
        END AS daDay,
        CASE WHEN EXISTS (
            SELECT 1
              FROM DangKyHoc dkh_pass
              JOIN LopHocPhan lhp_pass ON lhp_pass.id = dkh_pass.lophocphan_id
              JOIN MonHoc_KiHoc mkh_pass ON mkh_pass.id = lhp_pass.monhockihoc_id
              JOIN KetQuaMon kqm_pass ON kqm_pass.dangkyhoc_id = dkh_pass.id
             WHERE dkh_pass.sinhvien_id = p_sinhvien_id
               AND dkh_pass.trangthai <> 'Đã hủy'
               AND mkh_pass.monhoc_id = mh.id
               AND kqm_pass.diem >= 4.0
        ) THEN 1 ELSE 0 END AS daPass,
        CASE WHEN dkh_sv.id IS NULL THEN 0 ELSE 1 END AS daDangKy,
        dkh_sv.id AS dangKyHocId,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'tuan_id', bh.tuan_id,
                'ngay_id', bh.ngay_id,
                'kiphoc_id', bh.kiphoc_id,
                'phong_hoc', ph.ten,
                'giang_vien', TRIM(CONCAT(COALESCE(tv.hodem, ''), ' ', tv.ten))
            ))
              FROM BuoiHoc bh
              JOIN PhongHoc ph ON ph.id = bh.phonghoc_id
              JOIN GiangVien gv ON gv.thanhvien_id = bh.giangvien_id
              JOIN ThanhVien tv ON tv.id = gv.thanhvien_id
             WHERE bh.lophocphan_id = lhp.id
        ), JSON_ARRAY()) AS buoiHoc,
        COALESCE((
            SELECT JSON_ARRAYAGG(gv_name.hoten)
              FROM (
                    SELECT DISTINCT TRIM(CONCAT(COALESCE(tv2.hodem, ''), ' ', tv2.ten)) AS hoten
                      FROM GiangVien_LopHocPhan gvlhp2
                      JOIN GiangVien gv2 ON gv2.thanhvien_id = gvlhp2.giangvien_id
                      JOIN ThanhVien tv2 ON tv2.id = gv2.thanhvien_id
                     WHERE gvlhp2.lophocphan_id = lhp.id
                   ) gv_name
        ), JSON_ARRAY()) AS giangVien
    FROM LopHocPhan lhp
    JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
    JOIN MonHoc mh ON mh.id = mkh.monhoc_id
    LEFT JOIN DangKyHoc dkh_all ON dkh_all.lophocphan_id = lhp.id
    LEFT JOIN DangKyHoc dkh_sv
           ON dkh_sv.lophocphan_id = lhp.id
          AND dkh_sv.sinhvien_id = p_sinhvien_id
          AND dkh_sv.trangthai <> 'Đã hủy'
    WHERE mkh.kihoc_id = p_kihoc_id
    GROUP BY
        lhp.id, lhp.ten, mh.id, mh.ten, mh.sotc,
        lhp.nhom, lhp.tothuchanh, lhp.sisotoida, dkh_sv.id;
END //

CREATE PROCEDURE sp_DangKyHoc(
    IN p_sinhvien_id VARCHAR(50),
    IN p_lophocphan_id INT
)
BEGIN
    DECLARE v_sisotoida INT;
    DECLARE v_sisohientai INT;
    DECLARE v_monhoc_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM SinhVien WHERE masv = p_sinhvien_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sinh viên không tồn tại';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE id = p_lophocphan_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp không tồn tại';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM DangKyHoc
         WHERE sinhvien_id = p_sinhvien_id
           AND lophocphan_id = p_lophocphan_id
           AND trangthai <> 'Đã hủy'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã đăng ký';
    END IF;

    SELECT lhp.sisotoida, mkh.monhoc_id
      INTO v_sisotoida, v_monhoc_id
      FROM LopHocPhan lhp
      JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
     WHERE lhp.id = p_lophocphan_id
     FOR UPDATE;

    IF EXISTS (
        SELECT 1
          FROM DangKyHoc dkh
          JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
          JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
          JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id
         WHERE dkh.sinhvien_id = p_sinhvien_id
           AND dkh.trangthai <> 'Đã hủy'
           AND mkh.monhoc_id = v_monhoc_id
           AND kqm.diem >= 4.0
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã qua';
    END IF;

    SELECT COUNT(*)
      INTO v_sisohientai
      FROM DangKyHoc
     WHERE lophocphan_id = p_lophocphan_id
       AND trangthai <> 'Đã hủy';

    IF v_sisohientai >= v_sisotoida THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã đầy';
    END IF;

    -- Xử lý đăng ký lại nếu trước đó đã hủy
    IF EXISTS (SELECT 1 FROM DangKyHoc WHERE sinhvien_id = p_sinhvien_id AND lophocphan_id = p_lophocphan_id AND trangthai = 'Đã hủy') THEN
        UPDATE DangKyHoc
           SET trangthai = 'Đã lưu', ngaydangky = NOW()
         WHERE sinhvien_id = p_sinhvien_id AND lophocphan_id = p_lophocphan_id;
    ELSE
        INSERT INTO DangKyHoc(ngaydangky, trangthai, sinhvien_id, lophocphan_id)
        VALUES (NOW(), 'Đã lưu', p_sinhvien_id, p_lophocphan_id);
    END IF;

    COMMIT;
END //

CREATE PROCEDURE sp_HuyDangKyHoc(
    IN p_dangkyhoc_id INT,
    IN p_sinhvien_id VARCHAR(50)
)
BEGIN
    DECLARE v_owner VARCHAR(50);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_owner = NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT sinhvien_id
      INTO v_owner
      FROM DangKyHoc
     WHERE id = p_dangkyhoc_id
     FOR UPDATE;

    IF v_owner IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại';
    END IF;

    IF v_owner <> p_sinhvien_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không có quyền';
    END IF;

    IF EXISTS (SELECT 1 FROM KetQuaMon WHERE dangkyhoc_id = p_dangkyhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có điểm';
    END IF;

    -- Soft cancel as requested
    UPDATE DangKyHoc SET trangthai = 'Đã hủy' WHERE id = p_dangkyhoc_id;

    COMMIT;
END //

CREATE PROCEDURE sp_GetBangDiemSinhVien(
    IN p_sinhvien_id VARCHAR(50),
    IN p_kihoc_id INT
)
BEGIN
    SELECT COALESCE(JSON_ARRAYAGG(JSON_OBJECT(
        'monHoc', grade_rows.monHoc,
        'soTc', grade_rows.soTc,
        'diemTong', grade_rows.diemTong,
        'heChu', grade_rows.heChu,
        'diem4', grade_rows.diem4,
        'diemThanhPhan', grade_rows.diemThanhPhan
    )), JSON_ARRAY()) AS mon
    FROM (
        SELECT
            mh.ten AS monHoc,
            mh.sotc AS soTc,
            kqm.diem AS diemTong,
            dhc.ten AS heChu,
            dhc.diem4,
            COALESCE((
                SELECT JSON_ARRAYAGG(JSON_OBJECT(
                    'ten', dd.ten,
                    'tile', mdd.tile,
                    'diem', dtp.diem
                ))
                  FROM MonHoc_DauDiem mdd
                  JOIN DauDiem dd ON dd.id = mdd.daudiem_id
                  LEFT JOIN DiemThanhPhan dtp
                         ON dtp.dangkyhoc_id = dkh.id
                        AND dtp.daudiem_id = dd.id
                 WHERE mdd.monhoc_id = mh.id
            ), JSON_ARRAY()) AS diemThanhPhan
        FROM DangKyHoc dkh
        JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
        JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
        JOIN MonHoc mh ON mh.id = mkh.monhoc_id
        LEFT JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id
        LEFT JOIN DiemHeChu dhc ON dhc.id = kqm.diemhechu_id
        WHERE dkh.sinhvien_id = p_sinhvien_id
          AND dkh.trangthai <> 'Đã hủy'
          AND mkh.kihoc_id = p_kihoc_id
        ORDER BY mh.ten
    ) grade_rows;
END //

CREATE PROCEDURE sp_GetDashboardSinhVien(IN p_sinhvien_id VARCHAR(50))
BEGIN
    SELECT
        TRIM(CONCAT(COALESCE(tv.hodem, ''), ' ', tv.ten)) AS hoten,
        sv.masv AS maSv,
        (
            SELECT ll.ten
              FROM TONGKET_HOCKI tk
              JOIN LoaiHocLuc ll ON ll.id = tk.loaihocluc_id
             WHERE tk.sinhvien_id = p_sinhvien_id
             ORDER BY tk.kihoc_id DESC
             LIMIT 1
        ) AS hocLucCurrent,
        (
            SELECT tk.gpa_he10
              FROM TONGKET_HOCKI tk
             WHERE tk.sinhvien_id = p_sinhvien_id
             ORDER BY tk.kihoc_id DESC
             LIMIT 1
        ) AS gpaCurrent,
        (
            SELECT tk.gpa_he4
              FROM TONGKET_HOCKI tk
             WHERE tk.sinhvien_id = p_sinhvien_id
             ORDER BY tk.kihoc_id DESC
             LIMIT 1
        ) AS gpa4Current,
        COALESCE((
            SELECT SUM(mh.sotc)
              FROM DangKyHoc dkh
              JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
              JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
              JOIN MonHoc mh ON mh.id = mkh.monhoc_id
              JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id
             WHERE dkh.sinhvien_id = p_sinhvien_id
               AND dkh.trangthai <> 'Đã hủy'
               AND kqm.diem >= 4.0
        ), 0) AS tinChiTichLuy,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'kiHocId', h.kihoc_id,
                'tenKi', h.ten_ki,
                'gpa10', h.gpa_he10,
                'gpa4', h.gpa_he4,
                'tongtinchi', h.tongtinchi,
                'sotinchi_dat', h.sotinchi_dat,
                'hocLuc', h.hoc_luc
            ))
              FROM (
                    SELECT *
                      FROM v_TongKet_SinhVien_Dashboard
                     WHERE sinhvien_id = p_sinhvien_id
                     ORDER BY kihoc_id
                   ) h
        ), JSON_ARRAY()) AS history
    FROM SinhVien sv
    JOIN ThanhVien tv ON tv.id = sv.thanhvien_id
    WHERE sv.masv = p_sinhvien_id;
END //

-- =============================================================================
-- 3. TEACHER PROCEDURES
-- =============================================================================

CREATE PROCEDURE sp_GetLopHocPhanGiangVien(
    IN p_giangvien_id INT,
    IN p_kihoc_id INT
)
BEGIN
    SELECT
        lhp.id AS lophocphan_id,
        lhp.ten AS ten_lop,
        mh.id AS monhoc_id,
        mh.ten AS ten_mon_hoc,
        mh.sotc,
        COUNT(DISTINCT CASE WHEN dkh.trangthai <> 'Đã hủy' THEN dkh.id END) AS si_so
    FROM GiangVien_LopHocPhan gvlhp
    JOIN LopHocPhan lhp ON lhp.id = gvlhp.lophocphan_id
    JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
    JOIN MonHoc mh ON mh.id = mkh.monhoc_id
    LEFT JOIN DangKyHoc dkh ON dkh.lophocphan_id = lhp.id
    WHERE gvlhp.giangvien_id = p_giangvien_id
      AND mkh.kihoc_id = p_kihoc_id
    GROUP BY lhp.id, lhp.ten, mh.id, mh.ten, mh.sotc
    ORDER BY mh.ten, lhp.ten;
END //

CREATE PROCEDURE sp_GetTeacherGradeRoster(
    IN p_lophocphan_id INT,
    IN p_giangvien_id INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM GiangVien_LopHocPhan
         WHERE lophocphan_id = p_lophocphan_id
           AND giangvien_id = p_giangvien_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không có quyền';
    END IF;

    SELECT
        lhp.ten AS tenLhp,
        mh.ten AS monHoc,
        mh.sotc AS soTc,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'id', dd.id,
                'ten', dd.ten,
                'tile', mdd.tile
            ))
              FROM MonHoc_DauDiem mdd
              JOIN DauDiem dd ON dd.id = mdd.daudiem_id
             WHERE mdd.monhoc_id = mh.id
        ), JSON_ARRAY()) AS dauDiems,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'maSv', roster.maSv,
                'hoTen', roster.hoTen,
                'dangKyHocId', roster.dangKyHocId,
                'grades', roster.grades,
                'diemTong', roster.diemTong,
                'heChu', roster.heChu
            ))
              FROM (
                    SELECT
                        sv.masv AS maSv,
                        TRIM(CONCAT(COALESCE(tv.hodem, ''), ' ', tv.ten)) AS hoTen,
                        dkh.id AS dangKyHocId,
                        COALESCE((
                            SELECT JSON_OBJECTAGG(dtp.daudiem_id, dtp.diem)
                              FROM DiemThanhPhan dtp
                             WHERE dtp.dangkyhoc_id = dkh.id
                        ), JSON_OBJECT()) AS grades,
                        kqm.diem AS diemTong,
                        dhc.ten AS heChu
                    FROM DangKyHoc dkh
                    JOIN SinhVien sv ON sv.masv = dkh.sinhvien_id
                    JOIN ThanhVien tv ON tv.id = sv.thanhvien_id
                    LEFT JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id
                    LEFT JOIN DiemHeChu dhc ON dhc.id = kqm.diemhechu_id
                    WHERE dkh.lophocphan_id = p_lophocphan_id
                      AND dkh.trangthai <> 'Đã hủy'
                    ORDER BY sv.masv
                   ) roster
        ), JSON_ARRAY()) AS `rows`
    FROM LopHocPhan lhp
    JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
    JOIN MonHoc mh ON mh.id = mkh.monhoc_id
    WHERE lhp.id = p_lophocphan_id;
END //

CREATE PROCEDURE sp_LuuDiemThanhPhan(
    IN p_giangvien_id INT,
    IN p_dangkyhoc_id INT,
    IN p_daudiem_id INT,
    IN p_diem DECIMAL(4,2)
)
BEGIN
    IF p_diem < 0 OR p_diem > 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Điểm không hợp lệ';
    END IF;

    IF EXISTS (SELECT 1 FROM KetQuaMon WHERE dangkyhoc_id = p_dangkyhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Môn học đã chốt điểm';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM DangKyHoc dkh
          JOIN GiangVien_LopHocPhan gvlhp
            ON gvlhp.lophocphan_id = dkh.lophocphan_id
           AND gvlhp.giangvien_id = p_giangvien_id
         WHERE dkh.id = p_dangkyhoc_id
           AND dkh.trangthai <> 'Đã hủy'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không có quyền';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM DangKyHoc dkh
          JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
          JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
          JOIN MonHoc_DauDiem mdd ON mdd.monhoc_id = mkh.monhoc_id
         WHERE dkh.id = p_dangkyhoc_id
           AND mdd.daudiem_id = p_daudiem_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đầu điểm không hợp lệ';
    END IF;

    INSERT INTO DiemThanhPhan(dangkyhoc_id, daudiem_id, diem)
    VALUES (p_dangkyhoc_id, p_daudiem_id, p_diem)
    ON DUPLICATE KEY UPDATE diem = VALUES(diem);
END //

CREATE PROCEDURE sp_ChotDiemMonHoc(
    IN p_lophocphan_id INT,
    IN p_giangvien_id INT
)
BEGIN
    DECLARE v_monhoc_id INT;
    DECLARE v_tile_total DECIMAL(7,4);
    DECLARE v_registered_count INT;
    DECLARE v_missing_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE id = p_lophocphan_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp không tồn tại';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM GiangVien_LopHocPhan
         WHERE lophocphan_id = p_lophocphan_id
           AND giangvien_id = p_giangvien_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không có quyền';
    END IF;

    SELECT mkh.monhoc_id
      INTO v_monhoc_id
      FROM LopHocPhan lhp
      JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
     WHERE lhp.id = p_lophocphan_id;

    SELECT COALESCE(SUM(tile), 0)
      INTO v_tile_total
      FROM MonHoc_DauDiem
     WHERE monhoc_id = v_monhoc_id;

    IF ABS(v_tile_total - 1.0) > 0.001 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tỉ lệ điểm chưa đủ';
    END IF;

    SELECT COUNT(*)
      INTO v_registered_count
      FROM DangKyHoc
     WHERE lophocphan_id = p_lophocphan_id
       AND trangthai <> 'Đã hủy';

    IF v_registered_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không có sinh viên';
    END IF;

    SELECT COUNT(*)
      INTO v_missing_count
      FROM DangKyHoc dkh
      JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
      JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
      JOIN MonHoc_DauDiem mdd ON mdd.monhoc_id = mkh.monhoc_id
      LEFT JOIN DiemThanhPhan dtp
             ON dtp.dangkyhoc_id = dkh.id
            AND dtp.daudiem_id = mdd.daudiem_id
     WHERE dkh.lophocphan_id = p_lophocphan_id
       AND dkh.trangthai <> 'Đã hủy'
       AND dtp.diem IS NULL;

    IF v_missing_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chưa đủ điểm';
    END IF;

    INSERT INTO KetQuaMon(dangkyhoc_id, diem, diemhechu_id)
    SELECT final_score.dangkyhoc_id,
           final_score.diem_tong,
           dhc.id
      FROM (
            SELECT dkh.id AS dangkyhoc_id,
                   ROUND(SUM(dtp.diem * mdd.tile), 2) AS diem_tong
              FROM DangKyHoc dkh
              JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
              JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
              JOIN MonHoc_DauDiem mdd ON mdd.monhoc_id = mkh.monhoc_id
              JOIN DiemThanhPhan dtp
                   ON dtp.dangkyhoc_id = dkh.id
                  AND dtp.daudiem_id = mdd.daudiem_id
             WHERE dkh.lophocphan_id = p_lophocphan_id
               AND dkh.trangthai <> 'Đã hủy'
             GROUP BY dkh.id
           ) final_score
      JOIN DiemHeChu dhc
        ON final_score.diem_tong >= dhc.diem10_min
       AND (
             final_score.diem_tong < dhc.diem10_max
             OR (dhc.diem10_max = 10.0 AND final_score.diem_tong = 10.0)
           )
    ON DUPLICATE KEY UPDATE
        diem = VALUES(diem),
        diemhechu_id = VALUES(diemhechu_id);

    COMMIT;
END //

-- =============================================================================
-- 4. ADMIN PROCEDURES (sp_Admin_ prefix)
-- =============================================================================

-- --- Institutional Structure ---

CREATE PROCEDURE sp_Admin_CreateTruong(IN p_ten VARCHAR(255), IN p_mota VARCHAR(255))
BEGIN
    INSERT INTO Truong(ten, mota) VALUES (p_ten, p_mota);
END //

CREATE PROCEDURE sp_Admin_UpdateTruong(IN p_id INT, IN p_ten VARCHAR(255), IN p_mota VARCHAR(255))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Truong WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    UPDATE Truong SET ten = p_ten, mota = p_mota WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteTruong(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Truong WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM Khoa WHERE truong_id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có dữ liệu phụ thuộc'; END IF;
    DELETE FROM Truong WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_CreateKhoa(IN p_ten VARCHAR(255), IN p_mota VARCHAR(255), IN p_truong_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Truong WHERE id = p_truong_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trường không tồn tại'; END IF;
    INSERT INTO Khoa(ten, mota, truong_id) VALUES (p_ten, p_mota, p_truong_id);
END //

CREATE PROCEDURE sp_Admin_UpdateKhoa(IN p_id INT, IN p_ten VARCHAR(255), IN p_mota VARCHAR(255), IN p_truong_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Khoa WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Truong WHERE id = p_truong_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trường không tồn tại'; END IF;
    UPDATE Khoa SET ten = p_ten, mota = p_mota, truong_id = p_truong_id WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteKhoa(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Khoa WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM BoMon WHERE khoa_id = p_id) OR EXISTS (SELECT 1 FROM NganhHoc WHERE khoa_id = p_id) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có dữ liệu phụ thuộc'; 
    END IF;
    DELETE FROM Khoa WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_CreateBoMon(IN p_ten VARCHAR(255), IN p_mota VARCHAR(255), IN p_khoa_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Khoa WHERE id = p_khoa_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khoa không tồn tại'; END IF;
    INSERT INTO BoMon(ten, mota, khoa_id) VALUES (p_ten, p_mota, p_khoa_id);
END //

CREATE PROCEDURE sp_Admin_UpdateBoMon(IN p_id INT, IN p_ten VARCHAR(255), IN p_mota VARCHAR(255), IN p_khoa_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BoMon WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Khoa WHERE id = p_khoa_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khoa không tồn tại'; END IF;
    UPDATE BoMon SET ten = p_ten, mota = p_mota, khoa_id = p_khoa_id WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteBoMon(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BoMon WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM MonHoc WHERE bomon_id = p_id) OR EXISTS (SELECT 1 FROM GiangVien WHERE bomon_id = p_id) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có dữ liệu phụ thuộc'; 
    END IF;
    DELETE FROM BoMon WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_CreateNganh(IN p_ten VARCHAR(255), IN p_khoa_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Khoa WHERE id = p_khoa_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khoa không tồn tại'; END IF;
    INSERT INTO NganhHoc(ten, khoa_id) VALUES (p_ten, p_khoa_id);
END //

CREATE PROCEDURE sp_Admin_UpdateNganh(IN p_id INT, IN p_ten VARCHAR(255), IN p_khoa_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NganhHoc WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Khoa WHERE id = p_khoa_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khoa không tồn tại'; END IF;
    UPDATE NganhHoc SET ten = p_ten, khoa_id = p_khoa_id WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteNganh(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NganhHoc WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM LopHanhChinh WHERE nganh_id = p_id) OR EXISTS (SELECT 1 FROM NganhHoc_MonHoc WHERE nganh_id = p_id) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có dữ liệu phụ thuộc'; 
    END IF;
    DELETE FROM NganhHoc WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_AssignMonHocNganh(IN p_nganh_id INT, IN p_monhoc_id INT, IN p_loai VARCHAR(50))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NganhHoc WHERE id = p_nganh_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngành không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM MonHoc WHERE id = p_monhoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Môn không tồn tại'; END IF;
    IF p_loai NOT IN ('BB', 'TC') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loại không hợp lệ'; END IF;
    INSERT INTO NganhHoc_MonHoc(nganh_id, monhoc_id, loai) VALUES (p_nganh_id, p_monhoc_id, p_loai)
    ON DUPLICATE KEY UPDATE loai = VALUES(loai);
END //

CREATE PROCEDURE sp_Admin_CreateLopHanhChinh(IN p_tenlop VARCHAR(50), IN p_nganh_id INT)
BEGIN
    IF EXISTS (SELECT 1 FROM LopHanhChinh WHERE tenlop = p_tenlop) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tên lớp đã tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM NganhHoc WHERE id = p_nganh_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngành không tồn tại'; END IF;
    INSERT INTO LopHanhChinh(tenlop, nganh_id) VALUES (p_tenlop, p_nganh_id);
END //

CREATE PROCEDURE sp_Admin_UpdateLopHanhChinh(IN p_id INT, IN p_tenlop VARCHAR(50), IN p_nganh_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM LopHanhChinh WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM LopHanhChinh WHERE tenlop = p_tenlop AND id <> p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tên lớp đã tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM NganhHoc WHERE id = p_nganh_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngành không tồn tại'; END IF;
    UPDATE LopHanhChinh SET tenlop = p_tenlop, nganh_id = p_nganh_id WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteLopHanhChinh(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM LopHanhChinh WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM SinhVien WHERE lophanhchinh_id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp đã có sinh viên'; END IF;
    DELETE FROM LopHanhChinh WHERE id = p_id;
END //

-- --- Academic Catalog ---

CREATE PROCEDURE sp_Admin_CreateMonHoc(
    IN p_mamh VARCHAR(50),
    IN p_ten VARCHAR(255),
    IN p_sotc INT,
    IN p_mota TEXT,
    IN p_bomon_id INT
)
BEGIN
    IF p_mamh IS NULL OR p_mamh = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã môn không rỗng'; END IF;
    IF EXISTS (SELECT 1 FROM MonHoc WHERE mamh = p_mamh) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã môn đã tồn tại'; END IF;
    IF p_ten IS NULL OR p_ten = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tên môn không rỗng'; END IF;
    IF p_sotc <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số tín chỉ phải lớn hơn 0'; END IF;
    IF NOT EXISTS (SELECT 1 FROM BoMon WHERE id = p_bomon_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bộ môn không tồn tại'; END IF;
    INSERT INTO MonHoc(mamh, ten, sotc, mota, bomon_id) VALUES (p_mamh, p_ten, p_sotc, p_mota, p_bomon_id);
END //

CREATE PROCEDURE sp_Admin_UpdateMonHoc(
    IN p_id INT, IN p_mamh VARCHAR(50), IN p_ten VARCHAR(255), IN p_sotc INT, IN p_mota TEXT, IN p_bomon_id INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM MonHoc WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Môn học không tồn tại'; END IF;
    IF p_mamh IS NULL OR p_mamh = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã môn không rỗng'; END IF;
    IF EXISTS (SELECT 1 FROM MonHoc WHERE mamh = p_mamh AND id <> p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã môn đã tồn tại'; END IF;
    IF p_ten IS NULL OR p_ten = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tên môn không rỗng'; END IF;
    IF p_sotc <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số tín chỉ phải lớn hơn 0'; END IF;
    IF NOT EXISTS (SELECT 1 FROM BoMon WHERE id = p_bomon_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bộ môn không tồn tại'; END IF;

    UPDATE MonHoc SET mamh = p_mamh, ten = p_ten, sotc = p_sotc, mota = p_mota, bomon_id = p_bomon_id WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteMonHoc(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM MonHoc WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM NganhHoc_MonHoc WHERE monhoc_id = p_id) OR EXISTS (SELECT 1 FROM MonHoc_KiHoc WHERE monhoc_id = p_id) OR EXISTS (SELECT 1 FROM MonHoc_DauDiem WHERE monhoc_id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có dữ liệu học vụ';
    END IF;
    DELETE FROM MonHoc WHERE id = p_id;
END //

-- --- Time & Schedule ---

CREATE PROCEDURE sp_Admin_CreateNamHoc(IN p_ten VARCHAR(50))
BEGIN
    IF EXISTS (SELECT 1 FROM NamHoc WHERE ten = p_ten) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Năm học đã tồn tại'; END IF;
    INSERT INTO NamHoc(ten) VALUES (p_ten);
END //

CREATE PROCEDURE sp_Admin_UpdateNamHoc(IN p_id INT, IN p_ten VARCHAR(50))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NamHoc WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM NamHoc WHERE ten = p_ten AND id <> p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Năm học đã tồn tại'; END IF;
    UPDATE NamHoc SET ten = p_ten WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteNamHoc(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NamHoc WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM KiHoc WHERE namhoc_id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có kỳ học thuộc năm này'; END IF;
    DELETE FROM NamHoc WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_CreateHocKi(IN p_ten VARCHAR(50))
BEGIN
    IF EXISTS (SELECT 1 FROM HocKi WHERE ten = p_ten) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Học kỳ đã tồn tại'; END IF;
    INSERT INTO HocKi(ten) VALUES (p_ten);
END //

CREATE PROCEDURE sp_Admin_UpdateHocKi(IN p_id INT, IN p_ten VARCHAR(50))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM HocKi WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM HocKi WHERE ten = p_ten AND id <> p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Học kỳ đã tồn tại'; END IF;
    UPDATE HocKi SET ten = p_ten WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteHocKi(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM HocKi WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM KiHoc WHERE hocki_id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có kỳ học thuộc học kỳ này'; END IF;
    DELETE FROM HocKi WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_CreateKiHoc(IN p_namhoc_id INT, IN p_hocki_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NamHoc WHERE id = p_namhoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Năm học không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM HocKi WHERE id = p_hocki_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Học kỳ không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM KiHoc WHERE namhoc_id = p_namhoc_id AND hocki_id = p_hocki_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kỳ học đã tồn tại'; END IF;
    INSERT INTO KiHoc(namhoc_id, hocki_id) VALUES (p_namhoc_id, p_hocki_id);
END //

CREATE PROCEDURE sp_Admin_DeleteKiHoc(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM KiHoc WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM MonHoc_KiHoc WHERE kihoc_id = p_id) OR EXISTS (SELECT 1 FROM TONGKET_HOCKI WHERE kihoc_id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có dữ liệu học vụ';
    END IF;
    DELETE FROM KiHoc WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_AssignMonHocKiHoc(IN p_kihoc_id INT, IN p_monhoc_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM KiHoc WHERE id = p_kihoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kỳ học không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM MonHoc WHERE id = p_monhoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Môn không tồn tại'; END IF;
    INSERT IGNORE INTO MonHoc_KiHoc(kihoc_id, monhoc_id) VALUES (p_kihoc_id, p_monhoc_id);
END //

CREATE PROCEDURE sp_Admin_CreateLopHocPhan(
    IN p_ten VARCHAR(255), IN p_nhom INT, IN p_tothuchanh INT, IN p_sisotoida INT, IN p_monhockihoc_id INT
)
BEGIN
    IF p_ten IS NULL OR p_ten = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tên lớp không rỗng'; END IF;
    IF p_sisotoida <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sĩ số phải lớn hơn 0'; END IF;
    IF NOT EXISTS (SELECT 1 FROM MonHoc_KiHoc WHERE id = p_monhockihoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Môn học - Kỳ học không tồn tại'; END IF;
    INSERT INTO LopHocPhan(ten, nhom, tothuchanh, sisotoida, monhockihoc_id) VALUES (p_ten, p_nhom, p_tothuchanh, p_sisotoida, p_monhockihoc_id);
END //

CREATE PROCEDURE sp_Admin_UpdateLopHocPhan(
    IN p_id INT, IN p_ten VARCHAR(255), IN p_nhom INT, IN p_tothuchanh INT, IN p_sisotoida INT, IN p_monhockihoc_id INT
)
BEGIN
    DECLARE v_sisohientai INT;
    DECLARE v_old_mk_id INT;

    IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp không tồn tại'; END IF;
    IF p_sisotoida <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sĩ số phải lớn hơn 0'; END IF;

    SELECT monhockihoc_id INTO v_old_mk_id FROM LopHocPhan WHERE id = p_id;
    SELECT COUNT(*) INTO v_sisohientai FROM DangKyHoc WHERE lophocphan_id = p_id AND trangthai <> 'Đã hủy';

    IF v_old_mk_id <> p_monhockihoc_id AND v_sisohientai > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể đổi môn/kỳ khi đã có đăng ký'; END IF;
    IF p_sisotoida < v_sisohientai THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sĩ số mới nhỏ hơn số SV đang đăng ký'; END IF;

    UPDATE LopHocPhan SET ten = p_ten, nhom = p_nhom, tothuchanh = p_tothuchanh, sisotoida = p_sisotoida, monhockihoc_id = p_monhockihoc_id WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_DeleteLopHocPhan(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM DangKyHoc WHERE lophocphan_id = p_id) OR EXISTS (SELECT 1 FROM BuoiHoc WHERE lophocphan_id = p_id) OR EXISTS (SELECT 1 FROM GiangVien_LopHocPhan WHERE lophocphan_id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có dữ liệu phụ thuộc';
    END IF;
    DELETE FROM LopHocPhan WHERE id = p_id;
END //

CREATE PROCEDURE sp_Admin_AssignGiangVienLopHocPhan(IN p_giangvien_id INT, IN p_lophocphan_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM GiangVien WHERE thanhvien_id = p_giangvien_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giảng viên không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE id = p_lophocphan_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM GiangVien_LopHocPhan WHERE giangvien_id = p_giangvien_id AND lophocphan_id = p_lophocphan_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã phân công'; END IF;
    INSERT INTO GiangVien_LopHocPhan(giangvien_id, lophocphan_id) VALUES (p_giangvien_id, p_lophocphan_id);
END //

CREATE PROCEDURE sp_Admin_UnassignGiangVienLopHocPhan(IN p_giangvien_id INT, IN p_lophocphan_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM GiangVien_LopHocPhan WHERE giangvien_id = p_giangvien_id AND lophocphan_id = p_lophocphan_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM BuoiHoc WHERE giangvien_id = p_giangvien_id AND lophocphan_id = p_lophocphan_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đang xếp lịch buổi học'; END IF;
    DELETE FROM GiangVien_LopHocPhan WHERE giangvien_id = p_giangvien_id AND lophocphan_id = p_lophocphan_id;
END //

CREATE PROCEDURE sp_Admin_CreateBuoiHoc(
    IN p_lophocphan_id INT, IN p_tuan_id INT, IN p_ngay_id INT, IN p_kiphoc_id INT, IN p_phonghoc_id INT, IN p_giangvien_id INT
)
BEGIN
    DECLARE v_lhp_siso INT;
    DECLARE v_phong_succhua INT;

    IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE id = p_lophocphan_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM GiangVien_LopHocPhan WHERE lophocphan_id = p_lophocphan_id AND giangvien_id = p_giangvien_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giảng viên chưa được phân công cho lớp này'; END IF;

    SELECT sisotoida INTO v_lhp_siso FROM LopHocPhan WHERE id = p_lophocphan_id;
    SELECT succhua INTO v_phong_succhua FROM PhongHoc WHERE id = p_phonghoc_id;

    IF v_phong_succhua < v_lhp_siso THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sức chứa phòng không đủ cho sĩ số lớp'; END IF;
    IF EXISTS (SELECT 1 FROM BuoiHoc WHERE tuan_id = p_tuan_id AND ngay_id = p_ngay_id AND kiphoc_id = p_kiphoc_id AND phonghoc_id = p_phonghoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng phòng'; END IF;
    IF EXISTS (SELECT 1 FROM BuoiHoc WHERE tuan_id = p_tuan_id AND ngay_id = p_ngay_id AND kiphoc_id = p_kiphoc_id AND giangvien_id = p_giangvien_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng lịch giảng viên'; END IF;

    INSERT INTO BuoiHoc(lophocphan_id, tuan_id, ngay_id, kiphoc_id, phonghoc_id, giangvien_id) VALUES (p_lophocphan_id, p_tuan_id, p_ngay_id, p_kiphoc_id, p_phonghoc_id, p_giangvien_id);
END //

CREATE PROCEDURE sp_Admin_DeleteBuoiHoc(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BuoiHoc WHERE id = p_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tồn tại'; END IF;
    IF EXISTS (SELECT 1 FROM BuoiHoc bh JOIN DangKyHoc dkh ON dkh.lophocphan_id = bh.lophocphan_id WHERE bh.id = p_id AND dkh.trangthai <> 'Đã hủy') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp đã có sinh viên đăng ký';
    END IF;
    DELETE FROM BuoiHoc WHERE id = p_id;
END //

-- --- Grade Configuration ---

CREATE PROCEDURE sp_Admin_AssignMonHocDauDiem(IN p_monhoc_id INT, IN p_daudiem_id INT, IN p_tile DECIMAL(5,4))
BEGIN
    DECLARE v_current_total DECIMAL(5,4);
    DECLARE v_old_tile DECIMAL(5,4);

    IF NOT EXISTS (SELECT 1 FROM MonHoc WHERE id = p_monhoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Môn học không tồn tại'; END IF;
    IF NOT EXISTS (SELECT 1 FROM DauDiem WHERE id = p_daudiem_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đầu điểm không tồn tại'; END IF;
    IF p_tile <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tỉ lệ phải lớn hơn 0'; END IF;

    IF EXISTS (SELECT 1 FROM MonHoc_KiHoc mkh JOIN LopHocPhan lhp ON lhp.monhockihoc_id = mkh.id JOIN DangKyHoc dkh ON dkh.lophocphan_id = lhp.id JOIN (SELECT dangkyhoc_id FROM DiemThanhPhan UNION SELECT dangkyhoc_id FROM KetQuaMon) g ON g.dangkyhoc_id = dkh.id WHERE mkh.monhoc_id = p_monhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Môn đã có điểm hoặc kết quả, không thể sửa cấu hình';
    END IF;

    SELECT COALESCE(SUM(tile), 0) INTO v_current_total FROM MonHoc_DauDiem WHERE monhoc_id = p_monhoc_id;
    SELECT COALESCE((SELECT tile FROM MonHoc_DauDiem WHERE monhoc_id = p_monhoc_id AND daudiem_id = p_daudiem_id), 0) INTO v_old_tile;
    IF v_current_total - v_old_tile + p_tile > 1.0001 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tổng tỉ lệ vượt quá 1.0'; END IF;

    INSERT INTO MonHoc_DauDiem(monhoc_id, daudiem_id, tile) VALUES (p_monhoc_id, p_daudiem_id, p_tile) ON DUPLICATE KEY UPDATE tile = VALUES(tile);
END //

CREATE PROCEDURE sp_Admin_DeleteMonHocDauDiem(IN p_monhoc_id INT, IN p_daudiem_id INT)
BEGIN
    IF EXISTS (SELECT 1 FROM MonHoc_KiHoc mkh JOIN LopHocPhan lhp ON lhp.monhockihoc_id = mkh.id JOIN DangKyHoc dkh ON dkh.lophocphan_id = lhp.id JOIN (SELECT dangkyhoc_id FROM DiemThanhPhan UNION SELECT dangkyhoc_id FROM KetQuaMon) g ON g.dangkyhoc_id = dkh.id WHERE mkh.monhoc_id = p_monhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Môn đã có điểm hoặc kết quả, không thể sửa cấu hình';
    END IF;
    DELETE FROM MonHoc_DauDiem WHERE monhoc_id = p_monhoc_id AND daudiem_id = p_daudiem_id;
END //

-- =============================================================================
-- 5. REPORT & FINALIZATION PROCEDURES
-- =============================================================================

CREATE PROCEDURE sp_GetBaoCaoHocLuc(IN p_kihoc_id INT)
BEGIN
    SELECT
        (SELECT CONCAT(nh.ten, ' - ', hk.ten) FROM KiHoc ki JOIN NamHoc nh ON nh.id = ki.namhoc_id JOIN HocKi hk ON hk.id = ki.hocki_id WHERE ki.id = p_kihoc_id) AS kiHocTen,
        COALESCE((SELECT JSON_ARRAYAGG(JSON_OBJECT('loaiHocLuc', p.loai_hoc_luc, 'soLuong', p.so_luong)) FROM v_PhanBo_HocLuc p WHERE p.kihoc_id = p_kihoc_id), JSON_ARRAY()) AS phanBo,
        COALESCE((SELECT JSON_ARRAYAGG(JSON_OBJECT('maSv', b.masv, 'hoTen', b.ho_ten, 'gpa10', b.gpa_he10, 'gpa4', b.gpa_he4, 'tcDat', b.sotinchi_dat, 'tongTc', b.tongtinchi, 'hocLuc', b.hoc_luc)) FROM (SELECT * FROM v_BaoCao_HocLuc_ChiTiet WHERE kihoc_id = p_kihoc_id ORDER BY gpa_he4 DESC, masv) b), JSON_ARRAY()) AS sinhVien;
END //

CREATE PROCEDURE sp_TongKetHocKy(IN p_kihoc_id INT)
BEGIN
    DECLARE v_missing_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM KiHoc WHERE id = p_kihoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kỳ không tồn tại'; END IF;

    SELECT COUNT(*) INTO v_missing_count FROM DangKyHoc dkh JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id LEFT JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id WHERE mkh.kihoc_id = p_kihoc_id AND dkh.trangthai <> 'Đã hủy' AND kqm.id IS NULL;
    IF v_missing_count > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chưa chốt điểm hết các lớp'; END IF;

    INSERT INTO TONGKET_HOCKI(sinhvien_id, kihoc_id, gpa_he10, gpa_he4, tongtinchi, sotinchi_dat, loaihocluc_id)
    SELECT g.sinhvien_id, g.kihoc_id, g.gpa_he10, g.gpa_he4, g.tongtinchi, g.sotinchi_dat, ll.id
      FROM (SELECT dkh.sinhvien_id, p_kihoc_id AS kihoc_id, ROUND(SUM(kqm.diem * mh.sotc) / SUM(mh.sotc), 2) AS gpa_he10, ROUND(SUM(dhc.diem4 * mh.sotc) / SUM(mh.sotc), 2) AS gpa_he4, SUM(mh.sotc) AS tongtinchi, SUM(CASE WHEN kqm.diem >= 4.0 THEN mh.sotc ELSE 0 END) AS sotinchi_dat FROM DangKyHoc dkh JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id JOIN MonHoc mh ON mh.id = mkh.monhoc_id JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id JOIN DiemHeChu dhc ON dhc.id = kqm.diemhechu_id WHERE mkh.kihoc_id = p_kihoc_id AND dkh.trangthai <> 'Đã hủy' GROUP BY dkh.sinhvien_id) g
      JOIN LoaiHocLuc ll ON g.gpa_he4 >= ll.diem_min AND (g.gpa_he4 < ll.diem_max OR (ll.diem_max = 4.0 AND g.gpa_he4 = 4.0))
    ON DUPLICATE KEY UPDATE gpa_he10 = VALUES(gpa_he10), gpa_he4 = VALUES(gpa_he4), tongtinchi = VALUES(tongtinchi), sotinchi_dat = VALUES(sotinchi_dat), loaihocluc_id = VALUES(loaihocluc_id), created_at = CURRENT_TIMESTAMP;

    COMMIT;
END //

DELIMITER ;
