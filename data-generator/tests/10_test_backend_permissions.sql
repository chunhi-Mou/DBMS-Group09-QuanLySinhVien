USE sinhvien;

CALL sp_GetAuthUserByUsername('sv_test');

SELECT * FROM ThanhVien LIMIT 1;
INSERT INTO DangKyHoc(ngaydangky, trangthai, sinhvien_id, lophocphan_id)
VALUES (NOW(), 'Đã lưu', 'B23DCCE075', 5);
