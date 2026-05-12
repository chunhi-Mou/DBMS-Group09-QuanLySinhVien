/* TRIGGER: CHỐNG TRÙNG LỊCH ĐĂNG KÝ HỌC */
DELIMITER //
CREATE TRIGGER trg_check_sv_lich
BEFORE INSERT ON DangKyHoc
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM   DangKyHoc dkh
        JOIN   BuoiHoc   bh_cu  ON bh_cu.lophocphan_id  = dkh.lophocphan_id
        JOIN   BuoiHoc   bh_moi ON bh_moi.lophocphan_id = NEW.lophocphan_id
            AND bh_moi.tuan_id   = bh_cu.tuan_id
            AND bh_moi.ngay_id   = bh_cu.ngay_id
            AND bh_moi.kiphoc_id = bh_cu.kiphoc_id
        WHERE  dkh.sinhvien_id = NEW.sinhvien_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sinh viên đã có lịch học trùng vào khung giờ này';
    END IF;
END //
DELIMITER ;

/* Lấy danh sách Lớp học phần đang mở cho đăng ký */
SELECT lhp.id,
       lhp.ten,
       lhp.sisotoida,
       COUNT(dkh.id)  AS sisohientai,
       mh.ten         AS mon_hoc,
       mh.sotc
FROM   LopHocPhan    lhp
JOIN   MonHoc_KiHoc  mkh ON lhp.monhockihoc_id = mkh.id
JOIN   MonHoc         mh ON mkh.monhoc_id       = mh.id
LEFT   JOIN DangKyHoc dkh ON dkh.lophocphan_id  = lhp.id
WHERE  mkh.kihoc_id = :kihocId
  AND  mkh.monhoc_id IN (
       SELECT nm.monhoc_id
       FROM   NganhHoc_MonHoc nm
       JOIN   SinhVien_Nganh  sn ON nm.nganh_id = sn.nganh_id
       WHERE  sn.sinhvien_id = :masv
  )
GROUP  BY lhp.id, lhp.ten, lhp.sisotoida, mh.ten, mh.sotc;

/* Kiểm tra môn học đã pass chưa */
SELECT dkh.lophocphan_id
FROM   DangKyHoc    dkh
JOIN   LopHocPhan   lhp ON dkh.lophocphan_id   = lhp.id
JOIN   MonHoc_KiHoc mkh ON lhp.monhockihoc_id  = mkh.id
JOIN   KetQuaMon    kqm ON dkh.id              = kqm.dangkyhoc_id
WHERE  dkh.sinhvien_id = :masv
  AND  mkh.monhoc_id   = :monhocId
  AND  kqm.diem       >= 4;

/* Lấy thời khóa biểu Sinh viên */
SELECT b.tuan_id, b.ngay_id, b.kiphoc_id,
       ph.ten  AS phong,
       mh.ten  AS mon_hoc,
       lhp.ten AS lop,
       CONCAT(tv.hodem, ' ', tv.ten) AS giang_vien
FROM   BuoiHoc      b
JOIN   LopHocPhan   lhp ON b.lophocphan_id    = lhp.id
JOIN   MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN   MonHoc        mh ON mkh.monhoc_id       = mh.id
JOIN   PhongHoc      ph ON b.phonghoc_id       = ph.id
JOIN   GiangVien     gv ON b.giangvien_id      = gv.thanhvien_id
JOIN   ThanhVien     tv ON gv.thanhvien_id     = tv.id
WHERE  lhp.id IN (
       SELECT dkh.lophocphan_id
       FROM   DangKyHoc dkh
       WHERE  dkh.sinhvien_id = :masv
         AND  mkh.kihoc_id    = :kihocId
);

/* Lấy thời khóa biểu Giảng viên */
SELECT b.tuan_id, b.ngay_id, b.kiphoc_id,
       ph.ten  AS phong,
       mh.ten  AS mon_hoc,
       lhp.ten AS lop,
       CONCAT(tv.hodem, ' ', tv.ten) AS giang_vien
FROM   BuoiHoc      b
JOIN   LopHocPhan   lhp ON b.lophocphan_id    = lhp.id
JOIN   MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN   MonHoc        mh ON mkh.monhoc_id       = mh.id
JOIN   PhongHoc      ph ON b.phonghoc_id       = ph.id
JOIN   GiangVien     gv ON b.giangvien_id      = gv.thanhvien_id
JOIN   ThanhVien     tv ON gv.thanhvien_id     = tv.id
WHERE b.giangvien_id = :giangvienId
AND mkh.kihoc_id = :kihocId;

/* Tính điểm tổng kết trung bình môn học */
SELECT SUM(dtp.diem * mdd.tile) AS diem_tong
FROM   DiemThanhPhan  dtp
JOIN   MonHoc_DauDiem mdd
    ON dtp.daudiem_id  = mdd.daudiem_id
   AND mdd.monhoc_id   = :monhocId
WHERE  dtp.dangkyhoc_id = :dangkyhocId;

/* Áp điểm hệ 10 sang Điểm Chữ */
SELECT id, ten, diem4
FROM   DiemHeChu
WHERE  :diemTong BETWEEN diem10_min AND diem10_max
LIMIT  1;

/* Tính GPA và Tổng kết học kỳ của Sinh viên */
SELECT
    SUM(kqm.diem  * mh.sotc) / SUM(mh.sotc) AS gpa_he10,
    SUM(dhc.diem4 * mh.sotc) / SUM(mh.sotc) AS gpa_he4,
    SUM(mh.sotc)                             AS tong_tinchi,
    SUM(CASE WHEN kqm.diem >= 4
             THEN mh.sotc ELSE 0 END)        AS tinchi_dat
FROM   DangKyHoc    dkh
JOIN   LopHocPhan   lhp ON dkh.lophocphan_id  = lhp.id
JOIN   MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN   MonHoc        mh ON mkh.monhoc_id       = mh.id
JOIN   KetQuaMon    kqm ON dkh.id             = kqm.dangkyhoc_id
JOIN   DiemHeChu    dhc ON kqm.diemhechu_id   = dhc.id
WHERE  dkh.sinhvien_id = :masv
  AND  mkh.kihoc_id    = :kihocId;

/* Biểu đồ: Trend GPA trung bình toàn trường theo các kỳ */
SELECT t.kihoc_id                          AS ki_id,
       CONCAT(nh.ten, ' - ', hk.ten)       AS ten_ki,
       AVG(t.gpa_he4)                      AS gpa_tb
FROM   TONGKET_HOCKI t
JOIN   KiHoc          k  ON t.kihoc_id   = k.id
JOIN   NamHoc        nh  ON k.namhoc_id  = nh.id
JOIN   HocKi         hk  ON k.hocki_id   = hk.id
GROUP  BY t.kihoc_id, nh.ten, hk.ten
ORDER  BY t.kihoc_id;

/* Biểu đồ: Thống kê số lượng Sinh viên theo Khoa */
SELECT kh.ten             AS khoa,
       COUNT(sn.sinhvien_id) AS so_sinhvien
FROM   SinhVien_Nganh sn
JOIN   NganhHoc       ng ON sn.nganh_id  = ng.id
JOIN   Khoa           kh ON ng.khoa_id   = kh.id
GROUP  BY kh.ten;

/* Biểu đồ: Tỉ lệ xếp loại Học lực */
SELECT lhl.ten  AS loai_hoc_luc,
       COUNT(*) AS so_luong
FROM   TONGKET_HOCKI tkh
JOIN   LoaiHocLuc    lhl ON tkh.loaihocluc_id = lhl.id
WHERE  tkh.kihoc_id = :kihocId
GROUP  BY lhl.ten;

/* Biểu đồ: Top 10 môn học có tỉ lệ trượt cao nhất */
SELECT mh.ten             AS mon_hoc,
       COUNT(kqm.id)      AS tong_sv,
       SUM(CASE WHEN kqm.diem < 4
                THEN 1 ELSE 0 END) AS so_truot
FROM   KetQuaMon    kqm
JOIN   DangKyHoc   dkh ON kqm.dangkyhoc_id    = dkh.id
JOIN   LopHocPhan  lhp ON dkh.lophocphan_id   = lhp.id
JOIN   MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN   MonHoc       mh ON mkh.monhoc_id        = mh.id
GROUP  BY mh.ten
ORDER  BY so_truot * 1.0 / tong_sv DESC
LIMIT 10;
