-- INDEXES
CREATE INDEX idx_DangKyHoc_sinhvien_id ON DangKyHoc(sinhvien_id);
CREATE INDEX idx_DangKyHoc_lophocphan_id ON DangKyHoc(lophocphan_id);
CREATE INDEX idx_BuoiHoc_lophocphan_id ON BuoiHoc(lophocphan_id);
CREATE INDEX idx_BuoiHoc_giangvien_id ON BuoiHoc(giangvien_id);
CREATE INDEX idx_BuoiHoc_Schedule ON BuoiHoc(tuan_id, ngay_id, kiphoc_id);
CREATE INDEX idx_LopHocPhan_monhockihoc_id ON LopHocPhan(monhockihoc_id);
CREATE INDEX idx_MonHoc_KiHoc_kihoc_id ON MonHoc_KiHoc(kihoc_id);
CREATE INDEX idx_MonHoc_KiHoc_monhoc_id ON MonHoc_KiHoc(monhoc_id);
CREATE INDEX idx_DiemThanhPhan_dangkyhoc_id ON DiemThanhPhan(dangkyhoc_id);
CREATE INDEX idx_KetQuaMon_dangkyhoc_id ON KetQuaMon(dangkyhoc_id);
CREATE INDEX idx_SinhVien_Nganh_sinhvien_id ON SinhVien_Nganh(sinhvien_id);
CREATE INDEX idx_NganhHoc_MonHoc_nganh_id ON NganhHoc_MonHoc(nganh_id);

-- VIEWS
CREATE OR REPLACE VIEW v_ThongTin_LopHocPhan AS
SELECT lhp.id AS lophocphan_id, lhp.ten AS ten_lop, lhp.sisotoida,
       COUNT(dkh.id) AS sisohientai, mh.id AS monhoc_id, mh.mamh,
       mh.ten AS ten_mon_hoc, mh.sotc, mkh.kihoc_id
FROM LopHocPhan lhp
JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN MonHoc mh ON mkh.monhoc_id = mh.id
LEFT JOIN DangKyHoc dkh ON dkh.lophocphan_id = lhp.id
GROUP BY lhp.id, lhp.ten, lhp.sisotoida, mh.id, mh.mamh, mh.ten, mh.sotc, mkh.kihoc_id;

CREATE OR REPLACE VIEW v_ThoiKhoaBieu_SinhVien AS
SELECT dkh.sinhvien_id, mkh.kihoc_id, b.tuan_id, b.ngay_id, b.kiphoc_id,
       ph.ten AS phong_hoc, mh.ten AS ten_mon_hoc, lhp.ten AS ten_lop,
       CONCAT(tv.hodem, ' ', tv.ten) AS giang_vien
FROM DangKyHoc dkh
JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN MonHoc mh ON mkh.monhoc_id = mh.id
JOIN BuoiHoc b ON lhp.id = b.lophocphan_id
JOIN PhongHoc ph ON b.phonghoc_id = ph.id
JOIN GiangVien gv ON b.giangvien_id = gv.thanhvien_id
JOIN ThanhVien tv ON gv.thanhvien_id = tv.id;

CREATE OR REPLACE VIEW v_ThoiKhoaBieu_GiangVien AS
SELECT b.giangvien_id, mkh.kihoc_id, b.tuan_id, b.ngay_id, b.kiphoc_id,
       ph.ten AS phong_hoc, mh.ten AS ten_mon_hoc, lhp.ten AS ten_lop
FROM BuoiHoc b
JOIN LopHocPhan lhp ON b.lophocphan_id = lhp.id
JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN MonHoc mh ON mkh.monhoc_id = mh.id
JOIN PhongHoc ph ON b.phonghoc_id = ph.id;

CREATE OR REPLACE VIEW v_KetQuaHocTap_ChiTiet AS
SELECT dkh.sinhvien_id, mkh.kihoc_id, mh.id AS monhoc_id, mh.ten AS ten_mon_hoc,
       mh.sotc, SUM(dtp.diem * mdd.tile) AS diem_tong_he10,
       kqm.diem AS diem_tong_chinh_thuc, dhc.ten AS diem_chu, dhc.diem4
FROM DangKyHoc dkh
JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
JOIN MonHoc mh ON mkh.monhoc_id = mh.id
LEFT JOIN DiemThanhPhan dtp ON dkh.id = dtp.dangkyhoc_id
LEFT JOIN MonHoc_DauDiem mdd ON dtp.daudiem_id = mdd.daudiem_id AND mdd.monhoc_id = mh.id
LEFT JOIN KetQuaMon kqm ON dkh.id = kqm.dangkyhoc_id
LEFT JOIN DiemHeChu dhc ON kqm.diemhechu_id = dhc.id
GROUP BY dkh.sinhvien_id, mkh.kihoc_id, mh.id, mh.ten, mh.sotc, kqm.diem, dhc.ten, dhc.diem4;

-- TRIGGERS
DELIMITER //
CREATE TRIGGER trg_check_siso_toida
BEFORE INSERT ON DangKyHoc
FOR EACH ROW
BEGIN
    DECLARE v_siso INT;
    DECLARE v_toida INT;
    
    SELECT COUNT(dkh.id), lhp.sisotoida INTO v_siso, v_toida
    FROM LopHocPhan lhp
    LEFT JOIN DangKyHoc dkh ON lhp.id = dkh.lophocphan_id
    WHERE lhp.id = NEW.lophocphan_id
    GROUP BY lhp.id, lhp.sisotoida;
    
    IF v_siso >= v_toida THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lớp học phần đã đủ sĩ số tối đa';
    END IF;
END //
DELIMITER ;
