USE SinhVien;

INSERT INTO DauDiem(id, ten, mota) VALUES
    (1, 'Chuyên cần', 'Điểm chuyên cần / quá trình'),
    (2, 'Bài tập', 'Điểm bài tập'),
    (3, 'Giữa kỳ', 'Điểm giữa kỳ'),
    (4, 'Thực hành', 'Điểm thực hành'),
    (5, 'Cuối kỳ', 'Điểm cuối kỳ');

INSERT INTO DiemHeChu(id, ten, diem10_min, diem10_max, diem4, mota) VALUES
    (1, 'F',  0.0, 4.0, 0.0, 'Không đạt'),
    (2, 'D',  4.0, 5.0, 1.0, 'Đạt'),
    (3, 'D+', 5.0, 5.5, 1.5, 'Trung bình yếu'),
    (4, 'C',  5.5, 6.5, 2.0, 'Trung bình'),
    (5, 'C+', 6.5, 7.0, 2.5, 'Trung bình khá'),
    (6, 'B',  7.0, 8.0, 3.0, 'Khá'),
    (7, 'B+', 8.0, 8.5, 3.5, 'Khá giỏi'),
    (8, 'A',  8.5, 9.0, 3.7, 'Giỏi'),
    (9, 'A+', 9.0, 10.0, 4.0, 'Xuất sắc');

INSERT INTO LoaiHocLuc(id, ten, diem_min, diem_max, mota) VALUES
    (1, 'Kém',        0.0, 1.0, 'GPA dưới 1.0'),
    (2, 'Yếu',        1.0, 2.0, 'GPA từ 1.0 đến dưới 2.0'),
    (3, 'Trung bình', 2.0, 2.5, 'GPA từ 2.0 đến dưới 2.5'),
    (4, 'Khá',        2.5, 3.2, 'GPA từ 2.5 đến dưới 3.2'),
    (5, 'Giỏi',       3.2, 3.6, 'GPA từ 3.2 đến dưới 3.6'),
    (6, 'Xuất sắc',   3.6, 4.0, 'GPA từ 3.6 đến 4.0');

INSERT INTO TuanHoc(id, ten) VALUES
    (1, 'Tuần 1'), (2, 'Tuần 2'), (3, 'Tuần 3'), (4, 'Tuần 4'),
    (5, 'Tuần 5'), (6, 'Tuần 6'), (7, 'Tuần 7'), (8, 'Tuần 8'),
    (9, 'Tuần 9'), (10, 'Tuần 10'), (11, 'Tuần 11'), (12, 'Tuần 12'),
    (13, 'Tuần 13'), (14, 'Tuần 14'), (15, 'Tuần 15');

INSERT INTO NgayHoc(id, ten) VALUES
    (1, 'Thứ 2'),
    (2, 'Thứ 3'),
    (3, 'Thứ 4'),
    (4, 'Thứ 5'),
    (5, 'Thứ 6'),
    (6, 'Thứ 7');

INSERT INTO KipHoc(id, ten) VALUES
    (1, 'Kíp 1'),
    (2, 'Kíp 2'),
    (3, 'Kíp 3'),
    (4, 'Kíp 4'),
    (5, 'Kíp 5'),
    (6, 'Kíp 6');
