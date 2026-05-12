# data-generator/gen_phase3_catalog.py
import json, os

DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")

def _save(ctx, name, data):
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(os.path.join(DATA_DIR, f"{name}.json"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"  [SAVED] {name:30} {len(data):5d} records")
    ctx[name.lower()] = data

# (mamh, ten, sotc, bomon_id, course_type)
COURSES = [
    ("SKD1103",      "Kỹ năng tạo lập Văn bản",                1, 7, "theory"),
    ("BAS1152",      "Chủ nghĩa xã hội khoa học",              2, 7, "theory"),
    ("BAS1203",      "Toán rời rạc",                           3, 7, "theory"),
    ("BAS1201",      "Giải tích 1",                            3, 7, "theory"),
    ("BAS1202",      "Giải tích 2",                            3, 7, "theory"),
    ("BAS1106",      "Đại số tuyến tính",                      3, 7, "theory"),
    ("INT1154",      "Tin học cơ sở 1",                        2, 1, "lab"),
    ("INT1155",      "Tin học cơ sở 2",                        2, 1, "lab"),
    ("GD1001",       "Triết học Mác-Lênin",                    3, 7, "theory"),
    ("GD1002",       "Kinh tế chính trị Mác-Lênin",            2, 7, "theory"),
    ("GD1003",       "Tư tưởng Hồ Chí Minh",                  2, 7, "theory"),
    ("GD1004",       "Lịch sử Đảng Cộng sản Việt Nam",        2, 7, "theory"),
    ("GD1005",       "Pháp luật đại cương",                    2, 7, "theory"),
    ("BAS1301",      "Vật lý đại cương",                       3, 7, "theory"),
    ("BAS1401",      "Xác suất thống kê",                      3, 7, "theory"),
    ("ENG1001",      "Tiếng Anh 1",                            3, 7, "theory"),
    ("ENG1002",      "Tiếng Anh 2",                            3, 7, "theory"),
    ("ENG1003",      "Tiếng Anh chuyên ngành",                 3, 7, "theory"),
    ("INT1313",      "Cơ sở dữ liệu",                          3, 2, "theory"),
    ("INT1430",      "Mạng máy tính",                          3, 3, "theory"),
    ("INT1434_CLC",  "Lập trình web",                          3, 1, "lab"),
    ("INT14167_CLC", "Hệ quản trị Cơ sở dữ liệu",             3, 2, "lab"),
    ("INT1341_CLC",  "Nhập môn trí tuệ nhân tạo",              3, 1, "theory"),
    ("INT1340_CLC",  "Nhập môn CNPM",                          3, 5, "theory"),
    ("INT13187_CLC", "Thực tập cơ sở",                         4, 1, "lab"),
    ("INT1316",      "Kiến trúc máy tính",                     3, 2, "theory"),
    ("INT1307",      "Cấu trúc dữ liệu & Giải thuật",         3, 1, "theory"),
    ("INT1305",      "Lập trình hướng đối tượng",              3, 1, "lab"),
    ("INT1201",      "Hệ điều hành",                           3, 3, "theory"),
    ("INT1202",      "Lập trình C/C++",                        3, 1, "lab"),
    ("INT1421",      "Phát triển ứng dụng di động",            3, 1, "lab"),
    ("INT1422",      "Điện toán đám mây",                      3, 3, "theory"),
    ("INT1423",      "Khai phá dữ liệu",                       3, 2, "theory"),
    ("SEC1201",      "Mật mã học",                             3, 4, "theory"),
    ("SEC1202",      "Bảo mật mạng",                           3, 4, "theory"),
    ("SEC1203",      "An toàn ứng dụng web",                   3, 4, "lab"),
    ("SEC1204",      "Quản lý rủi ro an toàn thông tin",       2, 4, "theory"),
    ("SWE1201",      "Kiểm thử phần mềm",                      3, 5, "lab"),
    ("SWE1202",      "Quản lý dự án CNTT",                     3, 5, "theory"),
    ("SWE1203",      "Phát triển phần mềm Agile",              3, 5, "theory"),
    ("SWE1204",      "Thiết kế hướng đối tượng",               3, 5, "theory"),
    ("IS1201",       "Phân tích thiết kế hệ thống thông tin",  3, 5, "theory"),
    ("IS1202",       "Quản trị cơ sở dữ liệu nâng cao",       3, 2, "lab"),
    ("ACC1101",      "Nguyên lý kế toán",                      3, 6, "theory"),
    ("ACC1102",      "Kế toán tài chính",                      3, 6, "theory"),
    ("ACC1103",      "Kinh tế vi mô",                          3, 6, "theory"),
    ("ACC1104",      "Kinh tế vĩ mô",                          3, 6, "theory"),
    ("ACC1105",      "Tài chính doanh nghiệp",                 3, 6, "theory"),
    ("ACC1106",      "Kế toán quản trị",                       3, 6, "theory"),
    ("ACC1107",      "Kiểm toán",                              3, 6, "theory"),
    ("ACC1108",      "Phân tích tài chính",                    3, 6, "theory"),
    ("ACC1109",      "Kế toán máy",                            3, 6, "lab"),
    ("ACC1110",      "Luật kinh tế",                           2, 6, "theory"),
    ("ACC1111",      "Thống kê doanh nghiệp",                  3, 6, "theory"),
    ("ACC1112",      "Quản trị học",                           2, 6, "theory"),
]

_GEN = ["GD1001","GD1002","GD1003","GD1004","GD1005",
        "BAS1301","BAS1401","ENG1001","ENG1002","ENG1003"]

NGANH_MONHOC_MAP = {
    1: ([(m, "Bắt buộc") for m in [
        "SKD1103","BAS1152","BAS1203","BAS1201","BAS1202","BAS1106",
        "INT1154","INT1155","INT1313","INT1430","INT1434_CLC","INT14167_CLC",
        "INT1341_CLC","INT1340_CLC","INT13187_CLC","INT1316","INT1307","INT1305",
        "INT1201","INT1202","INT1421","INT1422","INT1423"]] +
       [(m, "Bắt buộc") for m in _GEN]),
    2: ([(m, "Bắt buộc") for m in [
        "SKD1103","BAS1152","BAS1203","BAS1201","BAS1106",
        "INT1154","INT1155","INT1313","INT1430","INT14167_CLC",
        "INT1341_CLC","INT1316","INT1307","INT1305","SEC1201","SEC1202",
        "INT1201","INT1202","INT1422","SEC1203","SEC1204"]] +
       [("INT1434_CLC","Tự chọn"),("INT1340_CLC","Tự chọn")] +
       [(m, "Bắt buộc") for m in _GEN]),
    3: ([(m, "Bắt buộc") for m in [
        "SKD1103","BAS1152","BAS1203","BAS1201","BAS1106",
        "INT1154","INT1155","INT1313","INT1430","INT1434_CLC","INT14167_CLC",
        "INT1341_CLC","INT1340_CLC","INT13187_CLC","INT1307","INT1305",
        "SWE1201","SWE1202","INT1201","INT1202","INT1421","INT1422",
        "SWE1203","SWE1204"]] +
       [(m, "Bắt buộc") for m in _GEN]),
    4: ([(m, "Bắt buộc") for m in [
        "SKD1103","BAS1152","BAS1203","BAS1201","BAS1106",
        "INT1154","INT1155","INT1313","INT1430","INT1434_CLC","INT14167_CLC",
        "INT1341_CLC","INT1340_CLC","INT13187_CLC","INT1316","INT1307",
        "INT1201","INT1202","INT1422","INT1423","IS1201","IS1202"]] +
       [("INT1305","Tự chọn")] +
       [(m, "Bắt buộc") for m in _GEN]),
    5: ([(m, "Bắt buộc") for m in [
        "SKD1103","BAS1152","BAS1201","BAS1106","INT1154","INT1155",
        "ACC1101","ACC1102","ACC1103","ACC1104","ACC1105","ACC1106","ACC1107","ACC1108",
        "ACC1109","ACC1110","ACC1111","ACC1112"]] +
       [("BAS1203","Tự chọn")] +
       [(m, "Bắt buộc") for m in _GEN]),
}

# Maps nganh_id -> list of relative semesters (0-indexed), each a list of mamh codes.
# Relative semester 0 = first semester at university for that cohort.
CURRICULUM_PLAN = {
    1: [  # CNTT
        ["SKD1103", "GD1001", "BAS1201", "BAS1106", "INT1154", "ENG1001"],          # s0: 1+3+3+3+2+3=15
        ["GD1002", "GD1003", "BAS1202", "INT1155", "ENG1002", "BAS1301"],           # s1: 2+2+3+2+3+3=15
        ["GD1004", "GD1005", "BAS1203", "BAS1401", "INT1202", "INT1316"],           # s2: 2+2+3+3+3+3=16
        ["BAS1152", "INT1307", "INT1305", "INT1313", "INT1201", "ENG1003"],         # s3: 2+3+3+3+3+3=17
        ["INT1430", "INT1434_CLC", "INT14167_CLC", "INT1341_CLC"],                  # s4: 3+3+3+3=12
        ["INT1340_CLC", "INT1421", "INT1422", "INT1423"],                           # s5: 3+3+3+3=12
        ["INT13187_CLC"],                                                            # s6: 4 (internship)
    ],
    2: [  # ATTT
        ["SKD1103", "GD1001", "BAS1201", "BAS1106", "INT1154", "ENG1001"],          # s0: 15
        ["GD1002", "GD1003", "INT1155", "ENG1002", "BAS1301"],                      # s1: 2+2+2+3+3=12
        ["GD1004", "GD1005", "BAS1203", "BAS1401", "INT1202", "INT1316"],           # s2: 16
        ["BAS1152", "INT1307", "INT1305", "INT1313", "INT1201", "ENG1003"],         # s3: 17
        ["INT1430", "INT14167_CLC", "INT1341_CLC", "SEC1201", "SEC1202"],           # s4: 3+3+3+3+3=15
        ["INT1340_CLC", "INT1434_CLC", "INT1422", "SEC1203", "SEC1204"],            # s5: 3+3+3+3+2=14
    ],
    3: [  # KTPM
        ["SKD1103", "GD1001", "BAS1201", "BAS1106", "INT1154", "ENG1001"],          # s0: 15
        ["GD1002", "GD1003", "BAS1202", "INT1155", "ENG1002", "BAS1301"],           # s1: 15
        ["GD1004", "GD1005", "BAS1203", "BAS1401", "INT1202"],                      # s2: 2+2+3+3+3=13
        ["BAS1152", "INT1307", "INT1305", "INT1313", "INT1201", "ENG1003"],         # s3: 17
        ["INT1430", "INT1434_CLC", "INT14167_CLC", "INT1341_CLC", "SWE1201"],       # s4: 3+3+3+3+3=15
        ["INT1340_CLC", "INT1421", "INT1422", "SWE1202", "SWE1204"],                # s5: 3+3+3+3+3=15
        ["SWE1203", "INT13187_CLC"],                                                 # s6: 3+4=7 (internship)
    ],
    4: [  # HTTT
        ["SKD1103", "GD1001", "BAS1201", "BAS1106", "INT1154", "ENG1001"],          # s0: 15
        ["GD1002", "GD1003", "BAS1202", "INT1155", "ENG1002", "BAS1301"],           # s1: 15
        ["GD1004", "GD1005", "BAS1203", "BAS1401", "INT1202", "INT1316"],           # s2: 16
        ["BAS1152", "INT1307", "INT1305", "INT1313", "INT1201", "ENG1003"],         # s3: 17
        ["INT1430", "INT1434_CLC", "INT14167_CLC", "INT1341_CLC", "IS1201"],        # s4: 3+3+3+3+3=15
        ["INT1340_CLC", "INT1422", "INT1423", "IS1202"],                             # s5: 3+3+3+3=12
        ["INT13187_CLC"],                                                             # s6: 4 (internship)
    ],
    5: [  # Ke Toan
        ["SKD1103", "GD1001", "BAS1201", "BAS1106", "INT1154", "ENG1001"],          # s0: 15
        ["GD1002", "GD1003", "ACC1101", "ACC1103", "INT1155", "ENG1002"],           # s1: 2+2+3+3+2+3=15
        ["GD1004", "GD1005", "BAS1401", "ACC1102", "ACC1104", "BAS1301"],           # s2: 2+2+3+3+3+3=16
        ["BAS1152", "ACC1105", "ACC1106", "ACC1110", "ACC1112", "ENG1003"],         # s3: 2+3+3+2+2+3=15
        ["ACC1107", "ACC1108", "ACC1109", "ACC1111"],                                # s4: 3+3+3+3=12
    ],
}

WEIGHTS = {
    "theory": [(1, 0.1), (3, 0.3), (5, 0.6)],
    "lab":    [(1, 0.1), (4, 0.4), (5, 0.5)],
}
WEIGHT_OVERRIDE = {
    # Thực tập cơ sở: heavy lab weight
    "INT13187_CLC": [(1, 0.1), (4, 0.5), (5, 0.4)],
    # Political / social theory courses: no midterm exam, just attendance + final
    "GD1001": [(1, 0.1), (5, 0.9)],
    "GD1002": [(1, 0.1), (5, 0.9)],
    "GD1003": [(1, 0.1), (5, 0.9)],
    "GD1004": [(1, 0.1), (5, 0.9)],
    "GD1005": [(1, 0.1), (5, 0.9)],
    "BAS1152": [(1, 0.1), (5, 0.9)],
    # Writing skills: attendance + homework + final (uses BT component)
    "SKD1103": [(1, 0.1), (2, 0.3), (5, 0.6)],
    # English courses: attendance + homework + final
    "ENG1001": [(1, 0.1), (2, 0.2), (5, 0.7)],
    "ENG1002": [(1, 0.1), (2, 0.2), (5, 0.7)],
    "ENG1003": [(1, 0.1), (2, 0.2), (5, 0.7)],
}

def run(ctx: dict) -> dict:
    mon_hoc = [
        {"id": i, "mamh": mamh, "ten": ten, "sotc": sotc, "mota": ten, "bomon_id": bomon_id}
        for i, (mamh, ten, sotc, bomon_id, _) in enumerate(COURSES, 1)
    ]
    mamh_to_id   = {m["mamh"]: m["id"] for m in mon_hoc}
    mamh_to_type = {mamh: ctype for mamh, _, _, _, ctype in COURSES}
    sotc_by_mid  = {m["id"]: m["sotc"] for m in mon_hoc}

    nganh_monhoc = [
        {"nganh_id": nid, "monhoc_id": mamh_to_id[mamh], "loai": loai}
        for nid, entries in NGANH_MONHOC_MAP.items()
        for mamh, loai in entries
    ]

    monhoc_daudiem = []
    weights_by_mid = {}
    for mh in mon_hoc:
        w = WEIGHT_OVERRIDE.get(mh["mamh"], WEIGHTS[mamh_to_type[mh["mamh"]]])
        weights_by_mid[mh["id"]] = w
        for daudiem_id, tile in w:
            monhoc_daudiem.append({"monhoc_id": mh["id"], "daudiem_id": daudiem_id, "tile": tile})

    monhoc_by_nganh = {}
    for entry in nganh_monhoc:
        monhoc_by_nganh.setdefault(entry["nganh_id"], []).append(entry["monhoc_id"])

    mid_nganh_count = {}
    for entry in nganh_monhoc:
        mid = entry["monhoc_id"]
        mid_nganh_count[mid] = mid_nganh_count.get(mid, 0) + 1

    ctx["curriculum_plan"]   = CURRICULUM_PLAN
    ctx["mamh_to_id"]        = mamh_to_id
    ctx["mamh_to_type"]      = mamh_to_type
    ctx["mid_nganh_count"]   = mid_nganh_count
    ctx["weights_by_monhoc"] = weights_by_mid
    ctx["sotc_by_monhoc"]    = sotc_by_mid
    ctx["monhoc_by_nganh"]   = monhoc_by_nganh
    ctx["monhoc"]            = mon_hoc

    _save(ctx, "MonHoc",          mon_hoc)
    _save(ctx, "NganhHoc_MonHoc", nganh_monhoc)
    _save(ctx, "MonHoc_DauDiem",  monhoc_daudiem)
    return ctx

if __name__ == "__main__":
    run({})
