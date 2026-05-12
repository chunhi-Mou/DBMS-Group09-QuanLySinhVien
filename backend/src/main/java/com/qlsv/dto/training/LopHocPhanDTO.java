package com.qlsv.dto.training;
import java.util.List;
public record LopHocPhanDTO(
    Integer id, String ten, Integer nhom, Integer tothuchanh, Integer monHocKiHocId,
    Integer monHocId, String tenMon, Integer soTc,
    Integer kiHocId, String kiHocTen,
    Integer siSoToiDa, Long siSoHienTai,
    List<GvInfo> giangVien
) {
    public record GvInfo(Integer giangVienId, String username, String hoTen) {}
}
