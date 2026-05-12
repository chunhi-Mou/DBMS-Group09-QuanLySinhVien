USE sinhvien;

DROP TRIGGER IF EXISTS trg_dangkyhoc_check_siso;
DROP TRIGGER IF EXISTS trg_dangkyhoc_check_siso_upd;
DROP TRIGGER IF EXISTS trg_dangkyhoc_check_lich;
DROP TRIGGER IF EXISTS trg_dangkyhoc_check_lich_upd;
DROP TRIGGER IF EXISTS trg_dangkyhoc_check_daqua;
DROP TRIGGER IF EXISTS trg_dangkyhoc_check_daqua_upd;
DROP TRIGGER IF EXISTS trg_dangkyhoc_check_trungmon;
DROP TRIGGER IF EXISTS trg_dangkyhoc_check_trungmon_upd;
DROP TRIGGER IF EXISTS trg_dangkyhoc_no_move;
DROP TRIGGER IF EXISTS trg_monhoc_daudiem_tile_ins;
DROP TRIGGER IF EXISTS trg_monhoc_daudiem_tile_upd;
DROP TRIGGER IF EXISTS trg_monhoc_daudiem_del;
DROP TRIGGER IF EXISTS trg_diemthanhphan_ins;
DROP TRIGGER IF EXISTS trg_diemthanhphan_upd;
DROP TRIGGER IF EXISTS trg_lophocphan_prevent_delete;
DROP TRIGGER IF EXISTS trg_diemhechu_range_ins;
DROP TRIGGER IF EXISTS trg_diemhechu_range_upd;
DROP TRIGGER IF EXISTS trg_loaihocluc_range_ins;
DROP TRIGGER IF EXISTS trg_loaihocluc_range_upd;

DELIMITER //

CREATE TRIGGER trg_dangkyhoc_check_siso
BEFORE INSERT ON DangKyHoc
FOR EACH ROW
BEGIN
    DECLARE v_sisotoida INT;
    DECLARE v_sisohientai INT;
    IF NEW.trangthai <> 'Đã hủy' THEN
        SELECT sisotoida INTO v_sisotoida FROM LopHocPhan WHERE id = NEW.lophocphan_id;
        SELECT COUNT(*) INTO v_sisohientai FROM DangKyHoc WHERE lophocphan_id = NEW.lophocphan_id AND trangthai <> 'Đã hủy';
        IF v_sisohientai >= v_sisotoida THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã đầy'; END IF;
    END IF;
END //

CREATE TRIGGER trg_dangkyhoc_check_siso_upd
BEFORE UPDATE ON DangKyHoc
FOR EACH ROW
BEGIN
    DECLARE v_sisotoida INT;
    DECLARE v_sisohientai INT;
    IF OLD.trangthai = 'Đã hủy' AND NEW.trangthai <> 'Đã hủy' THEN
        SELECT sisotoida INTO v_sisotoida FROM LopHocPhan WHERE id = NEW.lophocphan_id;
        SELECT COUNT(*) INTO v_sisohientai FROM DangKyHoc WHERE lophocphan_id = NEW.lophocphan_id AND trangthai <> 'Đã hủy' AND id <> OLD.id;
        IF v_sisohientai >= v_sisotoida THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã đầy'; END IF;
    END IF;
END //

CREATE TRIGGER trg_dangkyhoc_check_lich
BEFORE INSERT ON DangKyHoc
FOR EACH ROW
BEGIN
    IF NEW.trangthai <> 'Đã hủy' AND EXISTS (
        SELECT 1 FROM BuoiHoc bh_moi
        JOIN LopHocPhan lhp_moi ON lhp_moi.id = bh_moi.lophocphan_id
        JOIN MonHoc_KiHoc mkh_moi ON mkh_moi.id = lhp_moi.monhockihoc_id
        JOIN DangKyHoc dkh ON dkh.sinhvien_id = NEW.sinhvien_id AND dkh.trangthai <> 'Đã hủy'
        JOIN LopHocPhan lhp_cu ON lhp_cu.id = dkh.lophocphan_id
        JOIN MonHoc_KiHoc mkh_cu ON mkh_cu.id = lhp_cu.monhockihoc_id AND mkh_cu.kihoc_id = mkh_moi.kihoc_id
        JOIN BuoiHoc bh_cu ON bh_cu.lophocphan_id = lhp_cu.id
        WHERE bh_moi.lophocphan_id = NEW.lophocphan_id
          AND bh_cu.tuan_id = bh_moi.tuan_id AND bh_cu.ngay_id = bh_moi.ngay_id AND bh_cu.kiphoc_id = bh_moi.kiphoc_id
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng lịch'; END IF;
END //

CREATE TRIGGER trg_dangkyhoc_check_lich_upd
BEFORE UPDATE ON DangKyHoc
FOR EACH ROW
BEGIN
    IF OLD.trangthai = 'Đã hủy' AND NEW.trangthai <> 'Đã hủy' AND EXISTS (
        SELECT 1 FROM BuoiHoc bh_moi
        JOIN LopHocPhan lhp_moi ON lhp_moi.id = bh_moi.lophocphan_id
        JOIN MonHoc_KiHoc mkh_moi ON mkh_moi.id = lhp_moi.monhockihoc_id
        JOIN DangKyHoc dkh ON dkh.sinhvien_id = NEW.sinhvien_id AND dkh.trangthai <> 'Đã hủy' AND dkh.id <> OLD.id
        JOIN LopHocPhan lhp_cu ON lhp_cu.id = dkh.lophocphan_id
        JOIN MonHoc_KiHoc mkh_cu ON mkh_cu.id = lhp_cu.monhockihoc_id AND mkh_cu.kihoc_id = mkh_moi.kihoc_id
        JOIN BuoiHoc bh_cu ON bh_cu.lophocphan_id = lhp_cu.id
        WHERE bh_moi.lophocphan_id = NEW.lophocphan_id
          AND bh_cu.tuan_id = bh_moi.tuan_id AND bh_cu.ngay_id = bh_moi.ngay_id AND bh_cu.kiphoc_id = bh_moi.kiphoc_id
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng lịch'; END IF;
END //

CREATE TRIGGER trg_dangkyhoc_check_daqua
BEFORE INSERT ON DangKyHoc
FOR EACH ROW
BEGIN
    IF NEW.trangthai <> 'Đã hủy' AND EXISTS (
        SELECT 1 FROM LopHocPhan lhp_moi JOIN MonHoc_KiHoc mkh_moi ON mkh_moi.id = lhp_moi.monhockihoc_id
        JOIN DangKyHoc dkh_cu ON dkh_cu.sinhvien_id = NEW.sinhvien_id AND dkh_cu.trangthai <> 'Đã hủy'
        JOIN LopHocPhan lhp_cu ON lhp_cu.id = dkh_cu.lophocphan_id
        JOIN MonHoc_KiHoc mkh_cu ON mkh_cu.id = lhp_cu.monhockihoc_id
        JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh_cu.id
        WHERE lhp_moi.id = NEW.lophocphan_id AND mkh_cu.monhoc_id = mkh_moi.monhoc_id AND kqm.diem >= 4.0
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã qua'; END IF;
END //

CREATE TRIGGER trg_dangkyhoc_check_daqua_upd
BEFORE UPDATE ON DangKyHoc
FOR EACH ROW
BEGIN
    IF OLD.trangthai = 'Đã hủy' AND NEW.trangthai <> 'Đã hủy' AND EXISTS (
        SELECT 1 FROM LopHocPhan lhp_moi JOIN MonHoc_KiHoc mkh_moi ON mkh_moi.id = lhp_moi.monhockihoc_id
        JOIN DangKyHoc dkh_cu ON dkh_cu.sinhvien_id = NEW.sinhvien_id AND dkh_cu.trangthai <> 'Đã hủy' AND dkh_cu.id <> OLD.id
        JOIN LopHocPhan lhp_cu ON lhp_cu.id = dkh_cu.lophocphan_id
        JOIN MonHoc_KiHoc mkh_cu ON mkh_cu.id = lhp_cu.monhockihoc_id
        JOIN KetQuaMon kqm ON kqm.dangkyhoc_id = dkh_cu.id
        WHERE lhp_moi.id = NEW.lophocphan_id AND mkh_cu.monhoc_id = mkh_moi.monhoc_id AND kqm.diem >= 4.0
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã qua'; END IF;
END //

CREATE TRIGGER trg_dangkyhoc_check_trungmon
BEFORE INSERT ON DangKyHoc
FOR EACH ROW
BEGIN
    IF NEW.trangthai <> 'Đã hủy' AND EXISTS (
        SELECT 1 FROM LopHocPhan lhp_moi JOIN MonHoc_KiHoc mkh_moi ON mkh_moi.id = lhp_moi.monhockihoc_id
        JOIN DangKyHoc dkh_cu ON dkh_cu.sinhvien_id = NEW.sinhvien_id AND dkh_cu.trangthai <> 'Đã hủy'
        JOIN LopHocPhan lhp_cu ON lhp_cu.id = dkh_cu.lophocphan_id
        JOIN MonHoc_KiHoc mkh_cu ON mkh_cu.id = lhp_cu.monhockihoc_id
        WHERE lhp_moi.id = NEW.lophocphan_id AND mkh_cu.monhoc_id = mkh_moi.monhoc_id AND mkh_cu.kihoc_id = mkh_moi.kihoc_id
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã đăng ký'; END IF;
END //

CREATE TRIGGER trg_dangkyhoc_check_trungmon_upd
BEFORE UPDATE ON DangKyHoc
FOR EACH ROW
BEGIN
    IF OLD.trangthai = 'Đã hủy' AND NEW.trangthai <> 'Đã hủy' AND EXISTS (
        SELECT 1 FROM LopHocPhan lhp_moi JOIN MonHoc_KiHoc mkh_moi ON mkh_moi.id = lhp_moi.monhockihoc_id
        JOIN DangKyHoc dkh_cu ON dkh_cu.sinhvien_id = NEW.sinhvien_id AND dkh_cu.trangthai <> 'Đã hủy' AND dkh_cu.id <> OLD.id
        JOIN LopHocPhan lhp_cu ON lhp_cu.id = dkh_cu.lophocphan_id
        JOIN MonHoc_KiHoc mkh_cu ON mkh_cu.id = lhp_cu.monhockihoc_id
        WHERE lhp_moi.id = NEW.lophocphan_id AND mkh_cu.monhoc_id = mkh_moi.monhoc_id AND mkh_cu.kihoc_id = mkh_moi.kihoc_id
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã đăng ký'; END IF;
END //

CREATE TRIGGER trg_dangkyhoc_no_move
BEFORE UPDATE ON DangKyHoc
FOR EACH ROW
BEGIN
    IF NEW.sinhvien_id <> OLD.sinhvien_id OR NEW.lophocphan_id <> OLD.lophocphan_id THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không được sửa đăng ký'; END IF;
    IF OLD.trangthai <> 'Đã hủy' AND NEW.trangthai = 'Đã hủy' THEN
        IF EXISTS (SELECT 1 FROM KetQuaMon WHERE dangkyhoc_id = OLD.id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã chốt điểm'; END IF;
    ELSEIF OLD.trangthai = 'Đã hủy' AND NEW.trangthai = 'Đã lưu' THEN
        -- Allow activation
    ELSEIF OLD.trangthai <> NEW.trangthai THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trạng thái không hợp lệ'; END IF;
END //

CREATE TRIGGER trg_monhoc_daudiem_tile_ins
AFTER INSERT ON MonHoc_DauDiem
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(7,4);
    IF EXISTS (SELECT 1 FROM DiemThanhPhan dtp JOIN DangKyHoc dkh ON dkh.id = dtp.dangkyhoc_id JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id WHERE mkh.monhoc_id = NEW.monhoc_id) OR EXISTS (SELECT 1 FROM KetQuaMon kqm JOIN DangKyHoc dkh ON dkh.id = kqm.dangkyhoc_id JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id WHERE mkh.monhoc_id = NEW.monhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có điểm';
    END IF;
    SELECT COALESCE(SUM(tile), 0) INTO v_total FROM MonHoc_DauDiem WHERE monhoc_id = NEW.monhoc_id;
    IF v_total > 1.0001 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tỉ lệ điểm vượt 100%'; END IF;
END //

CREATE TRIGGER trg_monhoc_daudiem_tile_upd
AFTER UPDATE ON MonHoc_DauDiem
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(7,4);
    IF EXISTS (SELECT 1 FROM DiemThanhPhan dtp JOIN DangKyHoc dkh ON dkh.id = dtp.dangkyhoc_id JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id WHERE mkh.monhoc_id = OLD.monhoc_id) OR EXISTS (SELECT 1 FROM KetQuaMon kqm JOIN DangKyHoc dkh ON dkh.id = kqm.dangkyhoc_id JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id WHERE mkh.monhoc_id = OLD.monhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có điểm';
    END IF;
    SELECT COALESCE(SUM(tile), 0) INTO v_total FROM MonHoc_DauDiem WHERE monhoc_id = NEW.monhoc_id;
    IF v_total > 1.0001 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tỉ lệ điểm vượt 100%'; END IF;
END //

CREATE TRIGGER trg_monhoc_daudiem_del
BEFORE DELETE ON MonHoc_DauDiem
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM DiemThanhPhan dtp JOIN DangKyHoc dkh ON dkh.id = dtp.dangkyhoc_id JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id WHERE mkh.monhoc_id = OLD.monhoc_id) OR EXISTS (SELECT 1 FROM KetQuaMon kqm JOIN DangKyHoc dkh ON dkh.id = kqm.dangkyhoc_id JOIN LopHocPhan lhp ON lhp.id = dkh.lophocphan_id JOIN MonHoc_KiHoc mkh ON mkh.id = lhp.monhockihoc_id WHERE mkh.monhoc_id = OLD.monhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có điểm';
    END IF;
END //

CREATE TRIGGER trg_diemthanhphan_ins
BEFORE INSERT ON DiemThanhPhan
FOR EACH ROW
BEGIN
    IF NEW.diem < 0 OR NEW.diem > 10 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Điểm không hợp lệ'; END IF;
    IF EXISTS (SELECT 1 FROM DangKyHoc WHERE id = NEW.dangkyhoc_id AND trangthai = 'Đã hủy') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đăng ký đã hủy'; END IF;
    IF EXISTS (SELECT 1 FROM KetQuaMon WHERE dangkyhoc_id = NEW.dangkyhoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã chốt điểm'; END IF;
END //

CREATE TRIGGER trg_diemthanhphan_upd
BEFORE UPDATE ON DiemThanhPhan
FOR EACH ROW
BEGIN
    IF NEW.diem < 0 OR NEW.diem > 10 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Điểm không hợp lệ'; END IF;
    IF EXISTS (SELECT 1 FROM DangKyHoc WHERE id = OLD.dangkyhoc_id AND trangthai = 'Đã hủy') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đăng ký đã hủy'; END IF;
    IF EXISTS (SELECT 1 FROM KetQuaMon WHERE dangkyhoc_id = OLD.dangkyhoc_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã chốt điểm'; END IF;
END //

CREATE TRIGGER trg_lophocphan_prevent_delete
BEFORE DELETE ON LopHocPhan
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM DangKyHoc WHERE lophocphan_id = OLD.id AND trangthai <> 'Đã hủy') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp đã có sinh viên'; END IF;
END //

CREATE TRIGGER trg_diemhechu_range_ins
BEFORE INSERT ON DiemHeChu FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM DiemHeChu WHERE NOT (NEW.diem10_max <= diem10_min OR NEW.diem10_min >= diem10_max)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng điểm'; END IF;
END //

CREATE TRIGGER trg_diemhechu_range_upd
BEFORE UPDATE ON DiemHeChu FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM DiemHeChu WHERE id <> OLD.id AND NOT (NEW.diem10_max <= diem10_min OR NEW.diem10_min >= diem10_max)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng điểm'; END IF;
END //

CREATE TRIGGER trg_loaihocluc_range_ins
BEFORE INSERT ON LoaiHocLuc FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM LoaiHocLuc WHERE NOT (NEW.diem_max <= diem_min OR NEW.diem_min >= diem_max)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng học lực'; END IF;
END //

CREATE TRIGGER trg_loaihocluc_range_upd
BEFORE UPDATE ON LoaiHocLuc FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM LoaiHocLuc WHERE id <> OLD.id AND NOT (NEW.diem_max <= diem_min OR NEW.diem_min >= diem_max)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng học lực'; END IF;
END //

DELIMITER ;
ELECT 1 FROM LoaiHocLuc WHERE id <> OLD.id AND NOT (NEW.diem_max <= diem_min OR NEW.diem_min >= diem_max)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng học lực'; END IF;
END //

DELIMITER ;
