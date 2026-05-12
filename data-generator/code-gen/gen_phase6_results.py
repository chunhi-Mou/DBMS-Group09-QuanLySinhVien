# data-generator/gen_phase6_results.py
import json, os, random, datetime
from collections import defaultdict

DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
CURRENT_KIHOC_ID = 8

# Ngày bắt đầu đợt đăng ký cho từng kỳ (Kỳ 1 = tháng 8, Kỳ 2 = tháng 11)
_REG_START = {
    1: datetime.datetime(2022, 8, 22),
    2: datetime.datetime(2022, 11, 21),
    3: datetime.datetime(2023, 8, 21),
    4: datetime.datetime(2023, 11, 20),
    5: datetime.datetime(2024, 8, 19),
    6: datetime.datetime(2024, 11, 18),
    7: datetime.datetime(2025, 8, 18),
    8: datetime.datetime(2025, 11, 17),
}
_REG_SPAN_DAYS = {ki: 72 if ki % 2 == 0 else 21 for ki in range(1, 9)}


def _reg_ts(ki_id):
    base = _REG_START[ki_id]
    delta = datetime.timedelta(
        days=random.randint(0, _REG_SPAN_DAYS[ki_id]),
        hours=random.randint(7, 21),
        minutes=random.randint(0, 59),
        seconds=random.randint(0, 59),
    )
    return (base + delta).strftime("%Y-%m-%d %H:%M:%S")

def _save(name, data):
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(os.path.join(DATA_DIR, f"{name}.json"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"  [SAVED] {name:30} {len(data):5d} records")

def run(ctx: dict) -> dict:
    random.seed(42)

    diem_he_chu     = ctx["diemhechu"]
    loai_hoc_luc    = ctx["loaihocluc"]
    weights_by_mid  = ctx["weights_by_monhoc"]
    sotc_by_mid     = ctx["sotc_by_monhoc"]
    lhp_by_mid_ki   = ctx["lhp_by_mid_ki"]
    lhp_sisotoida   = ctx["lhp_sisotoida"]
    lhp_ngay_kip    = ctx["lhp_by_ngay_kip"]
    monhoc_by_nganh = ctx["monhoc_by_nganh"]
    fixed_k8        = ctx["fixed_k8_lhp_ids"]
    sv_ids          = ctx["sv_ids"]
    all_sv          = ctx["all_sv"]
    sinhvien_nganh  = ctx["sinhvien_nganh"]
    curriculum_plan = ctx["curriculum_plan"]
    mamh_to_id      = ctx["mamh_to_id"]

    nganh_by_masv = {sn["sinhvien_id"]: sn["nganh_id"] for sn in sinhvien_nganh}

    dang_ky_hoc, diem_thanh_phan, ket_qua_mon, tong_ket = [], [], [], []
    dk_id = 1; kq_id = 1; tk_id = 1

    lhp_enroll    = defaultdict(int)
    sv_ki_slots   = defaultdict(set)
    sv_ki_passed  = defaultdict(set)       # môn pass (điểm >= 4.0)
    sv_enrolled   = defaultdict(set)       # TẤT CẢ môn đã đăng ký (bất kể pass/fail)

    def get_grade(score):
        for g in sorted(diem_he_chu, key=lambda x: -x["diem10_min"]):
            if score >= g["diem10_min"]:
                return g["id"], g["diem4"]
        return 9, 0.0

    def get_lhl(gpa4):
        for l in sorted(loai_hoc_luc, key=lambda x: -x["diem_min"]):
            if gpa4 >= l["diem_min"]:
                return l["id"]
        return 6

    def biased_score(target_gpa4):
        if target_gpa4 >= 3.6: return round(random.uniform(8.5, 10.0), 1)
        if target_gpa4 >= 3.2: return round(random.uniform(7.5, 9.0),  1)
        if target_gpa4 >= 2.5: return round(random.uniform(6.0, 8.0),  1)
        if target_gpa4 >= 2.0: return round(random.uniform(4.5, 7.0),  1)
        return round(random.uniform(0.0, 4.5), 1) if random.random() < 0.7 else round(random.uniform(4.5, 6.5), 1)

    def enroll(masv, lhp_id, ki_id, mid, ts=None):
        nonlocal dk_id
        if mid in sv_enrolled[masv]:
            return False
        if lhp_enroll[lhp_id] >= lhp_sisotoida.get(lhp_id, 100):
            return False
        slot = lhp_ngay_kip.get(lhp_id)
        if slot and slot in sv_ki_slots[(masv, ki_id)]:
            return False
        if slot:
            sv_ki_slots[(masv, ki_id)].add(slot)
        lhp_enroll[lhp_id] += 1
        sv_enrolled[masv].add(mid)
        dang_ky_hoc.append({"id": dk_id, "ngaydangky": ts or _reg_ts(ki_id),
                             "trangthai": "Đã khóa",
                             "sinhvien_id": masv, "lophocphan_id": lhp_id})
        dk_id += 1
        return True

    def grade_enrollment(masv, lhp_id, ki_id, mid, target_gpa4=None):
        nonlocal kq_id
        dk = dk_id - 1
        weights = weights_by_mid.get(mid, [(1, 0.1), (3, 0.3), (5, 0.6)])
        target_final = biased_score(target_gpa4)
        scores = []
        for daudiem_id, tile in weights:
            if daudiem_id == 5:
                s = target_final
            elif daudiem_id == 1:
                s = round(min(10.0, target_final + random.uniform(0.0, 1.5)), 1)
            else:
                s = round(max(0.0, min(10.0, target_final + random.uniform(-1.5, 1.5))), 1)
            scores.append((daudiem_id, s))
        w_map = {d: t for d, t in weights}
        total = round(sum(s * w_map[d] for d, s in scores), 1)
        total = max(0.0, min(10.0, total))
        for daudiem_id, score in scores:
            diem_thanh_phan.append({"dangkyhoc_id":dk,"daudiem_id":daudiem_id,"diem":score})
        grade_id, grade4 = get_grade(total)
        ket_qua_mon.append({"id":kq_id,"dangkyhoc_id":dk,"diem":total,"diemhechu_id":grade_id})
        kq_id += 1
        return total, grade4

    def finalize_semester(masv, ki_id, records):
        """records = list of (diem10, diem4, sotc) tuples"""
        nonlocal tk_id
        if not records: return
        total_tc = sum(r[2] for r in records)
        if total_tc == 0: return
        gpa10    = round(sum(r[0]*r[2] for r in records) / total_tc, 2)
        gpa4     = round(sum(r[1]*r[2] for r in records) / total_tc, 2)
        lhl_id   = get_lhl(gpa4)
        tc_dat   = sum(r[2] for r in records if r[0] >= 4.0)
        tong_ket.append({"id":tk_id,"sinhvien_id":masv,"kihoc_id":ki_id,
                         "loaihocluc_id":lhl_id,"gpa_he10":gpa10,"gpa_he4":gpa4,
                         "tongtinchi":total_tc,"sotinchi_dat":tc_dat})
        tk_id += 1

    def pick_lhp(mid, ki_id):
        options = lhp_by_mid_ki.get(mid, {}).get(ki_id, [])
        for lhp_id in random.sample(options, len(options)):
            if lhp_enroll[lhp_id] < lhp_sisotoida.get(lhp_id, 100):
                return lhp_id
        return None

    def get_planned_mids(nganh_id, rel_sem, enrolled):
        """Lấy danh sách monhoc_id theo curriculum plan, loại trừ môn đã enrolled."""
        major_mids = set(monhoc_by_nganh.get(nganh_id, []))
        plan = curriculum_plan.get(nganh_id, [])
        if rel_sem < len(plan):
            mamhs = plan[rel_sem]
            return [mamh_to_id[m] for m in mamhs
                    if m in mamh_to_id
                    and mamh_to_id[m] not in enrolled
                    and mamh_to_id[m] in major_mids]
        remaining = [m for m in major_mids if m not in enrolled]
        random.shuffle(remaining)
        return remaining[:6]

    def get_enrollable_mids(ki_id, enrolled, tried):
        """Trả về danh sách monhoc_id có LHP section còn chỗ tại ki_id, chưa enrolled/tried."""
        result = []
        for mid, ki_data in lhp_by_mid_ki.items():
            if mid in enrolled or mid in tried:
                continue
            options = ki_data.get(ki_id, [])
            if any(lhp_enroll[lid] < lhp_sisotoida.get(lid, 100) for lid in options):
                result.append(mid)
        return result

    def enroll_historical(masv, nganh_id, ki_id, entry_ki, target, passed):
        rel_sem = ki_id - entry_ki
        target_mids = get_planned_mids(nganh_id, rel_sem, sv_enrolled[masv])

        records = []
        tried = set()

        def try_mid(mid):
            if mid in tried or mid in sv_enrolled[masv]:
                return False
            tried.add(mid)
            lhp_id = pick_lhp(mid, ki_id)
            if lhp_id is None:
                return False
            if not enroll(masv, lhp_id, ki_id, mid):
                return False
            total, grade4 = grade_enrollment(masv, lhp_id, ki_id, mid, target_gpa4=target)
            if total >= 4.0:
                passed.add(mid)
            records.append((total, grade4, sotc_by_mid.get(mid, 3)))
            return True

        for mid in target_mids:
            try_mid(mid)

        # Bổ sung cho đến khi đủ 5 môn VÀ 12TC, chỉ chọn môn CÓ section tại ki này
        current_tc = lambda: sum(r[2] for r in records)
        if len(records) < 5 or current_tc() < 12:
            nganh_mids = set(monhoc_by_nganh.get(nganh_id, []))
            available = get_enrollable_mids(ki_id, sv_enrolled[masv], tried)
            # Ưu tiên môn trong ngành trước, rồi ngoài ngành
            in_major = [m for m in available if m in nganh_mids]
            out_major = [m for m in available if m not in nganh_mids]
            random.shuffle(in_major)
            random.shuffle(out_major)
            for mid in in_major + out_major:
                if len(records) >= 5 and current_tc() >= 12:
                    break
                try_mid(mid)

        return records

    SPECIAL_TARGETS = {
        "sv_test":     3.0,
        "sv_xuat_sac": 3.8,
        "sv_gioi":     3.4,
        "sv_kha":      2.8,
        "sv_tb":       2.2,
        "sv_kem":      0.5,
    }

    # sv_test hoãn 7 môn dataSample khỏi lịch sử → dành cho ki=8
    _SV_TEST_K8 = ["SKD1103","INT1434_CLC","INT14167_CLC","INT1341_CLC",
                   "INT1340_CLC","BAS1152","INT13187_CLC"]
    sv_test_deferred = {mamh_to_id[m] for m in _SV_TEST_K8 if m in mamh_to_id}

    # B22 special students (entry ki_id=1), skip sv_ktoan
    for username, (_, masv, nganh_id) in sv_ids.items():
        if username == "sv_ktoan":
            continue
        target = SPECIAL_TARGETS.get(username, 3.0)
        entry_ki = 1

        if username == "sv_test":
            sv_enrolled[masv] |= sv_test_deferred

        for ki_id in range(entry_ki, CURRENT_KIHOC_ID):
            records = enroll_historical(masv, nganh_id, ki_id, entry_ki, target, sv_ki_passed[masv])
            finalize_semester(masv, ki_id, records)

        if username == "sv_test":
            sv_enrolled[masv] -= sv_test_deferred
            timestamps = [
                "2025-12-11 10:53:18", "2025-12-11 10:53:27", "2025-12-11 10:53:33",
                "2025-12-11 10:53:38", "2025-12-11 10:53:39", "2025-12-11 10:53:45",
                "2026-01-27 16:23:50",
            ]
            for mamh, ts in zip(_SV_TEST_K8, timestamps):
                mid = mamh_to_id.get(mamh)
                if mid:
                    lhp_id = fixed_k8.get(mamh)
                    if lhp_id:
                        enroll(masv, lhp_id, CURRENT_KIHOC_ID, mid, ts=ts)
        else:
            k8_mids = get_planned_mids(nganh_id, CURRENT_KIHOC_ID - entry_ki, sv_enrolled[masv])
            if len(k8_mids) < 5:
                tried = set(k8_mids)
                available = get_enrollable_mids(CURRENT_KIHOC_ID, sv_enrolled[masv], tried)
                random.shuffle(available)
                k8_mids = k8_mids + available[:max(0, 5 - len(k8_mids))]
            for mid in k8_mids:
                lhp_id = pick_lhp(mid, CURRENT_KIHOC_ID)
                if lhp_id:
                    enroll(masv, lhp_id, CURRENT_KIHOC_ID, mid)

    # sv_ktoan: B23 cohort (entry ki_id=3), ki_id 3-7 only, ki_id=8 = ZERO records
    _, sv_ktoan_masv, sv_ktoan_nganh = sv_ids["sv_ktoan"]
    entry_ki_ktoan = 3
    for ki_id in range(entry_ki_ktoan, CURRENT_KIHOC_ID):
        records = enroll_historical(sv_ktoan_masv, sv_ktoan_nganh, ki_id, entry_ki_ktoan, 2.8, sv_ki_passed[sv_ktoan_masv])
        finalize_semester(sv_ktoan_masv, ki_id, records)
    # ki_id=8: ZERO records (key test case)

    # Fill INT1313 full class with 10 CNTT general students
    full_lhp_id = fixed_k8.get("INT1313")
    int1313_mid = mamh_to_id.get("INT1313")
    if full_lhp_id and int1313_mid:
        special_masvs_set = {v[1] for v in sv_ids.values()}
        cntt_general = [
            sv["masv"] for sv in all_sv
            if sv["masv"].startswith("B23DCCE") and sv["masv"] not in special_masvs_set
        ]
        for masv in cntt_general[:10]:
            enroll(masv, full_lhp_id, CURRENT_KIHOC_ID, int1313_mid)

    # General B23 students (250): ki_id 3-7 history, ki_id=8 register only (~60%)
    special_masvs = {v[1] for v in sv_ids.values()}
    entry_ki_b23 = 3

    for sv_rec in all_sv:
        masv = sv_rec["masv"]
        if masv in special_masvs:
            continue
        nganh_id = nganh_by_masv.get(masv, 1)
        target_gen = 3.0 if random.random() < 0.85 else 0.5

        for ki_id in range(entry_ki_b23, CURRENT_KIHOC_ID):
            records = enroll_historical(masv, nganh_id, ki_id, entry_ki_b23, target_gen, sv_ki_passed[masv])
            finalize_semester(masv, ki_id, records)

        if random.random() < 0.6:
            k8_mids = get_planned_mids(nganh_id, CURRENT_KIHOC_ID - entry_ki_b23, sv_enrolled[masv])
            if len(k8_mids) < 5:
                tried = set(k8_mids)
                available = get_enrollable_mids(CURRENT_KIHOC_ID, sv_enrolled[masv], tried)
                random.shuffle(available)
                k8_mids = k8_mids + available[:max(0, 5 - len(k8_mids))]
            n_reg = random.randint(5, 7)
            for mid in k8_mids[:n_reg]:
                lhp_id = pick_lhp(mid, CURRENT_KIHOC_ID)
                if lhp_id:
                    enroll(masv, lhp_id, CURRENT_KIHOC_ID, mid)

    # Dọn LHP ki=8 trống (0 SV) → GV không thấy lớp ma
    mk_ki8 = {m["id"] for m in ctx["monhoc_kihoc"] if m["kihoc_id"] == CURRENT_KIHOC_ID}
    lhp_k8_ids = {l["id"] for l in ctx["lophocphan"] if l["monhockihoc_id"] in mk_ki8}
    enrolled_lhp = {d["lophocphan_id"] for d in dang_ky_hoc}
    empty_k8 = lhp_k8_ids - enrolled_lhp

    if empty_k8:
        ctx["lophocphan"] = [l for l in ctx["lophocphan"] if l["id"] not in empty_k8]
        ctx["giangvien_lophocphan"] = [g for g in ctx["giangvien_lophocphan"] if g["lophocphan_id"] not in empty_k8]
        ctx["buoihoc"] = [b for b in ctx["buoihoc"] if b["lophocphan_id"] not in empty_k8]
        _save("LopHocPhan",           ctx["lophocphan"])
        _save("GiangVien_LopHocPhan", ctx["giangvien_lophocphan"])
        _save("BuoiHoc",              ctx["buoihoc"])

    _save("DangKyHoc",     dang_ky_hoc)
    _save("DiemThanhPhan", diem_thanh_phan)
    _save("KetQuaMon",     ket_qua_mon)
    _save("TONGKET_HOCKI", tong_ket)
    return ctx

if __name__ == "__main__":
    import gen_phase1_dict, gen_phase2_structure, gen_phase3_catalog, gen_phase4_users, gen_phase5_schedule
    ctx = gen_phase1_dict.run({})
    ctx = gen_phase2_structure.run(ctx)
    ctx = gen_phase3_catalog.run(ctx)
    ctx = gen_phase4_users.run(ctx)
    ctx = gen_phase5_schedule.run(ctx)
    run(ctx)
