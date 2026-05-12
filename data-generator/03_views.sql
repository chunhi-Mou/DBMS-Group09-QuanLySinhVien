USE SinhVien;
SET NAMES utf8mb4;

DROP VIEW IF EXISTS v_BaoCao_HocLuc_ChiTiet;
DROP VIEW IF EXISTS v_NhapDiem_GiangVien;
DROP VIEW IF EXISTS v_PhanBo_HocLuc;
DROP VIEW IF EXISTS v_TongKet_SinhVien_Dashboard;
DROP VIEW IF EXISTS v_DiemThanhPhan_ChiTiet;
DROP VIEW IF EXISTS v_BangDiem_SinhVien;
DROP VIEW IF EXISTS v_LopHocPhan_ThongTinDayDu;

CREATE VIEW v_LopHocPhan_ThongTinDayDu AS
SELECT
    lhp.id AS lophocphan_id,
    lhp.ten AS ten_lop,
    lhp.nhom,
    lhp.tothuchanh,
    lhp.sisotoida,
    COUNT(DISTINCT CASE WHEN dkh.trangthai <> 'Đã hủy' THEN dkh.id END) AS sisohientai,
    lhp.sisotoida - COUNT(DISTINCT CASE WHEN dkh.trangthai <> 'Đã hủy' THEN dkh.id END) AS cho_trong,
    CASE
        WHEN COUNT(DISTINCT CASE WHEN dkh.trangthai <> 'Đã hủy' THEN dkh.id END) >= lhp.sisotoida
        THEN 1 ELSE 0
    END AS da_day,
    mh.id AS monhoc_id,
    mh.mamh,
    mh.ten AS ten_mon_hoc,
    mh.sotc,
    mkh.kihoc_id,
    GROUP_CONCAT(
        DISTINCT TRIM(CONCAT(COALESCE(tv.hodem, ''), ' ', tv.ten))
        ORDER BY tv.ten SEPARATOR '; '
    ) AS giang_vien
FROM LopHocPhan lhp
JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
JOIN MonHoc mh ON mh.id = mkh.monhoc_id
LEFT JOIN DangKyHoc dkh ON dkh.lophocphan_id = lhp.id
LEFT JOIN GiangVien_LopHocPhan gvlhp ON gvlhp.lophocphan_id = lhp.id
LEFT JOIN GiangVien gv ON gv.thanhvien_id = gvlhp.giangvien_id
LEFT JOIN ThanhVien tv ON tv.id = gv.thanhvien_id
GROUP BY
    lhp.id, lhp.ten, lhp.nhom, lhp.tothuchanh, lhp.sisotoida,
    mh.id, mh.mamh, mh.ten, mh.sotc, mkh.kihoc_id;

CREATE VIEW v_BangDiem_SinhVien AS
SELECT
    dkh.sinhvien_id,
    mkh.kihoc_id,
    mh.id AS monhoc_id,
    mh.mamh,
    mh.ten AS ten_mon_hoc,
    mh.sotc,
    kqm.diem AS diem_tong,
    dhc.ten AS diem_chu,
    dhc.diem4,
    CASE WHEN kqm.diem >= 4.0 THEN 1 ELSE 0 END AS da_dat
FROM DangKyHoc dkh
JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
JOIN MonHoc mh ON mh.id = mkh.monhoc_id
LEFT JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id
LEFT JOIN DiemHeChu dhc ON dhc.id = kqm.diemhechu_id
WHERE dkh.trangthai <> 'Đã hủy';

CREATE VIEW v_DiemThanhPhan_ChiTiet AS
SELECT
    dkh.id AS dangkyhoc_id,
    dkh.sinhvien_id,
    lhp.id AS lophocphan_id,
    dd.id AS daudiem_id,
    dd.ten AS ten_daudiem,
    mdd.tile,
    dtp.diem,
    ROUND(dtp.diem * mdd.tile, 4) AS diem_co_trong_so
FROM DangKyHoc dkh
JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id
JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
JOIN MonHoc_DauDiem mdd ON mdd.monhoc_id = mkh.monhoc_id
JOIN DauDiem dd ON dd.id = mdd.daudiem_id
LEFT JOIN DiemThanhPhan dtp
    ON dtp.dangkyhoc_id = dkh.id
   AND dtp.daudiem_id = dd.id
WHERE dkh.trangthai <> 'Đã hủy';

CREATE VIEW v_TongKet_SinhVien_Dashboard AS
SELECT
    tk.sinhvien_id,
    tk.kihoc_id,
    CONCAT(nh.ten, ' - ', hk.ten) AS ten_ki,
    tk.gpa_he10,
    tk.gpa_he4,
    tk.tongtinchi,
    tk.sotinchi_dat,
    ll.ten AS hoc_luc
FROM TONGKET_HOCKI tk
JOIN KiHoc ki ON ki.id = tk.kihoc_id
JOIN NamHoc nh ON nh.id = ki.namhoc_id
JOIN HocKi hk ON hk.id = ki.hocki_id
LEFT JOIN LoaiHocLuc ll ON ll.id = tk.loaihocluc_id;

CREATE VIEW v_PhanBo_HocLuc AS
SELECT
    tk.kihoc_id,
    ll.ten AS loai_hoc_luc,
    COUNT(tk.id) AS so_luong
FROM TONGKET_HOCKI tk
JOIN LoaiHocLuc ll ON ll.id = tk.loaihocluc_id
GROUP BY tk.kihoc_id, ll.id, ll.ten;

CREATE VIEW v_NhapDiem_GiangVien AS
SELECT
    gvlhp.giangvien_id,
    tv_gv.username AS username_gv,
    lhp.id AS lophocphan_id,
    lhp.ten AS ten_lop,
    mh.id AS monhoc_id,
    mh.ten AS ten_mon_hoc,
    mh.sotc,
    mkh.kihoc_id,
    dkh.id AS dangkyhoc_id,
    dkh.sinhvien_id,
    TRIM(CONCAT(COALESCE(tv_sv.hodem, ''), ' ', tv_sv.ten)) AS ho_ten_sv,
    kqm.diem AS diem_tong,
    dhc.ten AS diem_chu
FROM GiangVien_LopHocPhan gvlhp
JOIN LopHocPhan lhp ON lhp.id = gvlhp.lophocphan_id
JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id
JOIN MonHoc mh ON mh.id = mkh.monhoc_id
JOIN GiangVien gv ON gv.thanhvien_id = gvlhp.giangvien_id
JOIN ThanhVien tv_gv ON tv_gv.id = gv.thanhvien_id
LEFT JOIN DangKyHoc dkh
    ON dkh.lophocphan_id = lhp.id
   AND dkh.trangthai <> 'Đã hủy'
LEFT JOIN SinhVien sv ON sv.masv = dkh.sinhvien_id
LEFT JOIN ThanhVien tv_sv ON tv_sv.id = sv.thanhvien_id
LEFT JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh.id
LEFT JOIN DiemHeChu dhc ON dhc.id = kqm.diemhechu_id;

CREATE VIEW v_BaoCao_HocLuc_ChiTiet AS
SELECT
    tk.kihoc_id,
    CONCAT(nh.ten, ' - ', hk.ten) AS ten_ki,
    sv.masv,
    TRIM(CONCAT(COALESCE(tv.hodem, ''), ' ', tv.ten)) AS ho_ten,
    lhc.tenlop AS ten_lop_hanh_chinh,
    ngh.ten AS ten_nganh,
    tk.gpa_he10,
    tk.gpa_he4,
    tk.tongtinchi,
    tk.sotinchi_dat,
    ll.ten AS hoc_luc
FROM TONGKET_HOCKI tk
JOIN KiHoc ki ON ki.id = tk.kihoc_id
JOIN NamHoc nh ON nh.id = ki.namhoc_id
JOIN HocKi hk ON hk.id = ki.hocki_id
JOIN SinhVien sv ON sv.masv = tk.sinhvien_id
JOIN ThanhVien tv ON tv.id = sv.thanhvien_id
LEFT JOIN LopHanhChinh lhc ON lhc.id = sv.lophanhchinh_id
LEFT JOIN NganhHoc ngh ON ngh.id = lhc.nganh_id
LEFT JOIN LoaiHocLuc ll ON ll.id = tk.loaihocluc_id;
