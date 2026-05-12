package com.qlsv.dto.report;
import java.util.List;
public record AdminDashboardResponse(
    long tongSv, long tongGv, long tongLhp, long tongMon,
    Integer kiHocHienTaiId, String kiHocHienTaiTen,
    List<HocLucDist> distHocLuc,
    List<KhoaSv> svTheoKhoa,
    List<GpaPerKi> gpaQuaKi,
    List<MonTruot> topMonTruot,
    List<KiHocItem> kiHocList
) {
    public record HocLucDist(String loai, Long count) {}
    public record KhoaSv(String khoa, Long count) {}
    public record GpaPerKi(String kiHocTen, Float gpa) {}
    public record MonTruot(String monHoc, Float tyLeTruot, Long soSv) {}
    public record KiHocItem(Integer id, String ten) {}
}
