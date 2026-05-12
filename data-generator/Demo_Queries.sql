/* DEMO QUERIES - Quản lý Sinh viên */

USE SinhVien;

/* === DEMO 1: Tổng quan hệ thống === */

-- 1.1: Thống kê tổng quan
SELECT 
    'Tổng số sinh viên' AS thong_ke,
    COUNT(*) AS so_luong
FROM SinhVien
UNION ALL
SELECT 
    'Tổng số giảng viên',
    COUNT(*)
FROM GiangVien
UNION ALL
SELECT 
    'Tổng số môn học',
    COUNT(*)
FROM MonHoc
UNION ALL
SELECT 
    'Tổng số lớp học phần',
    COUNT(*)
FROM LopHocPhan
UNION ALL
SELECT 
    'Tổng số khoa',
    COUNT(*)
FROM Khoa;

-- 1.2: Số sinh viên theo khoa
SELECT 
    kh.ten AS ten_khoa,
    COUNT(DISTINCT sn.sinhvien_id) AS so_sinh_vien,
    COUNT(DISTINCT ng.id) AS so_nganh_hoc
FROM Khoa kh
LEFT JOIN NganhHoc ng ON kh.id = ng.khoa_id
LEFT JOIN SinhVien_Nganh sn ON ng.id = sn.nganh_id
GROUP BY kh.id, kh.ten
ORDER BY so_sinh_vien DESC;

-- 1.3: Top 5 môn hot nhất
SELECT 
    mh.mamh,
    mh.ten AS ten_mon_hoc,
    mh.sotc AS so_tin_chi,
    COUNT(DISTINCT dkh.sinhvien_id) AS so_sinh_vien_dang_ky,
    COUNT(DISTINCT lhp.id) AS so_lop_hoc_phan
FROM MonHoc mh
JOIN MonHoc_KiHoc mkh ON mh.id = mkh.monhoc_id
JOIN LopHocPhan lhp ON mkh.id = lhp.monhockihoc_id
JOIN DangKyHoc dkh ON lhp.id = dkh.lophocphan_id
GROUP BY mh.id, mh.mamh, mh.ten, mh.sotc
ORDER BY so_sinh_vien_dang_ky DESC
LIMIT 5;


/* === DEMO 2: Thông tin sinh viên === */

-- 2.1: Thông tin 1 sinh viên
SELECT 
    sv.masv,
    CONCAT(tv.hodem, ' ', tv.ten) AS ho_ten,
    tv.ngaysinh,
    tv.email,
    tv.dt AS dien_thoai,
    lhc.tenlop AS lop_hanh_chinh,
    ng.ten AS nganh_hoc,
    kh.ten AS khoa
FROM SinhVien sv
JOIN ThanhVien tv ON sv.thanhvien_id = tv.id
LEFT JOIN LopHanhChinh lhc ON sv.lophanhchinh_id = lhc.id
LEFT JOIN SinhVien_Nganh sn ON sv.masv = sn.sinhvien_id
LEFT JOIN NganhHoc ng ON sn.nganh_id = ng.id
LEFT JOIN Khoa kh ON ng.khoa_id = kh.id
LIMIT 1;

-- 2.2: Lịch học trong kỳ
SELECT 
    th.ten AS tuan,
    nh.ten AS ngay,
    kh.ten AS kip,
    v.ten_mon_hoc AS mon_hoc,
    v.ten_lop AS lop_hoc_phan,
    v.phong_hoc,
    v.giang_vien
FROM v_ThoiKhoaBieu_SinhVien v
JOIN TuanHoc th ON v.tuan_id = th.id
JOIN NgayHoc nh ON v.ngay_id = nh.id
JOIN KipHoc kh ON v.kiphoc_id = kh.id
WHERE v.sinhvien_id = (SELECT masv FROM SinhVien LIMIT 1)
  AND v.kihoc_id = (SELECT MAX(id) FROM KiHoc)
ORDER BY th.id, nh.id, kh.id;

-- 2.3: Bảng điểm
SELECT 
    mh.mamh,
    mh.ten AS mon_hoc,
    mh.sotc AS tin_chi,
    ROUND(kqm.diem, 2) AS diem_so,
    dhc.ten AS diem_chu,
    CASE 
        WHEN kqm.diem >= 4 THEN 'Đạt'
        ELSE 'Không đạt'
    END AS ket_qua,
    CONCAT(nh.ten, ' - ', hk.ten) AS hoc_ky
FROM DangKyHoc dkh
JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN MonHoc mh ON mkh.monhoc_id = mh.id
JOIN KiHoc k ON mkh.kihoc_id = k.id
JOIN NamHoc nh ON k.namhoc_id = nh.id
JOIN HocKi hk ON k.hocki_id = hk.id
LEFT JOIN KetQuaMon kqm ON dkh.id = kqm.dangkyhoc_id
LEFT JOIN DiemHeChu dhc ON kqm.diemhechu_id = dhc.id
WHERE dkh.sinhvien_id = (SELECT masv FROM SinhVien LIMIT 1)
ORDER BY k.id DESC, mh.ten;


/* === DEMO 3: Thống kê & báo cáo === */

-- 3.1: Kết quả học tập theo kỳ
SELECT 
    CONCAT(nh.ten, ' - ', hk.ten) AS hoc_ky,
    COUNT(DISTINCT tkh.sinhvien_id) AS tong_sinh_vien,
    ROUND(AVG(tkh.gpa_he10), 2) AS gpa_trung_binh_he10,
    ROUND(AVG(tkh.gpa_he4), 2) AS gpa_trung_binh_he4,
    ROUND(AVG(tkh.tongtinchi), 2) AS trung_binh_tin_chi,
    ROUND(AVG(tkh.sotinchi_dat), 2) AS trung_binh_tin_chi_dat
FROM TONGKET_HOCKI tkh
JOIN KiHoc k ON tkh.kihoc_id = k.id
JOIN NamHoc nh ON k.namhoc_id = nh.id
JOIN HocKi hk ON k.hocki_id = hk.id
WHERE k.id = (SELECT MAX(id) FROM KiHoc)
GROUP BY k.id, nh.ten, hk.ten;

-- 3.2: Phân bố xếp loại học lực
SELECT 
    lhl.ten AS xep_loai_hoc_luc,
    COUNT(*) AS so_luong_sinh_vien,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) 
        FROM TONGKET_HOCKI 
        WHERE kihoc_id = (SELECT MAX(id) FROM KiHoc)
    ), 2) AS ty_le_phan_tram
FROM TONGKET_HOCKI tkh
JOIN LoaiHocLuc lhl ON tkh.loaihocluc_id = lhl.id
WHERE tkh.kihoc_id = (SELECT MAX(id) FROM KiHoc)
GROUP BY lhl.id, lhl.ten
ORDER BY lhl.diem_min DESC;

-- 3.3: Top 10 sinh viên GPA cao nhất
SELECT 
    sv.masv,
    CONCAT(tv.hodem, ' ', tv.ten) AS ho_ten,
    lhc.tenlop AS lop,
    ng.ten AS nganh,
    ROUND(tkh.gpa_he10, 2) AS gpa_he10,
    ROUND(tkh.gpa_he4, 2) AS gpa_he4,
    lhl.ten AS xep_loai
FROM TONGKET_HOCKI tkh
JOIN SinhVien sv ON tkh.sinhvien_id = sv.masv
JOIN ThanhVien tv ON sv.thanhvien_id = tv.id
LEFT JOIN LopHanhChinh lhc ON sv.lophanhchinh_id = lhc.id
LEFT JOIN SinhVien_Nganh sn ON sv.masv = sn.sinhvien_id
LEFT JOIN NganhHoc ng ON sn.nganh_id = ng.id
LEFT JOIN LoaiHocLuc lhl ON tkh.loaihocluc_id = lhl.id
WHERE tkh.kihoc_id = (SELECT MAX(id) FROM KiHoc)
ORDER BY tkh.gpa_he4 DESC
LIMIT 10;

-- 3.4: Tỷ lệ đạt/trượt theo môn
SELECT 
    mh.mamh,
    mh.ten AS mon_hoc,
    COUNT(kqm.id) AS tong_sinh_vien,
    SUM(CASE WHEN kqm.diem >= 4 THEN 1 ELSE 0 END) AS so_sv_dat,
    SUM(CASE WHEN kqm.diem < 4 THEN 1 ELSE 0 END) AS so_sv_truot,
    ROUND(SUM(CASE WHEN kqm.diem >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(kqm.id), 2) AS ty_le_dat,
    ROUND(AVG(kqm.diem), 2) AS diem_trung_binh
FROM KetQuaMon kqm
JOIN DangKyHoc dkh ON kqm.dangkyhoc_id = dkh.id
JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN MonHoc mh ON mkh.monhoc_id = mh.id
WHERE mkh.kihoc_id = (SELECT MAX(id) FROM KiHoc)
GROUP BY mh.id, mh.mamh, mh.ten
HAVING COUNT(kqm.id) > 0
ORDER BY ty_le_dat ASC, so_sv_truot DESC
LIMIT 10;

-- 3.5: Lịch giảng dạy của giảng viên
SELECT 
    CONCAT(tv.hodem, ' ', tv.ten) AS giang_vien,
    bm.ten AS bo_mon,
    COUNT(DISTINCT lhp.id) AS so_lop_day,
    COUNT(DISTINCT bh.id) AS so_buoi_day,
    COUNT(DISTINCT dkh.sinhvien_id) AS tong_sinh_vien
FROM GiangVien gv
JOIN ThanhVien tv ON gv.thanhvien_id = tv.id
LEFT JOIN BoMon bm ON gv.bomon_id = bm.id
LEFT JOIN BuoiHoc bh ON gv.thanhvien_id = bh.giangvien_id
LEFT JOIN LopHocPhan lhp ON bh.lophocphan_id = lhp.id
LEFT JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
LEFT JOIN DangKyHoc dkh ON lhp.id = dkh.lophocphan_id
WHERE mkh.kihoc_id = (SELECT MAX(id) FROM KiHoc)
   OR mkh.kihoc_id IS NULL
GROUP BY gv.thanhvien_id, tv.hodem, tv.ten, bm.ten
HAVING so_lop_day > 0
ORDER BY so_lop_day DESC, tong_sinh_vien DESC
LIMIT 10;

-- 3.6: Thống kê sử dụng phòng học
SELECT 
    ph.ten AS phong_hoc,
    ph.succhua AS suc_chua,
    COUNT(DISTINCT bh.id) AS so_buoi_su_dung,
    COUNT(DISTINCT lhp.id) AS so_lop_hoc_phan,
    ROUND(COUNT(DISTINCT bh.id) * 100.0 / (
        SELECT COUNT(*) * (SELECT COUNT(*) FROM TuanHoc) * (SELECT COUNT(*) FROM NgayHoc) * (SELECT COUNT(*) FROM KipHoc)
        FROM PhongHoc
        WHERE id = ph.id
    ), 2) AS ty_le_su_dung
FROM PhongHoc ph
LEFT JOIN BuoiHoc bh ON ph.id = bh.phonghoc_id
LEFT JOIN LopHocPhan lhp ON bh.lophocphan_id = lhp.id
LEFT JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
WHERE mkh.kihoc_id = (SELECT MAX(id) FROM KiHoc)
   OR mkh.kihoc_id IS NULL
GROUP BY ph.id, ph.ten, ph.succhua
ORDER BY so_buoi_su_dung DESC
LIMIT 10;


/* === DEMO 4: Kiểm tra dữ liệu === */

-- 4.1: Sinh viên có lịch trùng
SELECT 
    sv.masv,
    CONCAT(tv.hodem, ' ', tv.ten) AS ho_ten,
    th.ten AS tuan,
    nh.ten AS ngay,
    kh.ten AS kip,
    COUNT(*) AS so_mon_trung_lich
FROM DangKyHoc dkh
JOIN SinhVien sv ON dkh.sinhvien_id = sv.masv
JOIN ThanhVien tv ON sv.thanhvien_id = tv.id
JOIN BuoiHoc bh ON dkh.lophocphan_id = bh.lophocphan_id
JOIN TuanHoc th ON bh.tuan_id = th.id
JOIN NgayHoc nh ON bh.ngay_id = nh.id
JOIN KipHoc kh ON bh.kiphoc_id = kh.id
GROUP BY sv.masv, tv.hodem, tv.ten, th.id, th.ten, nh.id, nh.ten, kh.id, kh.ten
HAVING COUNT(*) > 1
ORDER BY so_mon_trung_lich DESC;

-- 4.2: Lớp vượt sĩ số
SELECT 
    lophocphan_id AS id,
    ten_lop AS lop_hoc_phan,
    ten_mon_hoc AS mon_hoc,
    sisotoida AS si_so_toi_da,
    sisohientai AS si_so_hien_tai,
    sisohientai - sisotoida AS vuot_si_so
FROM v_ThongTin_LopHocPhan
WHERE sisohientai > sisotoida
ORDER BY vuot_si_so DESC;

-- 4.3: Sinh viên chưa có điểm
SELECT 
    sv.masv,
    CONCAT(tv.hodem, ' ', tv.ten) AS ho_ten,
    mh.ten AS mon_hoc,
    lhp.ten AS lop_hoc_phan,
    dkh.ngaydangky
FROM DangKyHoc dkh
JOIN SinhVien sv ON dkh.sinhvien_id = sv.masv
JOIN ThanhVien tv ON sv.thanhvien_id = tv.id
JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN MonHoc mh ON mkh.monhoc_id = mh.id
LEFT JOIN KetQuaMon kqm ON dkh.id = kqm.dangkyhoc_id
WHERE kqm.id IS NULL
  AND mkh.kihoc_id = (SELECT MAX(id) FROM KiHoc)
ORDER BY sv.masv, mh.ten
LIMIT 20;


/* === DEMO 5: Tìm kiếm === */

-- 5.1: Tìm sinh viên theo tên
SELECT 
    sv.masv,
    CONCAT(tv.hodem, ' ', tv.ten) AS ho_ten,
    tv.email,
    lhc.tenlop AS lop,
    ng.ten AS nganh
FROM SinhVien sv
JOIN ThanhVien tv ON sv.thanhvien_id = tv.id
LEFT JOIN LopHanhChinh lhc ON sv.lophanhchinh_id = lhc.id
LEFT JOIN SinhVien_Nganh sn ON sv.masv = sn.sinhvien_id
LEFT JOIN NganhHoc ng ON sn.nganh_id = ng.id
WHERE CONCAT(tv.hodem, ' ', tv.ten) LIKE CONCAT('%', 
    (SELECT SUBSTRING(ten, 1, 1) FROM ThanhVien WHERE vaitro = 'STUDENT' LIMIT 1), 
    '%')
LIMIT 10;

-- 5.2: Lớp còn chỗ trống
SELECT 
    lophocphan_id AS id,
    ten_lop AS lop_hoc_phan,
    mamh,
    ten_mon_hoc AS mon_hoc,
    sotc AS tin_chi,
    sisotoida AS si_so_toi_da,
    sisohientai AS si_so_hien_tai,
    sisotoida - sisohientai AS con_trong
FROM v_ThongTin_LopHocPhan
WHERE kihoc_id = (SELECT MAX(id) FROM KiHoc)
  AND sisohientai < sisotoida
ORDER BY con_trong DESC
LIMIT 10;

-- 6.1: Hiển thị các Stored Procedures
SHOW PROCEDURE STATUS WHERE Db = 'sinhvien';

SHOW CREATE PROCEDURE sp_DangKyHoc;

-- 6.3: Hiển thị các Triggers chống trùng lịch / đầy sĩ số
SHOW TRIGGERS FROM sinhvien;

-- 6.4: Hiển thị các Views đã tạo
SHOW FULL TABLES IN sinhvien WHERE TABLE_TYPE LIKE 'VIEW';

-- 6.5: Kiểm tra các Indexes tối ưu tốc độ tra cứu
SHOW INDEX FROM DangKyHoc;
SHOW INDEX FROM BuoiHoc;

-- 5.3: Lịch trống của phòng học
SELECT 
    ph.ten AS phong_hoc,
    th.ten AS tuan,
    nh.ten AS ngay,
    kh.ten AS kip,
    'Trống' AS trang_thai
FROM PhongHoc ph
CROSS JOIN TuanHoc th
CROSS JOIN NgayHoc nh
CROSS JOIN KipHoc kh
WHERE NOT EXISTS (
    SELECT 1
    FROM BuoiHoc bh
    WHERE bh.phonghoc_id = ph.id
      AND bh.tuan_id = th.id
      AND bh.ngay_id = nh.id
      AND bh.kiphoc_id = kh.id
)
ORDER BY ph.ten, th.id, nh.id, kh.id
LIMIT 20;
