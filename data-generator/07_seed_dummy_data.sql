USE SinhVien;
SET NAMES utf8mb4;

INSERT INTO Truong(id, ten, mota) VALUES
    (1, 'Học viện Công nghệ Bưu chính Viễn thông', 'PTIT');

INSERT INTO DiaChi(id, tinhthanh, truong_id) VALUES
    (1, 'Hà Nội', 1),
    (2, 'TP. Hồ Chí Minh', 1);

INSERT INTO Khoa(id, ten, mota, truong_id) VALUES
    (1, 'Khoa Công nghệ thông tin 1', 'Khoa CNTT', 1);

INSERT INTO BoMon(id, ten, mota, khoa_id) VALUES
    (1, 'Bộ môn Công nghệ phần mềm', 'CNPM', 1);

INSERT INTO NganhHoc(id, ten, khoa_id) VALUES
    (1, 'Công nghệ thông tin', 1);

INSERT INTO LopHanhChinh(id, tenlop, nganh_id) VALUES
    (1, 'D23CQCE06-B', 1);

INSERT INTO ThanhVien(id, username, password, hodem, ten, ngaysinh, email, dt, vaitro, diachi_id) VALUES
    (1, 'admin', '123456', 'Quản trị', 'Viên', '1990-01-01', 'admin@ptit.edu.vn', '0900000001', 'ADMIN', 1),
    (2, 'gv_test', '123456', 'Nguyễn Văn', 'Minh', '1985-02-02', 'gv_test@ptit.edu.vn', '0900000002', 'GV', 1),
    (3, 'gv_test2', '123456', 'Trần Thị', 'Lan', '1986-03-03', 'gv_test2@ptit.edu.vn', '0900000003', 'GV', 1),
    (4, 'sv_test', '123456', 'Chu Tuyết', 'Nhi', '2005-04-04', 'sv_test@ptit.edu.vn', '0900000004', 'SV', 1),
    (5, 'sv_full_1', '123456', 'Nguyễn', 'An', '2005-05-05', 'sv_full_1@ptit.edu.vn', '0900000005', 'SV', 1),
    (6, 'sv_full_2', '123456', 'Lê', 'Bình', '2005-06-06', 'sv_full_2@ptit.edu.vn', '0900000006', 'SV', 1);

INSERT INTO GiangVien(thanhvien_id, bomon_id, hocham) VALUES
    (2, 1, 'Thạc sĩ'),
    (3, 1, 'Thạc sĩ');

INSERT INTO SinhVien(masv, thanhvien_id, lophanhchinh_id) VALUES
    ('B23DCCE075', 4, 1),
    ('B23DCCE076', 5, 1),
    ('B23DCCE077', 6, 1);

INSERT INTO SinhVien_Nganh(sinhvien_id, nganh_id) VALUES
    ('B23DCCE075', 1),
    ('B23DCCE076', 1),
    ('B23DCCE077', 1);

INSERT INTO MonHoc(id, mamh, ten, sotc, mota, bomon_id) VALUES
    (1, 'INT1306', 'Cơ sở dữ liệu', 3, 'Môn học về mô hình dữ liệu và SQL', 1),
    (2, 'INT1339', 'Lập trình Java', 3, 'Môn học lập trình Java', 1),
    (3, 'INT1404', 'Mạng máy tính', 3, 'Môn học mạng máy tính', 1);

INSERT INTO NganhHoc_MonHoc(nganh_id, monhoc_id, loai) VALUES
    (1, 1, 'BB'),
    (1, 2, 'BB'),
    (1, 3, 'TC');

INSERT INTO MonHoc_DauDiem(monhoc_id, daudiem_id, tile) VALUES
    (1, 1, 0.10), (1, 3, 0.30), (1, 5, 0.60),
    (2, 1, 0.10), (2, 2, 0.20), (2, 3, 0.20), (2, 5, 0.50),
    (3, 1, 0.10), (3, 3, 0.30), (3, 5, 0.60);

INSERT INTO NamHoc(id, ten) VALUES
    (1, '2024-2025'),
    (2, '2025-2026');

INSERT INTO HocKi(id, ten) VALUES
    (1, 'HK1'),
    (2, 'HK2');

INSERT INTO KiHoc(id, namhoc_id, hocki_id) VALUES
    (1, 1, 1),
    (2, 2, 2);

INSERT INTO MonHoc_KiHoc(id, monhoc_id, kihoc_id) VALUES
    (1, 1, 1),
    (2, 2, 2),
    (3, 1, 2),
    (4, 3, 2);

INSERT INTO LopHocPhan(id, ten, nhom, tothuchanh, sisotoida, monhockihoc_id) VALUES
    (1, 'CSDL-01-2024', 1, NULL, 30, 1),
    (2, 'JAVA-01-2025', 1, NULL, 30, 2),
    (3, 'CSDL-02-2025', 2, NULL, 30, 3),
    (4, 'MMT-01-2025', 1, NULL, 2, 4),
    (5, 'MMT-02-2025', 2, NULL, 30, 4);

INSERT INTO GiangVien_LopHocPhan(giangvien_id, lophocphan_id) VALUES
    (2, 1),
    (2, 2),
    (2, 3),
    (3, 4),
    (3, 5);

INSERT INTO PhongHoc(id, ten, succhua) VALUES
    (1, 'A2-101', 60),
    (2, 'A2-102', 60),
    (3, 'A3-201', 40);

INSERT INTO BuoiHoc(id, lophocphan_id, tuan_id, ngay_id, kiphoc_id, phonghoc_id, giangvien_id) VALUES
    (1, 1, 1, 4, 2, 1, 2),
    (2, 2, 1, 1, 1, 1, 2),
    (3, 3, 1, 2, 2, 2, 2),
    (4, 4, 1, 3, 3, 3, 3),
    (5, 5, 1, 1, 1, 2, 3);

INSERT INTO DangKyHoc(id, ngaydangky, trangthai, sinhvien_id, lophocphan_id) VALUES
    (1, '2024-09-01 08:00:00', 'Đã lưu', 'B23DCCE075', 1),
    (2, '2026-02-01 08:00:00', 'Đã lưu', 'B23DCCE075', 2),
    (3, '2026-02-01 08:05:00', 'Đã lưu', 'B23DCCE076', 4),
    (4, '2026-02-01 08:10:00', 'Đã lưu', 'B23DCCE077', 4);

INSERT INTO DiemThanhPhan(dangkyhoc_id, daudiem_id, diem) VALUES
    (1, 1, 9.0), (1, 3, 8.5), (1, 5, 8.5),
    (2, 1, 9.0), (2, 2, 8.0), (2, 3, 8.0), (2, 5, 8.5),
    (3, 1, 7.0), (3, 3, 7.0), (3, 5, 7.0),
    (4, 1, 6.0), (4, 3, 6.0), (4, 5, 6.0);

CALL sp_ChotDiemMonHoc(1, 2);
CALL sp_TongKetHocKy(1);
CALL sp_ChotDiemMonHoc(4, 3);
