# data-generator/gen_phase1_dict.py
import json, os, random

DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")

def _save(ctx, name, data):
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(os.path.join(DATA_DIR, f"{name}.json"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"  [SAVED] {name:30} {len(data):5d} records")
    ctx[name.lower()] = data

def run(ctx: dict) -> dict:
    random.seed(42)

    tuan_hoc = [{"id": i, "ten": f"Tuần {i}"} for i in range(1, 16)]

    ngay_hoc = [
        {"id": 1, "ten": "Thứ 2"}, {"id": 2, "ten": "Thứ 3"},
        {"id": 3, "ten": "Thứ 4"}, {"id": 4, "ten": "Thứ 5"},
        {"id": 5, "ten": "Thứ 6"}, {"id": 6, "ten": "Thứ 7"},
    ]
    kip_hoc = [
        {"id": 1, "ten": "07:00-08:50"}, {"id": 2, "ten": "09:00-10:50"},
        {"id": 3, "ten": "12:00-13:50"}, {"id": 4, "ten": "14:00-15:50"},
        {"id": 5, "ten": "16:00-17:50"}, {"id": 6, "ten": "18:00-19:50"},
    ]
    _buildings = ["A1", "A2", "A3", "B1", "B2"]
    phong_hoc = []
    _pid = 1
    for _bld in _buildings:
        for _floor in range(1, 6):
            for _room in range(1, 3):
                phong_hoc.append({
                    "id": _pid,
                    "ten": f"{_bld}-{_floor}{_room:02d}",
                    "succhua": 80
                })
                _pid += 1
    nam_hoc = [{"id": i, "ten": f"{2021+i}-{2022+i}"} for i in range(1, 5)]
    hoc_ki  = [{"id": 1, "ten": "Kỳ 1"}, {"id": 2, "ten": "Kỳ 2"}]
    ki_hoc  = [
        {"id": i, "namhoc_id": (i - 1) // 2 + 1, "hocki_id": (i - 1) % 2 + 1}
        for i in range(1, 9)
    ]
    dau_diem = [
        {"id": 1, "ten": "CC", "mota": "Chuyên cần"},
        {"id": 2, "ten": "BT", "mota": "Bài tập"},
        {"id": 3, "ten": "GK", "mota": "Giữa kỳ"},
        {"id": 4, "ten": "TH", "mota": "Thực hành"},
        {"id": 5, "ten": "CK", "mota": "Cuối kỳ"},
    ]
    diem_he_chu = [
        {"id": 1, "ten": "A+", "diem4": 4.0, "diem10_min": 9.0,  "diem10_max": 10.0, "mota": "Xuất sắc"},
        {"id": 2, "ten": "A",  "diem4": 3.7, "diem10_min": 8.5,  "diem10_max": 8.9,  "mota": "Giỏi"},
        {"id": 3, "ten": "B+", "diem4": 3.5, "diem10_min": 8.0,  "diem10_max": 8.4,  "mota": "Khá giỏi"},
        {"id": 4, "ten": "B",  "diem4": 3.0, "diem10_min": 7.0,  "diem10_max": 7.9,  "mota": "Khá"},
        {"id": 5, "ten": "C+", "diem4": 2.5, "diem10_min": 6.5,  "diem10_max": 6.9,  "mota": "TB Khá"},
        {"id": 6, "ten": "C",  "diem4": 2.0, "diem10_min": 5.5,  "diem10_max": 6.4,  "mota": "Trung bình"},
        {"id": 7, "ten": "D+", "diem4": 1.5, "diem10_min": 5.0,  "diem10_max": 5.4,  "mota": "TB Yếu"},
        {"id": 8, "ten": "D",  "diem4": 1.0, "diem10_min": 4.0,  "diem10_max": 4.9,  "mota": "Yếu"},
        {"id": 9, "ten": "F",  "diem4": 0.0, "diem10_min": 0.0,  "diem10_max": 3.9,  "mota": "Kém"},
    ]
    loai_hoc_luc = [
        {"id": 1, "ten": "Xuất sắc",   "diem_min": 3.6,  "diem_max": 4.0,  "mota": ""},
        {"id": 2, "ten": "Giỏi",       "diem_min": 3.2,  "diem_max": 3.59, "mota": ""},
        {"id": 3, "ten": "Khá",        "diem_min": 2.5,  "diem_max": 3.19, "mota": ""},
        {"id": 4, "ten": "Trung bình", "diem_min": 2.0,  "diem_max": 2.49, "mota": ""},
        {"id": 5, "ten": "Yếu",        "diem_min": 1.0,  "diem_max": 1.99, "mota": ""},
        {"id": 6, "ten": "Kém",        "diem_min": 0.0,  "diem_max": 0.99, "mota": ""},
    ]

    # Provincial distribution: ~30% Hanoi, rest from across Vietnam
    _PROVINCES = [
        ("Hà Nội",           ["Đống Đa", "Thanh Xuân", "Cầu Giấy", "Hoàng Mai", "Hai Bà Trưng", "Ba Đình"]),
        ("TP. Hồ Chí Minh",  ["Quận 1", "Quận 3", "Bình Thạnh", "Gò Vấp", "Tân Bình"]),
        ("Hải Phòng",        ["Lê Chân", "Ngô Quyền", "Hồng Bàng", "Kiến An"]),
        ("Nghệ An",          ["Thành phố Vinh", "Diễn Châu", "Quỳnh Lưu"]),
        ("Thanh Hóa",        ["Thành phố Thanh Hóa", "Sầm Sơn", "Bỉm Sơn"]),
        ("Nam Định",         ["Thành phố Nam Định", "Mỹ Lộc", "Vụ Bản"]),
        ("Thái Bình",        ["Thành phố Thái Bình", "Đông Hưng", "Kiến Xương"]),
        ("Bắc Ninh",         ["Thành phố Bắc Ninh", "Từ Sơn", "Tiên Du"]),
        ("Hà Tĩnh",          ["Thành phố Hà Tĩnh", "Hồng Lĩnh", "Can Lộc"]),
        ("Đà Nẵng",          ["Hải Châu", "Thanh Khê", "Sơn Trà", "Ngũ Hành Sơn"]),
    ]
    _WEIGHTS = [30, 15, 10, 8, 8, 7, 7, 5, 5, 5]

    def _pick_province():
        r = random.randint(1, sum(_WEIGHTS))
        cumul = 0
        for (tinh, qdist), w in zip(_PROVINCES, _WEIGHTS):
            cumul += w
            if r <= cumul:
                return tinh, random.choice(qdist)
        return _PROVINCES[0][0], random.choice(_PROVINCES[0][1])

    dia_chi = []
    for i in range(1, 121):
        tinhthanh, quanhuyen = _pick_province()
        dia_chi.append({
            "id": i, "sonha": f"Số {random.randint(1, 200)}", "toanha": "",
            "xompho": "", "phuongxa": "", "quanhuyen": quanhuyen,
            "tinhthanh": tinhthanh, "truong_id": None
        })

    _save(ctx, "TuanHoc",    tuan_hoc)
    _save(ctx, "NgayHoc",    ngay_hoc)
    _save(ctx, "KipHoc",     kip_hoc)
    _save(ctx, "PhongHoc",   phong_hoc)
    _save(ctx, "NamHoc",     nam_hoc)
    _save(ctx, "HocKi",      hoc_ki)
    _save(ctx, "KiHoc",      ki_hoc)
    _save(ctx, "DauDiem",    dau_diem)
    _save(ctx, "DiemHeChu",  diem_he_chu)
    _save(ctx, "LoaiHocLuc", loai_hoc_luc)
    _save(ctx, "DiaChi",     dia_chi)
    return ctx

if __name__ == "__main__":
    run({})
