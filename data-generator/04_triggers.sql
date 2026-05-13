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

-- --- Protection for DangKyHoc ---
-- Registration logic (siso, lich, daqua, trungmon) moved to sp_DangKyHoc.
-- Trigger only protects invariants.

CREATE TRIGGER trg_dangkyhoc_no_move
BEFORE UPDATE ON DangKyHoc
FOR EACH ROW
BEGIN
    IF NEW.sinhvien_id <> OLD.sinhvien_id OR NEW.lophocphan_id <> OLD.lophocphan_id THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không được sửa đăng ký'; 
    END IF;
    
    -- Hủy đăng ký: check nếu đã chốt điểm
    IF OLD.trangthai <> 'Đã hủy' AND NEW.trangthai = 'Đã hủy' THEN
        IF EXISTS (SELECT 1 FROM KetQuaMon WHERE dangkyhoc_id = OLD.id) THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã chốt điểm'; 
        END IF;
    -- Reactivation (Đã hủy -> Đã lưu) is allowed. sp_DangKyHoc handles siso/lich for reactivation.
    END IF;
END //

-- --- Protection for Grade Config ---

CREATE TRIGGER trg_monhoc_daudiem_tile_ins
AFTER INSERT ON MonHoc_DauDiem
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(7,4);
    IF EXISTS (SELECT 1 FROM MonHoc_KiHoc mkh JOIN LopHocPhan lhp ON lhp.monhockihoc_id = mkh.id JOIN DangKyHoc dkh ON dkh.lophocphan_id = lhp.id JOIN (SELECT dangkyhoc_id FROM DiemThanhPhan UNION SELECT dangkyhoc_id FROM KetQuaMon) g ON g.dangkyhoc_id = dkh.id WHERE mkh.monhoc_id = NEW.monhoc_id) THEN
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
    IF EXISTS (SELECT 1 FROM MonHoc_KiHoc mkh JOIN LopHocPhan lhp ON lhp.monhockihoc_id = mkh.id JOIN DangKyHoc dkh ON dkh.lophocphan_id = lhp.id JOIN (SELECT dangkyhoc_id FROM DiemThanhPhan UNION SELECT dangkyhoc_id FROM KetQuaMon) g ON g.dangkyhoc_id = dkh.id WHERE mkh.monhoc_id = OLD.monhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có điểm';
    END IF;
    SELECT COALESCE(SUM(tile), 0) INTO v_total FROM MonHoc_DauDiem WHERE monhoc_id = NEW.monhoc_id;
    IF v_total > 1.0001 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tỉ lệ điểm vượt 100%'; END IF;
END //

CREATE TRIGGER trg_monhoc_daudiem_del
BEFORE DELETE ON MonHoc_DauDiem
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM MonHoc_KiHoc mkh JOIN LopHocPhan lhp ON lhp.monhockihoc_id = mkh.id JOIN DangKyHoc dkh ON dkh.lophocphan_id = lhp.id JOIN (SELECT dangkyhoc_id FROM DiemThanhPhan UNION SELECT dangkyhoc_id FROM KetQuaMon) g ON g.dangkyhoc_id = dkh.id WHERE mkh.monhoc_id = OLD.monhoc_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đã có điểm';
    END IF;
END //

-- --- Protection for Grades ---

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

-- --- Protection for Classes ---

CREATE TRIGGER trg_lophocphan_prevent_delete
BEFORE DELETE ON LopHocPhan
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM DangKyHoc WHERE lophocphan_id = OLD.id AND trangthai <> 'Đã hủy') THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp đã có sinh viên'; 
    END IF;
END //

-- --- Protection for Lookup Ranges ---

CREATE TRIGGER trg_diemhechu_range_ins
BEFORE INSERT ON DiemHeChu FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM DiemHeChu WHERE NOT (NEW.diem10_max <= diem10_min OR NEW.diem10_min >= diem10_max)) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng điểm'; 
    END IF;
END //

CREATE TRIGGER trg_diemhechu_range_upd
BEFORE UPDATE ON DiemHeChu FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM DiemHeChu WHERE id <> OLD.id AND NOT (NEW.diem10_max <= diem10_min OR NEW.diem10_min >= diem10_max)) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng điểm'; 
    END IF;
END //

CREATE TRIGGER trg_loaihocluc_range_ins
BEFORE INSERT ON LoaiHocLuc FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM LoaiHocLuc WHERE NOT (NEW.diem_max <= diem_min OR NEW.diem_min >= diem_max)) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng học lực'; 
    END IF;
END //

CREATE TRIGGER trg_loaihocluc_range_upd
BEFORE UPDATE ON LoaiHocLuc FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM LoaiHocLuc WHERE id <> OLD.id AND NOT (NEW.diem_max <= diem_min OR NEW.diem_min >= diem_max)) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trùng khoảng học lực'; 
    END IF;
END //

DELIMITER ;
