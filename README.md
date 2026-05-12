# Hệ thống Quản lý Sinh viên - PTIT (BTL Nhóm 09)

## Phạm vi hệ thống

Web app quản lý đăng ký tín chỉ và điểm số cho **3 vai trò**:

| Vai trò | Chức năng chính |
|---|---|
| **Sinh viên** | Đăng ký / hủy tín chỉ · Xem lịch học · Xem bảng điểm / GPA |
| **Giảng viên** | Xem lớp đang dạy · Nhập điểm thành phần · Tổng kết môn |
| **Nhân viên (Admin)** | CRUD tài khoản · Cấu hình cấu trúc trường (khoa, ngành, môn, kỳ, lớp HP, lịch) · Tổng kết kỳ · Báo cáo học lực |

**Stack:** React 18 + Vite (port 5173) — Spring Boot 3.2.5 / Java 17 (port 8080) — MySQL 8

---

## Yêu cầu cài đặt

- **Java 17+** và **Maven 3.8+**
- **Node.js 18+** và **npm**
- **MySQL 8** đang chạy ở `localhost:3306`
  - User: `root` / Password: `chunhi`
  - (đổi trong `backend/src/main/resources/application.yml` nếu cần)
- **Python 3.9+** với các thư viện:
  ```
  pip install pymysql bcrypt
  ```

---

## Bước 1 — Tạo và nạp dữ liệu

```bash
cd data-generator

# Sinh dữ liệu vào data-generator/data/*.json
python gen_main.py

# Tạo database và nạp toàn bộ dữ liệu vào MySQL
python import_data.py
```

Kết quả mong đợi: tất cả 31 bảng đều hiển thị `✓`.

> **Lưu ý:** Mỗi lần chạy `import_data.py` sẽ **xóa và tạo lại** database `sinhvien` từ đầu.

---

## Bước 2 — Khởi động Backend

```bash
cd backend
mvn spring-boot:run
```

Server khởi động tại `http://localhost:8080`.  
Swagger UI: `http://localhost:8080/swagger-ui.html`

---

## Bước 3 — Khởi động Frontend

Mở terminal mới:

```bash
cd frontend
npm install      # chỉ cần chạy lần đầu
npm run dev
```

Truy cập ứng dụng tại `http://localhost:5173`.

---

## Tài khoản đăng nhập (mật khẩu đều là `123456`)

| Vai trò | Username |
|---|---|
| Admin (Nhân viên) | `admin` |
| Sinh viên | `b22dccn001` |
| Giảng viên | `gv2` |

> Tài khoản sinh viên theo định dạng `{campus}{năm}dc{ngành}{số}`, ví dụ `b22dccn001`, `n23dcpm005`.  
> Tài khoản giảng viên: `gv2` đến `gv151`. Xem `data-generator/data/ThanhVien.json` để tra cứu thêm.

---

## Cấu trúc thư mục

```
.
├── backend/                Spring Boot REST API
├── frontend/               React + Vite SPA
├── data-generator/
│   ├── gen_data.py         Sinh dữ liệu giả lập
│   ├── import_data.py      Nạp dữ liệu vào MySQL
│   ├── sinhvien.sql      Schema32 bảng
│   └── data/               JSON đã sinh (tự động tạo)
```
