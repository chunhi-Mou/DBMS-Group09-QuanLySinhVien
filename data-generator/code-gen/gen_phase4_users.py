# data-generator/gen_phase4_users.py
import json, os, random
import bcrypt
from collections import defaultdict

DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")

HO   = ['Nguyễn','Trần','Lê','Phạm','Hoàng','Vũ','Đặng','Bùi','Đinh','Lý']
DEM  = ['Văn','Thị','Đức','Thu','Minh','Thanh','Ngọc','Hồng','Hải','Gia']
TEN  = ['An','Bình','Dũng','Đạt','Hoa','Linh','Long','Mai','Nam','Tâm',
        'Sơn','Tùng','Tuấn','Hùng','Oanh','Hiền','Khoa','Thảo','Hương','Kiên']

# Real PTIT major codes used in student IDs (B23DC{CODE}{NNN})
MAJOR_CODES = {1: "CE", 2: "AT", 3: "PM", 4: "HT", 5: "KT"}

def _save(ctx, name, data):
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(os.path.join(DATA_DIR, f"{name}.json"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"  [SAVED] {name:30} {len(data):5d} records")
    ctx[name.lower()] = data

def _name(): return f"{random.choice(HO)} {random.choice(DEM)}", random.choice(TEN)
def _phone(): return "0"+"".join(str(random.randint(0,9)) for _ in range(9))
def _dob(teacher):
    y = random.randint(1975, 1990) if teacher else random.randint(2004, 2005)
    return f"{y}-{random.randint(1,12):02d}-{random.randint(1,28):02d}"

def _tv(tid, username, pw, hodem, ten, vaitro, teacher):
    return {"id":tid,"username":username,"password":pw,"hodem":hodem,"ten":ten,
            "ngaysinh":_dob(teacher),"email":f"{username}@ptit.edu.vn",
            "dt":_phone(),"vaitro":vaitro,"diachi_id":random.randint(1,120)}

def run(ctx: dict) -> dict:
    random.seed(42)
    pw = bcrypt.hashpw(b"123456", bcrypt.gensalt(10)).decode().replace("$2b$", "$2a$")
    lhc_by_nganh = ctx["lhc_by_nganh"]

    tv, gv, nv, sv, sv_nganh = [], [], [], [], []
    tid = 1

    # Admin
    tv.append(_tv(tid,"admin",pw,"Nguyễn Quản","Trị","ADMIN",True)); tid+=1

    # NhanVien — 3 staff with distinct roles
    nv_defs = [
        ("nv_test",   "Trần Giáo",  "Vụ",    "Giáo vụ"),
        ("nv_daotao", "Nguyễn Đào", "Tạo",   "Phòng đào tạo"),
        ("nv_hssv",   "Lê Hành",    "Chính", "Phòng công tác sinh viên"),
    ]
    for username, hodem, ten, vitri in nv_defs:
        tv.append(_tv(tid, username, pw, hodem, ten, "NHANVIEN", True))
        nv.append({"thanhvien_id": tid, "vitri": vitri})
        tid += 1

    # Named GVs
    named_gv_def = [
        ("gv_test","Trần Tuấn",   "Phong",1,"ThS"),
        ("gv_dhl", "Đặng Hoàng",  "Long", 1,"ThS"),
        ("gv_ntk", "Nguyễn Trọng","Khánh",2,"TS"),
        ("gv_dtd", "Đỗ Thị",      "Diệu", 7,"TS"),
        ("gv_nqh", "Nguyễn Quang","Hưng", 1,"TS"),
        ("gv_nmh", "Nguyễn Mạnh", "Hùng", 1,"TS"),
    ]
    named_gv_ids = {}
    for username,hodem,ten,bomon_id,hocham in named_gv_def:
        tv.append(_tv(tid,username,pw,hodem,ten,"GV",True))
        gv.append({"thanhvien_id":tid,"bomon_id":bomon_id,"hocham":hocham})
        named_gv_ids[username] = tid; tid+=1

    # 34 random GVs (total 40 with named) — ~5-6 per department
    _HOCHAM = ["ThS", "ThS", "TS", "TS", "PGS"]  # weighted toward ThS/TS, rare PGS
    for i in range(34):
        username = f"gv_{tid:03d}"
        hodem,ten = _name()
        bomon_id = (i % 7) + 1
        tv.append(_tv(tid,username,pw,hodem,ten,"GV",True))
        gv.append({"thanhvien_id":tid,"bomon_id":bomon_id,"hocham":random.choice(_HOCHAM)})
        tid+=1

    all_gv_ids = [g["thanhvien_id"] for g in gv]
    ctx["all_gv_ids"]    = all_gv_ids
    ctx["named_gv_ids"]  = named_gv_ids
    ctx["giang_vien"]    = gv

    # Special Students — B22 cohort (enrolled 2022, start ki_id=1)
    special_sv = [
        ("sv_test",     "B22DCCE001", 1, 0),
        ("sv_xuat_sac", "B22DCCE002", 1, 0),
        ("sv_gioi",     "B22DCCE003", 1, 0),
        ("sv_kha",      "B22DCCE004", 1, 0),
        ("sv_tb",       "B22DCCE005", 1, 1),
        ("sv_kem",      "B22DCCE006", 1, 1),
        ("sv_ktoan",    "B23DCKT001", 5, 0),
    ]
    sv_ids = {}
    for username,masv,nganh_id,lhc_idx in special_sv:
        hodem,ten = _name()
        lhc_id = lhc_by_nganh[nganh_id][lhc_idx]
        tv.append(_tv(tid,username,pw,hodem,ten,"SV",False))
        sv.append({"masv":masv,"thanhvien_id":tid,"lophanhchinh_id":lhc_id})
        sv_nganh.append({"sinhvien_id":masv,"nganh_id":nganh_id})
        sv_ids[username] = (tid, masv, nganh_id)
        tid+=1

    ctx["sv_ids"] = sv_ids

    # 500 general students (100 per major) — B23 cohort
    for nganh_id in range(1,6):
        code = MAJOR_CODES[nganh_id]
        lhc_ids = lhc_by_nganh[nganh_id]
        start = 2 if nganh_id in (1, 5) else 1
        for i in range(100):
            num = start + i
            masv = f"B23DC{code}{num:03d}"
            hodem,ten = _name()
            lhc_id = lhc_ids[0] if i < 50 else lhc_ids[1]
            tv.append(_tv(tid, masv.lower(), pw, hodem, ten, "SV", False))
            sv.append({"masv":masv,"thanhvien_id":tid,"lophanhchinh_id":lhc_id})
            sv_nganh.append({"sinhvien_id":masv,"nganh_id":nganh_id})
            tid+=1

    ctx["all_sv"]         = sv
    ctx["sinhvien_nganh"] = sv_nganh

    _save(ctx,"ThanhVien",      tv)
    _save(ctx,"SinhVien",       sv)
    _save(ctx,"GiangVien",      gv)
    _save(ctx,"NhanVien",       nv)
    _save(ctx,"SinhVien_Nganh", sv_nganh)
    return ctx

if __name__ == "__main__":
    import gen_phase1_dict, gen_phase2_structure
    ctx = gen_phase1_dict.run({})
    ctx = gen_phase2_structure.run(ctx)
    run(ctx)
