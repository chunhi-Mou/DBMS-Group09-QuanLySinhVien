# data-generator/gen_phase5_schedule.py
import json, os, random
from collections import defaultdict

DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
CURRENT_KIHOC_ID = 8

def _save(ctx, name, data):
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(os.path.join(DATA_DIR, f"{name}.json"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"  [SAVED] {name:30} {len(data):5d} records")
    ctx[name.lower()] = data

# Hardcoded KiHoc 8 sections matching dataSample.md
# (mamh, nhom, gv_username, ngay_id, kip_id, phong_id, sisotoida)
FIXED_K8 = [
    ("SKD1103",      5, "gv_test", 4, 1,  1, 80),
    ("INT1434_CLC",  5, "gv_nqh",  6, 1, 13, 80),
    ("INT14167_CLC", 2, "gv_ntk",  2, 2, 39, 80),
    ("INT1341_CLC",  5, "gv_dhl",  2, 1, 42, 80),
    ("INT1340_CLC",  6, "gv_nmh",  6, 2,  7, 80),
    ("BAS1152",      6, "gv_dtd",  3, 2, 22, 80),
    ("INT13187_CLC", 1, "gv_test", 5, 2,  2, 80),
    ("INT1313",      1, "gv_test", 5, 3,  1, 10),
    ("INT1430",      1, "gv_test", 6, 1, 20, 80),
]

def run(ctx: dict) -> dict:
    random.seed(42)

    mamh_to_id      = ctx["mamh_to_id"]
    named_gv_ids    = ctx["named_gv_ids"]
    all_gv_ids      = ctx["all_gv_ids"]
    giang_vien      = ctx["giang_vien"]
    monhoc_by_nganh = ctx["monhoc_by_nganh"]
    mon_hoc         = ctx["monhoc"]
    mamh_to_type    = ctx.get("mamh_to_type", {})
    mid_nganh_count = ctx.get("mid_nganh_count", {})

    bomon_by_mid = {m["id"]: m["bomon_id"] for m in mon_hoc}
    gv_by_bomon  = defaultdict(list)
    for gv in giang_vien:
        gv_by_bomon[gv["bomon_id"]].append(gv["thanhvien_id"])

    def pick_gv(mid):
        bm = bomon_by_mid.get(mid, 1)
        pool = gv_by_bomon.get(bm) or all_gv_ids
        return random.choice(pool)

    gv_slots   = set()
    room_slots = set()

    def find_slot(ki_id, gv_id):
        for _ in range(2000):
            ngay  = random.randint(1, 6)
            kip   = random.randint(1, 6)
            phong = random.randint(1, 50)
            if (ki_id,gv_id,ngay,kip) not in gv_slots and (ki_id,phong,ngay,kip) not in room_slots:
                gv_slots.add((ki_id,gv_id,ngay,kip))
                room_slots.add((ki_id,phong,ngay,kip))
                return ngay, kip, phong
        return None

    mk_id_ctr = 1; lhp_id_ctr = 1; bh_id_ctr = 1
    mk_by_mon_ki  = {}
    lhp_by_mid_ki   = defaultdict(lambda: defaultdict(list))
    lhp_by_mamh_ki  = defaultdict(lambda: defaultdict(list))
    lhp_sisotoida   = {}
    lhp_by_ngay_kip = {}

    monhoc_kihoc, lop_hoc_phan, gv_lhp, buoi_hoc = [], [], [], []

    def register_mk(mid, ki_id):
        nonlocal mk_id_ctr
        key = (mid, ki_id)
        if key not in mk_by_mon_ki:
            monhoc_kihoc.append({"id":mk_id_ctr,"monhoc_id":mid,"kihoc_id":ki_id})
            mk_by_mon_ki[key] = mk_id_ctr
            mk_id_ctr += 1
        return mk_by_mon_ki[key]

    def add_lhp(mid, ki_id, mamh, nhom, siso, gv_id, ngay, kip, phong):
        nonlocal lhp_id_ctr, bh_id_ctr
        mk = register_mk(mid, ki_id)
        is_lab = mamh_to_type.get(mamh, "theory") == "lab"
        lop_hoc_phan.append({
            "id":lhp_id_ctr,"ten":mamh,"nhom":nhom,
            "tothuchanh": 30 if is_lab else 0,
            "sisotoida":siso,"monhockihoc_id":mk
        })
        gv_lhp.append({"giangvien_id":gv_id,"lophocphan_id":lhp_id_ctr})
        # BuoiHoc has a global UNIQUE(tuan_id, ngay_id, kiphoc_id, phonghoc_id)
        # constraint with no ki_id scope — only generate rows for the current semester.
        if ki_id == CURRENT_KIHOC_ID:
            for tuan in range(1, 16):
                buoi_hoc.append({
                    "id":bh_id_ctr,"lophocphan_id":lhp_id_ctr,
                    "tuan_id":tuan,"ngay_id":ngay,"kiphoc_id":kip,
                    "phonghoc_id":phong,"giangvien_id":gv_id
                })
                bh_id_ctr += 1
        lhp_by_mid_ki[mid][ki_id].append(lhp_id_ctr)
        lhp_by_mamh_ki[mamh][ki_id].append(lhp_id_ctr)
        lhp_sisotoida[lhp_id_ctr] = siso
        lhp_by_ngay_kip[lhp_id_ctr] = (ngay, kip)
        lhp_id_ctr += 1

    all_mids = sorted({mid for mids in monhoc_by_nganh.values() for mid in mids})
    mamh_by_mid = {m["id"]: m["mamh"] for m in mon_hoc}

    for ki_id in range(1, CURRENT_KIHOC_ID + 1):

        if ki_id == CURRENT_KIHOC_ID:
            for mamh, nhom, gv_uname, ngay, kip, phong, siso in FIXED_K8:
                mid   = mamh_to_id[mamh]
                gv_id = named_gv_ids[gv_uname]
                add_lhp(mid, ki_id, mamh, nhom, siso, gv_id, ngay, kip, phong)
                gv_slots.add((ki_id, gv_id, ngay, kip))
                room_slots.add((ki_id, phong, ngay, kip))

        open_count = max(1, int(len(all_mids) * 0.90))
        for mid in random.sample(all_mids, open_count):
            mamh = mamh_by_mid[mid]
            n_majors = mid_nganh_count.get(mid, 1)
            n_sections = random.randint(4, 6) if n_majors >= 3 else random.randint(2, 4)
            for nhom_n in range(1, n_sections + 1):
                gv_id = pick_gv(mid)
                slot  = find_slot(ki_id, gv_id)
                if slot is None:
                    continue
                ngay, kip, phong = slot
                siso = 80
                add_lhp(mid, ki_id, mamh, nhom_n, siso, gv_id, ngay, kip, phong)

    ctx["mk_id_by_mon_ki"]  = mk_by_mon_ki
    ctx["lhp_by_mid_ki"]    = dict(lhp_by_mid_ki)
    ctx["lhp_by_mamh_ki"]   = dict(lhp_by_mamh_ki)
    ctx["lhp_sisotoida"]    = lhp_sisotoida
    ctx["lhp_by_ngay_kip"]  = lhp_by_ngay_kip
    ctx["fixed_k8_lhp_ids"] = {
        mamh: lhp_by_mamh_ki[mamh][CURRENT_KIHOC_ID][0]
        for mamh, *_ in FIXED_K8
        if lhp_by_mamh_ki[mamh][CURRENT_KIHOC_ID]
    }

    _save(ctx,"MonHoc_KiHoc",         monhoc_kihoc)
    _save(ctx,"LopHocPhan",           lop_hoc_phan)
    _save(ctx,"GiangVien_LopHocPhan", gv_lhp)
    _save(ctx,"BuoiHoc",              buoi_hoc)
    return ctx

if __name__ == "__main__":
    import gen_phase1_dict, gen_phase2_structure, gen_phase3_catalog, gen_phase4_users
    ctx = gen_phase1_dict.run({})
    ctx = gen_phase2_structure.run(ctx)
    ctx = gen_phase3_catalog.run(ctx)
    ctx = gen_phase4_users.run(ctx)
    run(ctx)
