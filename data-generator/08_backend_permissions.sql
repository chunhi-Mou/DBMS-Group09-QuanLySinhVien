USE sinhvien;

CREATE USER IF NOT EXISTS 'qlsv_app'@'localhost' IDENTIFIED BY 'change-this-password';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'qlsv_app'@'localhost';

GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetAuthUserByUsername TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetDanhSachKiHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetLopHocPhanKhaDung TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_DangKyHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_HuyDangKyHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetBangDiemSinhVien TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetDashboardSinhVien TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetLopHocPhanGiangVien TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetTeacherGradeRoster TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_LuuDiemThanhPhan TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_ChotDiemMonHoc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_GetBaoCaoHocLuc TO 'qlsv_app'@'localhost';
GRANT EXECUTE ON PROCEDURE sinhvien.sp_TongKetHocKy TO 'qlsv_app'@'localhost';

FLUSH PRIVILEGES;
