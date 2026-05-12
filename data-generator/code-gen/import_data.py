#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Import PTIT data from data-generator/data/*.json into MySQL.
Run gen_data.py first to generate the JSON files.
"""
import json, os, sys
import pymysql
sys.stdout.reconfigure(encoding="utf-8")

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR   = os.path.join(SCRIPT_DIR, "data")
SCHEMA     = os.path.join(SCRIPT_DIR, "SinhVien.sql")

print("=" * 60)
print("PTIT Import v3.0")
print("=" * 60)

# ── Connect ──────────────────────────────────────────────────
print("\nConnecting to MySQL...")
try:
    conn   = pymysql.connect(host="localhost", user="root", password="chunhi", charset="utf8mb4")
    cursor = conn.cursor()
    print("✓ Connected")
except Exception as e:
    print(f"✗ {e}"); sys.exit(1)

# ── Database ─────────────────────────────────────────────────
cursor.execute("DROP DATABASE IF EXISTS sinhvien")
cursor.execute("CREATE DATABASE sinhvien CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
cursor.execute("USE sinhvien")
conn.commit()
print("✓ Database reset")

# ── Schema ───────────────────────────────────────────────────
with open(SCHEMA, "r", encoding="utf-8") as f:
    sql_text = f.read()

for stmt in sql_text.split(";"):
    stmt = stmt.strip()
    if stmt and not stmt.upper().startswith("USE"):
        try:
            cursor.execute(stmt)
        except Exception as e:
            if "already exists" not in str(e):
                print(f"  Schema warning: {e}")
conn.commit()

# Tạo trigger riêng (pymysql không hỗ trợ DELIMITER)
try:
    cursor.execute("DROP TRIGGER IF EXISTS trg_check_sv_lich")
    cursor.execute("""
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
END
""")
    
    cursor.execute("DROP TRIGGER IF EXISTS trg_check_siso_toida")
    cursor.execute("""
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
END
""")
    conn.commit()
    print("✓ Triggers tạo thành công")
    
    # ── Procedures ────────────────────────────────────────────────
    cursor.execute("DROP PROCEDURE IF EXISTS sp_DangKyHoc")
    cursor.execute("""
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
END
""")

    cursor.execute("DROP PROCEDURE IF EXISTS sp_ChotDiemMonHoc")
    cursor.execute("""
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
END
""")

    cursor.execute("DROP PROCEDURE IF EXISTS sp_TongKetHocKy")
    cursor.execute("""
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
END
""")
    conn.commit()
    print("✓ Procedures tạo thành công")

except Exception as e:
    print(f"  Trigger/Procedure warning: {e}")

print("✓ Schema created\n")

# ── Helpers ──────────────────────────────────────────────────
def load(name):
    path = os.path.join(DATA_DIR, f"{name}.json")
    if not os.path.exists(path):
        print(f"  {'[MISSING]':12} {name} — run gen_data.py first")
        return []
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def insert(table, sql, rows):
    if not rows:
        print(f"  {'✗ no data':12} {table}"); return 0
    try:
        for i in range(0, len(rows), 1000):
            cursor.executemany(sql, rows[i:i+1000])
        conn.commit()
        print(f"  {'✓':12} {table:30} {len(rows):>7} rows")
        return len(rows)
    except Exception as e:
        print(f"  {'✗':12} {table:30} {str(e)[:60]}")
        conn.rollback()
        return 0

# ── Insert (FK order) ─────────────────────────────────────────
print("=== Importing ===\n")

r = {name: load(name) for name in [
    "Truong","DiaChi","Khoa","BoMon",
    "NganhHoc","LopHanhChinh",
    "ThanhVien","GiangVien","NhanVien","SinhVien",
    "SinhVien_Nganh","MonHoc","NganhHoc_MonHoc",
    "DauDiem","MonHoc_DauDiem","NamHoc","HocKi","KiHoc",
    "MonHoc_KiHoc","LopHocPhan","GiangVien_LopHocPhan",
    "PhongHoc","TuanHoc","NgayHoc","KipHoc","BuoiHoc",
    "DiemHeChu","LoaiHocLuc",
    "DangKyHoc","DiemThanhPhan","KetQuaMon","TONGKET_HOCKI",
]}

insert("Truong",
       "INSERT INTO Truong(id,ten,mota) VALUES(%s,%s,%s)",
       [(x["id"], x["ten"], x["mota"]) for x in r["Truong"]])

insert("DiaChi",
       "INSERT INTO DiaChi(id,sonha,toanha,xompho,phuongxa,quanhuyen,tinhthanh,truong_id) VALUES(%s,%s,%s,%s,%s,%s,%s,%s)",
       [(x["id"],x["sonha"],x["toanha"],x["xompho"],x["phuongxa"],x["quanhuyen"],x["tinhthanh"],x.get("truong_id"))
        for x in r["DiaChi"]])

insert("Khoa",
       "INSERT INTO Khoa(id,ten,mota,truong_id) VALUES(%s,%s,%s,%s)",
       [(x["id"],x["ten"],x["mota"],x["truong_id"]) for x in r["Khoa"]])

insert("BoMon",
       "INSERT INTO BoMon(id,ten,mota,khoa_id) VALUES(%s,%s,%s,%s)",
       [(x["id"],x["ten"],x["mota"],x["khoa_id"]) for x in r["BoMon"]])

insert("NganhHoc",
       "INSERT INTO NganhHoc(id,ten,khoa_id) VALUES(%s,%s,%s)",
       [(x["id"],x["ten"],x["khoa_id"]) for x in r["NganhHoc"]])

insert("LopHanhChinh",
       "INSERT INTO LopHanhChinh(id,tenlop,nganh_id) VALUES(%s,%s,%s)",
       [(x["id"],x["tenlop"],x["nganh_id"]) for x in r["LopHanhChinh"]])

insert("ThanhVien",
       "INSERT INTO ThanhVien(id,username,password,hodem,ten,ngaysinh,email,dt,vaitro,diachi_id) VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
       [(x["id"],x["username"],x["password"],x["hodem"],x["ten"],x["ngaysinh"],x["email"],x["dt"],x["vaitro"],x["diachi_id"])
        for x in r["ThanhVien"]])

insert("SinhVien",
       "INSERT INTO SinhVien(masv,thanhvien_id,lophanhchinh_id) VALUES(%s,%s,%s)",
       [(x["masv"],x["thanhvien_id"],x.get("lophanhchinh_id")) for x in r["SinhVien"]])

insert("GiangVien",
       "INSERT INTO GiangVien(thanhvien_id,bomon_id,hocham) VALUES(%s,%s,%s)",
       [(x["thanhvien_id"],x["bomon_id"],x["hocham"]) for x in r["GiangVien"]])

insert("NhanVien",
       "INSERT INTO NhanVien(thanhvien_id,vitri) VALUES(%s,%s)",
       [(x["thanhvien_id"],x["vitri"]) for x in r["NhanVien"]])

insert("SinhVien_Nganh",
       "INSERT INTO SinhVien_Nganh(sinhvien_id,nganh_id) VALUES(%s,%s)",
       [(x["sinhvien_id"],x["nganh_id"]) for x in r["SinhVien_Nganh"]])

insert("MonHoc",
       "INSERT INTO MonHoc(id,mamh,ten,sotc,mota,bomon_id) VALUES(%s,%s,%s,%s,%s,%s)",
       [(x["id"],x["mamh"],x["ten"],x["sotc"],x["mota"],x["bomon_id"]) for x in r["MonHoc"]])

insert("NganhHoc_MonHoc",
       "INSERT INTO NganhHoc_MonHoc(nganh_id,monhoc_id,loai) VALUES(%s,%s,%s)",
       [(x["nganh_id"],x["monhoc_id"],x["loai"]) for x in r["NganhHoc_MonHoc"]])

insert("DauDiem",
       "INSERT INTO DauDiem(id,ten,mota) VALUES(%s,%s,%s)",
       [(x["id"],x["ten"],x["mota"]) for x in r["DauDiem"]])

insert("MonHoc_DauDiem",
       "INSERT INTO MonHoc_DauDiem(monhoc_id,daudiem_id,tile) VALUES(%s,%s,%s)",
       [(x["monhoc_id"],x["daudiem_id"],x["tile"]) for x in r["MonHoc_DauDiem"]])

insert("NamHoc",
       "INSERT INTO NamHoc(id,ten) VALUES(%s,%s)",
       [(x["id"],x["ten"]) for x in r["NamHoc"]])

insert("HocKi",
       "INSERT INTO HocKi(id,ten) VALUES(%s,%s)",
       [(x["id"],x["ten"]) for x in r["HocKi"]])

insert("KiHoc",
       "INSERT INTO KiHoc(id,namhoc_id,hocki_id) VALUES(%s,%s,%s)",
       [(x["id"],x["namhoc_id"],x["hocki_id"]) for x in r["KiHoc"]])

insert("MonHoc_KiHoc",
       "INSERT INTO MonHoc_KiHoc(id,monhoc_id,kihoc_id) VALUES(%s,%s,%s)",
       [(x["id"],x["monhoc_id"],x["kihoc_id"]) for x in r["MonHoc_KiHoc"]])

insert("LopHocPhan",
       "INSERT INTO LopHocPhan(id,ten,nhom,tothuchanh,sisotoida,monhockihoc_id) VALUES(%s,%s,%s,%s,%s,%s)",
       [(x["id"],x["ten"],x["nhom"],x["tothuchanh"],x["sisotoida"],x["monhockihoc_id"]) for x in r["LopHocPhan"]])

insert("GiangVien_LopHocPhan",
       "INSERT INTO GiangVien_LopHocPhan(giangvien_id,lophocphan_id) VALUES(%s,%s)",
       [(x["giangvien_id"],x["lophocphan_id"]) for x in r["GiangVien_LopHocPhan"]])

insert("PhongHoc",
       "INSERT INTO PhongHoc(id,ten,succhua) VALUES(%s,%s,%s)",
       [(x["id"],x["ten"],x["succhua"]) for x in r["PhongHoc"]])

insert("TuanHoc",
       "INSERT INTO TuanHoc(id,ten) VALUES(%s,%s)",
       [(x["id"],x["ten"]) for x in r["TuanHoc"]])

insert("NgayHoc",
       "INSERT INTO NgayHoc(id,ten) VALUES(%s,%s)",
       [(x["id"],x["ten"]) for x in r["NgayHoc"]])

insert("KipHoc",
       "INSERT INTO KipHoc(id,ten) VALUES(%s,%s)",
       [(x["id"],x["ten"]) for x in r["KipHoc"]])

insert("BuoiHoc",
       "INSERT INTO BuoiHoc(id,lophocphan_id,tuan_id,ngay_id,kiphoc_id,phonghoc_id,giangvien_id) VALUES(%s,%s,%s,%s,%s,%s,%s)",
       [(x["id"],x["lophocphan_id"],x["tuan_id"],x["ngay_id"],x["kiphoc_id"],x["phonghoc_id"],x["giangvien_id"])
        for x in r["BuoiHoc"]])

insert("DiemHeChu",
       "INSERT INTO DiemHeChu(id,ten,diem4,diem10_min,diem10_max,mota) VALUES(%s,%s,%s,%s,%s,%s)",
       [(x["id"],x["ten"],x["diem4"],x["diem10_min"],x["diem10_max"],x.get("mota",""))
        for x in r["DiemHeChu"]])

insert("LoaiHocLuc",
       "INSERT INTO LoaiHocLuc(id,ten,diem_min,diem_max,mota) VALUES(%s,%s,%s,%s,%s)",
       [(x["id"],x["ten"],x["diem_min"],x["diem_max"],x.get("mota",""))
        for x in r["LoaiHocLuc"]])

insert("DangKyHoc",
       "INSERT INTO DangKyHoc(id,ngaydangky,trangthai,sinhvien_id,lophocphan_id) VALUES(%s,%s,%s,%s,%s)",
       [(x["id"],x.get("ngaydangky", "2026-05-04 00:00:00"),x.get("trangthai", "Đã khóa"),x["sinhvien_id"],x["lophocphan_id"]) for x in r["DangKyHoc"]])

insert("DiemThanhPhan",
       "INSERT INTO DiemThanhPhan(dangkyhoc_id,daudiem_id,diem) VALUES(%s,%s,%s)",
       [(x["dangkyhoc_id"],x["daudiem_id"],x["diem"]) for x in r["DiemThanhPhan"]])

insert("KetQuaMon",
       "INSERT INTO KetQuaMon(id,dangkyhoc_id,diem,diemhechu_id) VALUES(%s,%s,%s,%s)",
       [(x["id"],x["dangkyhoc_id"],x["diem"],x["diemhechu_id"]) for x in r["KetQuaMon"]])

insert("TONGKET_HOCKI",
       "INSERT INTO TONGKET_HOCKI(id,sinhvien_id,kihoc_id,loaihocluc_id,gpa_he10,gpa_he4,tongtinchi,sotinchi_dat) VALUES(%s,%s,%s,%s,%s,%s,%s,%s)",
       [(x["id"],x["sinhvien_id"],x["kihoc_id"],x["loaihocluc_id"],x["gpa_he10"],x["gpa_he4"],x["tongtinchi"],x["sotinchi_dat"])
        for x in r["TONGKET_HOCKI"]])

# ── Optimizations ────────────────────────────────────────────
print("\n=== Applying Optimizations ===")
OPT_FILE = os.path.join(SCRIPT_DIR, "db_optimization.sql")
if os.path.exists(OPT_FILE):
    with open(OPT_FILE, "r", encoding="utf-8") as f:
        opt_text = f.read()
    
    views_indexes = opt_text.split("-- TRIGGERS")[0]
    for stmt in views_indexes.split(";"):
        stmt = stmt.strip()
        if stmt:
            try:
                cursor.execute(stmt)
            except Exception as e:
                print(f"  Opt warning: {e}")
    conn.commit()
    print("✓ Indexes and Views applied")

conn.close()
print("\n" + "=" * 60)
print("✓ Import complete!")
print("=" * 60)
