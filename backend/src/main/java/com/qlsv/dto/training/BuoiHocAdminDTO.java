package com.qlsv.dto.training;
public record BuoiHocAdminDTO(
    Integer id, Integer lhpId, String tenLhp, String monHoc,
    Integer tuanId, Integer ngayId, Integer kipId,
    Integer phongHocId, String phongTen,
    Integer giangVienId, String giangVienTen
) {}
