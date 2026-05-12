# DBMS-Group09-QuanLySinhVien

Hệ thống quản lý sinh viên, tập trung vào quản lý đăng ký tín chỉ và điểm số cho 3 vai trò chính: **Sinh viên**, **Giảng viên** và **Nhân viên (Admin)**.

## Chức năng theo vai trò

| Vai trò | Chức năng chính |
| --- | --- |
| **Sinh viên** | Đăng ký / hủy tín chỉ · Xem lịch học · Xem bảng điểm / GPA |
| **Giảng viên** | Xem lớp đang dạy · Nhập điểm thành phần · Tổng kết môn |
| **Nhân viên (Admin)** | CRUD tài khoản · Cấu hình cấu trúc trường (khoa, ngành, môn, kỳ, lớp HP, lịch) · Tổng kết kỳ · Báo cáo học lực |

## Công nghệ sử dụng

- **Frontend:** React 18 + Vite (port `5173`)
- **Backend:** Spring Boot 3.2.5 / Java 17 (port `8080`)
- **Database:** MySQL 8

## Yêu cầu cài đặt

- **Java 17+** và **Maven 3.8+**
- **Node.js 18+** và **npm**
- **MySQL 8** đang chạy ở `localhost:3306`
  - Cập nhật user/password theo môi trường của bạn trong `backend/src/main/resources/application.yml`
