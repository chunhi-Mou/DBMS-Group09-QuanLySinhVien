DELIMITER //

CREATE PROCEDURE sp_DangKyHoc(IN p_sinhvien_id VARCHAR(50), IN p_lophocphan_id INT)
BEGIN
    DECLARE v_sisotoida INT;
    DECLARE v_sisohientai INT;
    DECLARE v_kihoc_id INT;
    DECLARE v_monhoc_id INT;
    DECLARE v_pass_count INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    SELECT lhp.sisotoida, COUNT(dkh.id), mkh.kihoc_id, mkh.monhoc_id
    INTO v_sisotoida, v_sisohientai, v_kihoc_id, v_monhoc_id
    FROM LopHocPhan lhp
    JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
    LEFT JOIN DangKyHoc dkh ON lhp.id = dkh.lophocphan_id
    WHERE lhp.id = p_lophocphan_id
    GROUP BY lhp.id;
    
    IF v_sisohientai >= v_sisotoida THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lớp học phần đã đầy';
    END IF;
    
    SELECT COUNT(*) INTO v_pass_count
    FROM DangKyHoc dkh
    JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
    JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
    JOIN KetQuaMon kqm ON dkh.id = kqm.dangkyhoc_id
    WHERE dkh.sinhvien_id = p_sinhvien_id 
      AND mkh.monhoc_id = v_monhoc_id
      AND kqm.diem >= 4.0;
      
    IF v_pass_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sinh viên đã qua môn này';
    END IF;
    
    INSERT INTO DangKyHoc (ngaydangky, trangthai, sinhvien_id, lophocphan_id)
    VALUES (NOW(), 'Đã lưu', p_sinhvien_id, p_lophocphan_id);
    
    COMMIT;
END //

CREATE PROCEDURE sp_ChotDiemMonHoc(IN p_lophocphan_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_dangkyhoc_id INT;
    DECLARE v_diem_tong FLOAT;
    DECLARE v_diemhechu_id INT;
    
    DECLARE cur CURSOR FOR 
        SELECT dkh.id
        FROM DangKyHoc dkh
        WHERE dkh.lophocphan_id = p_lophocphan_id;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_dangkyhoc_id;
        IF done THEN LEAVE read_loop; END IF;
        
        SELECT SUM(dtp.diem * mdd.tile) INTO v_diem_tong
        FROM DangKyHoc dkh
        JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
        JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
        JOIN MonHoc_DauDiem mdd ON mkh.monhoc_id = mdd.monhoc_id
        JOIN DiemThanhPhan dtp ON dkh.id = dtp.dangkyhoc_id AND dtp.daudiem_id = mdd.daudiem_id
        WHERE dkh.id = v_dangkyhoc_id;
        
        IF v_diem_tong IS NOT NULL THEN
            SELECT id INTO v_diemhechu_id FROM DiemHeChu
            WHERE v_diem_tong BETWEEN diem10_min AND diem10_max LIMIT 1;
            
            IF EXISTS (SELECT 1 FROM KetQuaMon WHERE dangkyhoc_id = v_dangkyhoc_id) THEN
                UPDATE KetQuaMon SET diem = v_diem_tong, diemhechu_id = v_diemhechu_id WHERE dangkyhoc_id = v_dangkyhoc_id;
            ELSE
                INSERT INTO KetQuaMon (dangkyhoc_id, diem, diemhechu_id) VALUES (v_dangkyhoc_id, v_diem_tong, v_diemhechu_id);
            END IF;
        END IF;
    END LOOP;
    CLOSE cur;
    COMMIT;
END //

CREATE PROCEDURE sp_TongKetHocKy(IN p_kihoc_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_sinhvien_id VARCHAR(50);
    DECLARE v_gpa_he10 FLOAT;
    DECLARE v_gpa_he4 FLOAT;
    DECLARE v_tong_tin_chi INT;
    DECLARE v_tin_chi_dat INT;
    DECLARE v_loaihocluc_id INT;
    
    DECLARE cur CURSOR FOR 
        SELECT DISTINCT dkh.sinhvien_id
        FROM DangKyHoc dkh
        JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
        JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
        WHERE mkh.kihoc_id = p_kihoc_id;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_sinhvien_id;
        IF done THEN LEAVE read_loop; END IF;
        
        SELECT 
            IFNULL(SUM(kqm.diem * mh.sotc) / NULLIF(SUM(mh.sotc), 0), 0),
            IFNULL(SUM(dhc.diem4 * mh.sotc) / NULLIF(SUM(mh.sotc), 0), 0),
            IFNULL(SUM(mh.sotc), 0),
            IFNULL(SUM(CASE WHEN kqm.diem >= 4.0 THEN mh.sotc ELSE 0 END), 0)
        INTO v_gpa_he10, v_gpa_he4, v_tong_tin_chi, v_tin_chi_dat
        FROM DangKyHoc dkh
        JOIN LopHocPhan lhp ON dkh.lophocphan_id = lhp.id
        JOIN MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
        JOIN MonHoc mh ON mkh.monhoc_id = mh.id
        JOIN KetQuaMon kqm ON dkh.id = kqm.dangkyhoc_id
        JOIN DiemHeChu dhc ON kqm.diemhechu_id = dhc.id
        WHERE dkh.sinhvien_id = v_sinhvien_id AND mkh.kihoc_id = p_kihoc_id;
          
        IF v_tong_tin_chi > 0 THEN
            SELECT id INTO v_loaihocluc_id FROM LoaiHocLuc WHERE v_gpa_he4 BETWEEN diem_min AND diem_max LIMIT 1;
            
            IF EXISTS (SELECT 1 FROM TONGKET_HOCKI WHERE sinhvien_id = v_sinhvien_id AND kihoc_id = p_kihoc_id) THEN
                UPDATE TONGKET_HOCKI
                SET gpa_he10 = v_gpa_he10, gpa_he4 = v_gpa_he4, tongtinchi = v_tong_tin_chi, sotinchi_dat = v_tin_chi_dat, loaihocluc_id = v_loaihocluc_id
                WHERE sinhvien_id = v_sinhvien_id AND kihoc_id = p_kihoc_id;
            ELSE
                INSERT INTO TONGKET_HOCKI (sinhvien_id, kihoc_id, loaihocluc_id, gpa_he10, gpa_he4, tongtinchi, sotinchi_dat)
                VALUES (v_sinhvien_id, p_kihoc_id, v_loaihocluc_id, v_gpa_he10, v_gpa_he4, v_tong_tin_chi, v_tin_chi_dat);
            END IF;
        END IF;
    END LOOP;
    CLOSE cur;
    COMMIT;
END //

DELIMITER ;
