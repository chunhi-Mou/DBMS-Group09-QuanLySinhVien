USE SinhVien;

ALTER TABLE ThanhVien
    MODIFY username VARCHAR(255) NOT NULL,
    MODIFY password VARCHAR(255) NOT NULL,
    MODIFY ten      VARCHAR(255) NOT NULL,
    MODIFY email    VARCHAR(255) NOT NULL,
    MODIFY vaitro   VARCHAR(50)  NOT NULL,
    ADD CONSTRAINT chk_thanhvien_vaitro
        CHECK (vaitro IN ('ADMIN', 'GV', 'SV', 'NV'));

ALTER TABLE KiHoc
    MODIFY namhoc_id INT NOT NULL,
    MODIFY hocki_id  INT NOT NULL,
    ADD CONSTRAINT uq_kihoc_namhoc_hocki
        UNIQUE (namhoc_id, hocki_id);

ALTER TABLE MonHoc
    MODIFY mamh VARCHAR(50)  NOT NULL,
    MODIFY ten  VARCHAR(255) NOT NULL,
    MODIFY sotc INT NOT NULL;

ALTER TABLE NganhHoc_MonHoc
    MODIFY loai VARCHAR(50) NOT NULL,
    ADD CONSTRAINT chk_nganhhoc_monhoc_loai
        CHECK (loai IN ('BB', 'TC'));

ALTER TABLE MonHoc_DauDiem
    MODIFY tile DECIMAL(5,4) NOT NULL,
    ADD CONSTRAINT chk_monhoc_daudiem_tile
        CHECK (tile > 0 AND tile <= 1);

ALTER TABLE LopHocPhan
    MODIFY ten            VARCHAR(255) NOT NULL,
    MODIFY sisotoida      INT NOT NULL,
    MODIFY monhockihoc_id INT NOT NULL;

ALTER TABLE PhongHoc
    MODIFY ten     VARCHAR(255) NOT NULL,
    MODIFY succhua INT NOT NULL,
    ADD CONSTRAINT chk_phonghoc_succhua
        CHECK (succhua > 0);

ALTER TABLE BuoiHoc
    MODIFY lophocphan_id INT NOT NULL,
    MODIFY tuan_id       INT NOT NULL,
    MODIFY ngay_id       INT NOT NULL,
    MODIFY kiphoc_id     INT NOT NULL,
    MODIFY phonghoc_id   INT NOT NULL,
    MODIFY giangvien_id  INT NOT NULL;

ALTER TABLE DangKyHoc
    MODIFY trangthai     VARCHAR(50) NOT NULL DEFAULT 'Đã lưu',
    MODIFY sinhvien_id   VARCHAR(50) NOT NULL,
    MODIFY lophocphan_id INT NOT NULL,
    ADD CONSTRAINT chk_dangkyhoc_trangthai
        CHECK (trangthai IN ('Đã lưu', 'Đã khóa', 'Chờ duyệt', 'Đã hủy'));

ALTER TABLE DauDiem
    MODIFY ten VARCHAR(50) NOT NULL;

ALTER TABLE DiemThanhPhan
    MODIFY diem DECIMAL(4,2) NOT NULL;

ALTER TABLE DiemHeChu
    MODIFY ten        VARCHAR(5) NOT NULL,
    MODIFY diem4      DECIMAL(4,2) NOT NULL,
    MODIFY diem10_min DECIMAL(4,2) NOT NULL,
    MODIFY diem10_max DECIMAL(4,2) NOT NULL,
    ADD CONSTRAINT chk_diemhechu_diem4
        CHECK (diem4 >= 0 AND diem4 <= 4),
    ADD CONSTRAINT chk_diemhechu_range
        CHECK (diem10_min >= 0 AND diem10_max <= 10 AND diem10_min < diem10_max);

ALTER TABLE LoaiHocLuc
    MODIFY ten      VARCHAR(50) NOT NULL,
    MODIFY diem_min DECIMAL(4,2) NOT NULL,
    MODIFY diem_max DECIMAL(4,2) NOT NULL,
    ADD CONSTRAINT chk_loaihocluc_range
        CHECK (diem_min >= 0 AND diem_max <= 4 AND diem_min < diem_max);

ALTER TABLE KetQuaMon
    MODIFY dangkyhoc_id INT NOT NULL,
    MODIFY diem         DECIMAL(4,2) NOT NULL,
    MODIFY diemhechu_id INT NOT NULL;
