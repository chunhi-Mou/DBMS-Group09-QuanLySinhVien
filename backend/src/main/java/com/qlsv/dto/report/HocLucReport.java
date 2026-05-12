package com.qlsv.dto.report;
import java.util.List;
public record HocLucReport(
    Integer kiHocId, String kiHocTen,
    List<DistRow> phanBo,
    List<StudentRow> sinhVien
) {
    public record DistRow(String loaiHocLuc, Long soLuong) {}
    public record StudentRow(String maSv, String hoTen, Float gpa10, Float gpa4,
                             Integer tongTc, Integer tcDat, String hocLuc) {}
}
