package com.qlsv.dto;
import java.util.List;
public record TeacherDashboardResponse(
    String hoTen, String maGv,
    Integer soLopKyHienTai, Long tongSv,
    List<KiClasses> theoKi
) {
    public record KiClasses(Integer kiHocId, String kiHocTen, Integer soLop, Long tongSv) {}
}
