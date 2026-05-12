USE sinhvien;

CREATE USER IF NOT EXISTS 'qlsv_app'@'localhost' IDENTIFIED BY 'change-this-password';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'qlsv_app'@'localhost';

-- Common & Auth
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetAuthUserByUsername TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetDanhSachKiHoc TO 'qlsv_app'@'localhost';

-- Student
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetLopHocPhanKhaDung TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_DangKyHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_HuyDangKyHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetBangDiemSinhVien TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetDashboardSinhVien TO 'qlsv_app'@'localhost';

-- Teacher
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetLopHocPhanGiangVien TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetTeacherGradeRoster TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_LuuDiemThanhPhan TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_ChotDiemMonHoc TO 'qlsv_app'@'localhost';

-- Admin: Structure
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateTruong TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateTruong TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteTruong TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateKhoa TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateKhoa TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteKhoa TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateBoMon TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateBoMon TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteBoMon TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateNganh TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateNganh TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteNganh TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateMonHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateMonHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteMonHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_AssignMonHocNganh TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateLopHanhChinh TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateLopHanhChinh TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteLopHanhChinh TO 'qlsv_app'@'localhost';

-- Admin: Training
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateNamHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateNamHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteNamHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateHocKi TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateHocKi TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteHocKi TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateKiHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteKiHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_AssignMonHocKiHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateLopHocPhan TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UpdateLopHocPhan TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteLopHocPhan TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_AssignGiangVienLopHocPhan TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_UnassignGiangVienLopHocPhan TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_CreateBuoiHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteBuoiHoc TO 'qlsv_app'@'localhost';

-- Admin: Grade Config
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_AssignMonHocDauDiem TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_Admin_DeleteMonHocDauDiem TO 'qlsv_app'@'localhost';

-- Reports & Finalize
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetBaoCaoHocLuc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_TongKetHocKy TO 'qlsv_app'@'localhost';

FLUSH PRIVILEGES;
