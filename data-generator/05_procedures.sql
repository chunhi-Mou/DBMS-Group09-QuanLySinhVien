USE SinhVien;

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

DELIMITER //


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

    INSERT INTO DangKyHoc(ngaydangky, trangthai, sinhvien_id, lophocphan_id)
    VALUES (NOW(), 'Đã lưu', p_sinhvien_id, p_lophocphan_id);

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

    DELETE FROM DangKyHoc WHERE id = p_dangkyhoc_id;

    COMMIT;
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

CREATE PROCEDURE sp_TongKetHocKy(IN p_kihoc_id INT)
BEGIN
    DECLARE v_missing_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM KiHoc WHERE id = p_kihoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kỳ không tồn tại';
    END IF;

    SELECT COUNT(*)
      INTO v_missing_count
      FROM DangKyHoc dkh
      JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
      JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
      LEFT JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id
     WHERE mkh.kihoc_id = p_kihoc_id
       AND dkh.trangthai <> 'Đã hủy'
       AND kqm.id IS NULL;

    IF v_missing_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chưa chốt điểm';
    END IF;

    INSERT INTO TONGKET_HOCKI(
        sinhvien_id, kihoc_id, gpa_he10, gpa_he4,
        tongtinchi, sotinchi_dat, loaihocluc_id
    )
    SELECT g.sinhvien_id,
           g.kihoc_id,
           g.gpa_he10,
           g.gpa_he4,
           g.tongtinchi,
           g.sotinchi_dat,
           ll.id
      FROM (
            SELECT dkh.sinhvien_id,
                   p_kihoc_id AS kihoc_id,
                   ROUND(SUM(kqm.diem * mh.sotc) / SUM(mh.sotc), 2) AS gpa_he10,
                   ROUND(SUM(dhc.diem4 * mh.sotc) / SUM(mh.sotc), 2) AS gpa_he4,
                   SUM(mh.sotc) AS tongtinchi,
                   SUM(CASE WHEN kqm.diem >= 4.0 THEN mh.sotc ELSE 0 END) AS sotinchi_dat
              FROM DangKyHoc dkh
              JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
              JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
              JOIN MonHoc mh ON mh.id = mkh.monhoc_id
              JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id
              JOIN DiemHeChu dhc ON dhc.id = kqm.diemhechu_id
             WHERE mkh.kihoc_id = p_kihoc_id
               AND dkh.trangthai <> 'Đã hủy'
             GROUP BY dkh.sinhvien_id
           ) g
      JOIN LoaiHocLuc ll
        ON g.gpa_he4 >= ll.diem_min
       AND (
             g.gpa_he4 < ll.diem_max
             OR (ll.diem_max = 4.0 AND g.gpa_he4 = 4.0)
           )
    ON DUPLICATE KEY UPDATE
        gpa_he10 = VALUES(gpa_he10),
        gpa_he4 = VALUES(gpa_he4),
        tongtinchi = VALUES(tongtinchi),
        sotinchi_dat = VALUES(sotinchi_dat),
        loaihocluc_id = VALUES(loaihocluc_id),
        created_at = CURRENT_TIMESTAMP;

    COMMIT;
END //

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

CREATE PROCEDURE sp_GetBaoCaoHocLuc(IN p_kihoc_id INT)
BEGIN
    SELECT
        (
            SELECT CONCAT(nh.ten, ' - ', hk.ten)
              FROM KiHoc ki
              JOIN NamHoc nh ON nh.id = ki.namhoc_id
              JOIN HocKi hk ON hk.id = ki.hocki_id
             WHERE ki.id = p_kihoc_id
        ) AS kiHocTen,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'loaiHocLuc', p.loai_hoc_luc,
                'soLuong', p.so_luong
            ))
              FROM v_PhanBo_HocLuc p
             WHERE p.kihoc_id = p_kihoc_id
        ), JSON_ARRAY()) AS phanBo,
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
                'maSv', b.masv,
                'hoTen', b.ho_ten,
                'gpa10', b.gpa_he10,
                'gpa4', b.gpa_he4,
                'tcDat', b.sotinchi_dat,
                'tongTc', b.tongtinchi,
                'hocLuc', b.hoc_luc
            ))
              FROM (
                    SELECT *
                      FROM v_BaoCao_HocLuc_ChiTiet
                     WHERE kihoc_id = p_kihoc_id
                     ORDER BY gpa_he4 DESC, masv
                   ) b
        ), JSON_ARRAY()) AS sinhVien;
END //

DELIMITER ;
