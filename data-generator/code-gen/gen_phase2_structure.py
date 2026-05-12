# data-generator/gen_phase2_structure.py
import json, os
from collections import defaultdict

DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")

def _save(ctx, name, data):
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(os.path.join(DATA_DIR, f"{name}.json"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"  [SAVED] {name:30} {len(data):5d} records")
    ctx[name.lower()] = data

def run(ctx: dict) -> dict:
    truong = [
        {"id": 1, "ten": "PTIT HN",  "mota": "Học viện Công nghệ Bưu chính Viễn thông - CS Hà Nội"},
        {"id": 2, "ten": "PTIT HCM", "mota": "Học viện Công nghệ Bưu chính Viễn thông - CS TP.HCM"},
    ]
    khoa = [
        {"id": 1, "ten": "Công nghệ thông tin 1",   "mota": "", "truong_id": 1},
        {"id": 2, "ten": "An toàn thông tin",        "mota": "", "truong_id": 1},
        {"id": 3, "ten": "Kỹ thuật điện tử",        "mota": "", "truong_id": 1},
        {"id": 4, "ten": "Quản trị kinh doanh",     "mota": "", "truong_id": 1},
        {"id": 5, "ten": "Khoa học cơ bản",         "mota": "", "truong_id": 1},
    ]
    bomon = [
        {"id": 1, "ten": "Lập trình và Thuật toán",  "mota": "", "khoa_id": 1},
        {"id": 2, "ten": "Hệ thống máy tính",        "mota": "", "khoa_id": 1},
        {"id": 3, "ten": "Mạng và Truyền thông",     "mota": "", "khoa_id": 1},
        {"id": 4, "ten": "An toàn thông tin",        "mota": "", "khoa_id": 2},
        {"id": 5, "ten": "Kỹ thuật phần mềm",       "mota": "", "khoa_id": 1},
        {"id": 6, "ten": "Kế toán - Tài chính",     "mota": "", "khoa_id": 4},
        {"id": 7, "ten": "Toán - Lý thuyết",        "mota": "", "khoa_id": 5},
    ]
    nganh_hoc = [
        {"id": 1, "ten": "Công nghệ thông tin",  "khoa_id": 1},
        {"id": 2, "ten": "An toàn thông tin",    "khoa_id": 2},
        {"id": 3, "ten": "Kỹ thuật phần mềm",   "khoa_id": 1},
        {"id": 4, "ten": "Hệ thống thông tin",  "khoa_id": 1},
        {"id": 5, "ten": "Kế toán",             "khoa_id": 4},
    ]

    # 2 classes per major = 10 total; real PTIT format: D23CQ{CODE}{NN}-B
    MAJOR_CODES = {1: "CE", 2: "AT", 3: "PM", 4: "HT", 5: "KT"}
    lop_hanh_chinh = []
    lhc_by_nganh = defaultdict(list)
    lhc_id = 1
    for nganh_id in range(1, 6):
        code = MAJOR_CODES[nganh_id]
        for k in range(1, 3):
            lop_hanh_chinh.append({"id": lhc_id, "tenlop": f"D23CQ{code}{k:02d}-B", "nganh_id": nganh_id})
            lhc_by_nganh[nganh_id].append(lhc_id)
            lhc_id += 1

    ctx["lhc_by_nganh"] = dict(lhc_by_nganh)

    _save(ctx, "Truong",        truong)
    _save(ctx, "Khoa",          khoa)
    _save(ctx, "BoMon",         bomon)
    _save(ctx, "NganhHoc",      nganh_hoc)
    _save(ctx, "LopHanhChinh",  lop_hanh_chinh)
    return ctx

if __name__ == "__main__":
    run({})
