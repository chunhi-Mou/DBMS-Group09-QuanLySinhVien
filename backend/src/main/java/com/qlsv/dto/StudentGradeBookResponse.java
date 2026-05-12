package com.qlsv.dto;
import java.util.List;
public record StudentGradeBookResponse(Integer kiHocId, List<MonGrade> mon) {
    public record MonGrade(
        String monHoc, Integer soTc,
        List<DiemTP> diemThanhPhan,
        Float diemTong, String heChu, Float diem4
    ) {}
    public record DiemTP(String ten, Float tile, Float diem) {}
}
