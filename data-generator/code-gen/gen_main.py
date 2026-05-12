# data-generator/gen_main.py
"""
Data generation pipeline. Run this file to regenerate all data.

  cd data-generator
  python gen_main.py

Phases:
  1. Dictionaries    -- lookup tables (TuanHoc, KipHoc, DiemHeChu, ...)
  2. Structure       -- academic org (Truong, Khoa, BoMon, NganhHoc, LopHanhChinh)
  3. Catalog         -- training program (MonHoc, NganhHoc_MonHoc, MonHoc_DauDiem)
  4. Users           -- accounts (ThanhVien, SinhVien, GiangVien, NhanVien, SinhVien_Nganh)
  5. Schedule        -- timetable (MonHoc_KiHoc, LopHocPhan, BuoiHoc)
  6. Results         -- academic (DangKyHoc, DiemThanhPhan, KetQuaMon, TONGKET_HOCKI)

Constants:
  CURRENT_KIHOC_ID = 8  (NamHoc 4 / 2025-2026, Ky 2)
  General students start from KiHoc 3 (enrolled NamHoc 2 / 2023-2024)
"""

import gen_phase1_dict
import gen_phase2_structure
import gen_phase3_catalog
import gen_phase4_users
import gen_phase5_schedule
import gen_phase6_results

def main():
    print("=== QLSV Data Generator ===")
    ctx = {}
    print("\n[Phase 1] Dictionaries")
    ctx = gen_phase1_dict.run(ctx)
    print("\n[Phase 2] Academic Organisation")
    ctx = gen_phase2_structure.run(ctx)
    print("\n[Phase 3] Training Catalog")
    ctx = gen_phase3_catalog.run(ctx)
    print("\n[Phase 4] Users")
    ctx = gen_phase4_users.run(ctx)
    print("\n[Phase 5] Scheduling")
    ctx = gen_phase5_schedule.run(ctx)
    print("\n[Phase 6] Academic Results")
    ctx = gen_phase6_results.run(ctx)
    print("\n=== Generation complete ===")

if __name__ == "__main__":
    main()
