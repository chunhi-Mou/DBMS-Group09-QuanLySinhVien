package com.qlsv.dto;
import java.util.List;
public record StudentDashboardResponse(
    String hoten, String maSv,
    Float gpaCurrent, Float gpa4Current, String hocLucCurrent,
    Integer tinChiTichLuy,
    List<KiSummary> history
) {
    public record KiSummary(Integer kiHocId, String tenKi, Float gpa10, Float gpa4, String hocLuc, Integer tcDat) {}
}
