USE sinhvien;

CALL sp_GetAuthUserByUsername('sv_test');

SELECT 1 FROM ThanhVien LIMIT 1;
INSERT INTO DangKyHoc(ngaydangky, trangthai, sinhvien_id, lophocphan_id)
VALUES (NOW(), 'Đã lưu', 'B23DCCE075', 5);
UPDATE DangKyHoc SET trangthai = 'Đã hủy' WHERE id = 1;
DELETE FROM DangKyHoc WHERE id = 1;
SELECT 1 FROM v_BangDiem_SinhVien LIMIT 1;
SELECT 1 FROM v_LopHocPhan_ThongTinDayDu LIMIT 1;
