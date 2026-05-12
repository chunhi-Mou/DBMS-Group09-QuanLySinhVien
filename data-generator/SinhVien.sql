-- Schema: Quản lý Đăng ký tín chỉ và Điểm Sinh viên

CREATE DATABASE IF NOT EXISTS SinhVien
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE SinhVien;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS
    TONGKET_HOCKI,
    LoaiHocLuc,
    KetQuaMon,
    DiemHeChu,
    DiemThanhPhan,
    DangKyHoc,
    BuoiHoc,
    GiangVien_LopHocPhan,
    LopHocPhan,
    MonHoc_KiHoc,
    KiHoc,
    HocKi,
    NamHoc,
    MonHoc_DauDiem,
    DauDiem,
    NganhHoc_MonHoc,
    MonHoc,
    SinhVien_Nganh,
    NhanVien,
    GiangVien,
    SinhVien,
    LopHanhChinh,
    ThanhVien,
    BoMon,
    NganhHoc,
    Khoa,
    Truong,
    DiaChi,
    PhongHoc,
    TuanHoc,
    NgayHoc,
    KipHoc;

SET FOREIGN_KEY_CHECKS = 1;

-- TẦNG 1: CƠ SỞ VẬT CHẤT & ĐỊA LÝ

-- 1. Trường
CREATE TABLE Truong (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    ten  VARCHAR(255),
    mota VARCHAR(255)
);

-- 2. Địa chỉ
CREATE TABLE DiaChi (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    sonha     VARCHAR(255),
    toanha    VARCHAR(255),
    xompho    VARCHAR(255),
    phuongxa  VARCHAR(255),
    quanhuyen VARCHAR(255),
    tinhthanh VARCHAR(255),
    truong_id INT,
    FOREIGN KEY (truong_id) REFERENCES Truong(id)
);

-- TẦNG 2: CƠ CẤU TỔ CHỨC

-- 3. Khoa
CREATE TABLE Khoa (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    ten       VARCHAR(255),
    mota      VARCHAR(255),
    truong_id INT,
    FOREIGN KEY (truong_id) REFERENCES Truong(id)
);

-- 4. Bộ môn
CREATE TABLE BoMon (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    ten     VARCHAR(255),
    mota    VARCHAR(255),
    khoa_id INT,
    FOREIGN KEY (khoa_id) REFERENCES Khoa(id)
);

-- 5. Ngành học
CREATE TABLE NganhHoc (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    ten     VARCHAR(255),
    khoa_id INT,
    FOREIGN KEY (khoa_id) REFERENCES Khoa(id)
);

-- 6. Lớp hành chính
CREATE TABLE LopHanhChinh (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    tenlop   VARCHAR(50) UNIQUE,
    nganh_id INT,
    FOREIGN KEY (nganh_id) REFERENCES NganhHoc(id)
);

-- TẦNG 3: NGƯỜI DÙNG HỆ THỐNG

-- 7. Thành viên
CREATE TABLE ThanhVien (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    username  VARCHAR(255) NOT NULL UNIQUE,
    password  VARCHAR(255) NOT NULL,
    hodem     VARCHAR(255),
    ten       VARCHAR(255) NOT NULL,
    ngaysinh  DATE,
    email     VARCHAR(255) NOT NULL UNIQUE,
    dt        VARCHAR(50),
    vaitro    VARCHAR(50)  NOT NULL,
    diachi_id INT,
    FOREIGN KEY (diachi_id) REFERENCES DiaChi(id),
    CONSTRAINT chk_thanhvien_vaitro CHECK (vaitro IN ('ADMIN', 'GV', 'SV', 'NV'))
);

-- 8. Sinh viên
CREATE TABLE SinhVien (
    masv            VARCHAR(50) PRIMARY KEY,
    thanhvien_id    INT UNIQUE,
    lophanhchinh_id INT,
    FOREIGN KEY (thanhvien_id)    REFERENCES ThanhVien(id),
    FOREIGN KEY (lophanhchinh_id) REFERENCES LopHanhChinh(id)
);

-- 9. Giảng viên
CREATE TABLE GiangVien (
    thanhvien_id INT PRIMARY KEY,
    bomon_id     INT,
    hocham       VARCHAR(50),
    FOREIGN KEY (thanhvien_id) REFERENCES ThanhVien(id),
    FOREIGN KEY (bomon_id)     REFERENCES BoMon(id)
);

-- 10. Nhân viên
CREATE TABLE NhanVien (
    thanhvien_id INT PRIMARY KEY,
    vitri        VARCHAR(255),
    FOREIGN KEY (thanhvien_id) REFERENCES ThanhVien(id)
);

-- TẦNG 4: CHƯƠNG TRÌNH ĐÀO TẠO

-- 11. Sinh viên - Ngành học
CREATE TABLE SinhVien_Nganh (
    sinhvien_id VARCHAR(50),
    nganh_id    INT,
    PRIMARY KEY (sinhvien_id, nganh_id),
    FOREIGN KEY (sinhvien_id) REFERENCES SinhVien(masv),
    FOREIGN KEY (nganh_id)    REFERENCES NganhHoc(id)
);

-- 12. Môn học
CREATE TABLE MonHoc (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    mamh     VARCHAR(50) NOT NULL UNIQUE,
    ten      VARCHAR(255) NOT NULL,
    sotc     INT NOT NULL CHECK (sotc > 0),
    mota     TEXT,
    bomon_id INT,
    FOREIGN KEY (bomon_id) REFERENCES BoMon(id)
);

-- 13. Ngành học - Môn học
CREATE TABLE NganhHoc_MonHoc (
    nganh_id  INT,
    monhoc_id INT,
    loai      VARCHAR(50) NOT NULL,
    PRIMARY KEY (nganh_id, monhoc_id),
    FOREIGN KEY (nganh_id)  REFERENCES NganhHoc(id),
    FOREIGN KEY (monhoc_id) REFERENCES MonHoc(id),
    CONSTRAINT chk_nganhhoc_monhoc_loai CHECK (loai IN ('BB', 'TC'))
);

-- 14. Đầu điểm
CREATE TABLE DauDiem (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    ten  VARCHAR(50) NOT NULL,
    mota VARCHAR(255)
);

-- 15. Môn học - Đầu điểm
CREATE TABLE MonHoc_DauDiem (
    monhoc_id  INT,
    daudiem_id INT,
    tile       DECIMAL(5,4) NOT NULL,
    PRIMARY KEY (monhoc_id, daudiem_id),
    FOREIGN KEY (monhoc_id)  REFERENCES MonHoc(id),
    FOREIGN KEY (daudiem_id) REFERENCES DauDiem(id),
    CONSTRAINT chk_monhoc_daudiem_tile CHECK (tile > 0 AND tile <= 1)
);

-- TẦNG 5: THỜI GIAN VÀ XẾP LỊCH

-- 16. Năm học
CREATE TABLE NamHoc (
    id  INT AUTO_INCREMENT PRIMARY KEY,
    ten VARCHAR(50)
);

-- 17. Học kỳ
CREATE TABLE HocKi (
    id  INT AUTO_INCREMENT PRIMARY KEY,
    ten VARCHAR(50)
);

-- 18. Kỳ học
CREATE TABLE KiHoc (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    namhoc_id INT NOT NULL,
    hocki_id  INT NOT NULL,
    FOREIGN KEY (namhoc_id) REFERENCES NamHoc(id),
    FOREIGN KEY (hocki_id)  REFERENCES HocKi(id),
    CONSTRAINT uq_kihoc_namhoc_hocki UNIQUE (namhoc_id, hocki_id)
);

-- 19. Môn học - Kỳ học
CREATE TABLE MonHoc_KiHoc (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    monhoc_id INT,
    kihoc_id  INT,
    UNIQUE (monhoc_id, kihoc_id),
    FOREIGN KEY (monhoc_id) REFERENCES MonHoc(id),
    FOREIGN KEY (kihoc_id)  REFERENCES KiHoc(id)
);

-- 20. Lớp học phần
CREATE TABLE LopHocPhan (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    ten            VARCHAR(255) NOT NULL,
    nhom           INT,
    tothuchanh     INT,
    sisotoida      INT NOT NULL CHECK (sisotoida > 0),
    monhockihoc_id INT NOT NULL,
    FOREIGN KEY (monhockihoc_id) REFERENCES MonHoc_KiHoc(id)
);

-- 21. Giảng viên - Lớp học phần
CREATE TABLE GiangVien_LopHocPhan (
    giangvien_id  INT,
    lophocphan_id INT,
    PRIMARY KEY (giangvien_id, lophocphan_id),
    FOREIGN KEY (giangvien_id)  REFERENCES GiangVien(thanhvien_id),
    FOREIGN KEY (lophocphan_id) REFERENCES LopHocPhan(id)
);

-- 22. Tuần học
CREATE TABLE TuanHoc (
    id  INT AUTO_INCREMENT PRIMARY KEY,
    ten VARCHAR(50)
);

-- 23. Ngày học
CREATE TABLE NgayHoc (
    id  INT AUTO_INCREMENT PRIMARY KEY,
    ten VARCHAR(50)
);

-- 24. Kíp học
CREATE TABLE KipHoc (
    id  INT AUTO_INCREMENT PRIMARY KEY,
    ten VARCHAR(50)
);

-- 25. Phòng học
CREATE TABLE PhongHoc (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    ten     VARCHAR(255) NOT NULL,
    succhua INT NOT NULL,
    CONSTRAINT chk_phonghoc_succhua CHECK (succhua > 0)
);

-- 26. Buổi học (Lịch)
CREATE TABLE BuoiHoc (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    lophocphan_id INT NOT NULL,
    tuan_id       INT NOT NULL,
    ngay_id       INT NOT NULL,
    kiphoc_id     INT NOT NULL,
    phonghoc_id   INT NOT NULL,
    giangvien_id  INT NOT NULL,
    FOREIGN KEY (lophocphan_id) REFERENCES LopHocPhan(id),
    FOREIGN KEY (tuan_id)       REFERENCES TuanHoc(id),
    FOREIGN KEY (ngay_id)       REFERENCES NgayHoc(id),
    FOREIGN KEY (kiphoc_id)     REFERENCES KipHoc(id),
    FOREIGN KEY (phonghoc_id)   REFERENCES PhongHoc(id),
    FOREIGN KEY (giangvien_id)  REFERENCES GiangVien(thanhvien_id),

    UNIQUE (tuan_id, ngay_id, kiphoc_id, phonghoc_id),
    UNIQUE (tuan_id, ngay_id, kiphoc_id, giangvien_id)
);

-- TẦNG 6: KẾT QUẢ HỌC TẬP

-- 27. Đăng ký học
CREATE TABLE DangKyHoc (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    ngaydangky    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    trangthai     VARCHAR(50) NOT NULL DEFAULT 'Đã lưu',
    sinhvien_id   VARCHAR(50) NOT NULL,
    lophocphan_id INT         NOT NULL,
    UNIQUE (sinhvien_id, lophocphan_id),
    FOREIGN KEY (sinhvien_id)   REFERENCES SinhVien(masv),
    FOREIGN KEY (lophocphan_id) REFERENCES LopHocPhan(id),
    CONSTRAINT chk_dangkyhoc_trangthai CHECK (trangthai IN ('Đã lưu', 'Đã khóa', 'Chờ duyệt', 'Đã hủy'))
);

-- 28. Điểm thành phần
CREATE TABLE DiemThanhPhan (
    dangkyhoc_id INT NOT NULL,
    daudiem_id   INT NOT NULL,
    diem         DECIMAL(4,2) NOT NULL CHECK (diem >= 0 AND diem <= 10),
    PRIMARY KEY (dangkyhoc_id, daudiem_id),
    FOREIGN KEY (dangkyhoc_id) REFERENCES DangKyHoc(id),
    FOREIGN KEY (daudiem_id)   REFERENCES DauDiem(id)
);

-- 29. Điểm hệ chữ
CREATE TABLE DiemHeChu (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    ten        VARCHAR(5)   NOT NULL,
    diem4      DECIMAL(4,2) NOT NULL,
    diem10_min DECIMAL(4,2) NOT NULL,
    diem10_max DECIMAL(4,2) NOT NULL,
    mota       VARCHAR(255),
    CONSTRAINT chk_diemhechu_diem4  CHECK (diem4 >= 0 AND diem4 <= 4),
    CONSTRAINT chk_diemhechu_range  CHECK (diem10_min >= 0 AND diem10_max <= 10 AND diem10_min < diem10_max)
);

-- 30. Kết quả môn
CREATE TABLE KetQuaMon (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    dangkyhoc_id INT          NOT NULL UNIQUE,
    diem         DECIMAL(4,2) NOT NULL CHECK (diem >= 0 AND diem <= 10),
    diemhechu_id INT          NOT NULL,
    FOREIGN KEY (dangkyhoc_id) REFERENCES DangKyHoc(id),
    FOREIGN KEY (diemhechu_id) REFERENCES DiemHeChu(id)
);

-- 31. Loại học lực
CREATE TABLE LoaiHocLuc (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    ten      VARCHAR(50)  NOT NULL,
    diem_min DECIMAL(4,2) NOT NULL,
    diem_max DECIMAL(4,2) NOT NULL,
    mota     VARCHAR(255),
    CONSTRAINT chk_loaihocluc_range CHECK (diem_min >= 0 AND diem_max <= 4 AND diem_min < diem_max)
);

-- 32. Tổng kết học kỳ
CREATE TABLE TONGKET_HOCKI (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    sinhvien_id   VARCHAR(50) NOT NULL,
    kihoc_id      INT         NOT NULL,
    loaihocluc_id INT,
    gpa_he10      FLOAT,
    gpa_he4       FLOAT,
    tongtinchi    INT,
    sotinchi_dat  INT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sinhvien_id)   REFERENCES SinhVien(masv),
    FOREIGN KEY (kihoc_id)      REFERENCES KiHoc(id),
    FOREIGN KEY (loaihocluc_id) REFERENCES LoaiHocLuc(id),
    UNIQUE (sinhvien_id, kihoc_id)
);
