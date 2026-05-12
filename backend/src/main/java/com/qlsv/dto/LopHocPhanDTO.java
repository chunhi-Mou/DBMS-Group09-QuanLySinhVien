package com.qlsv.dto;
import java.util.List;
public record LopHocPhanDTO(
    Integer id, String ten, Integer nhom, Integer tothuchanh, Integer monHocId, String monHocTen, Integer soTc,
    Integer siSoToiDa, Long siSoHienTai, boolean daDay, boolean daDangKy, boolean daPass,
    Integer dangKyHocId,
    String loai,
    List<BuoiHocDTO> lich,
    List<String> giangVien
) {}
