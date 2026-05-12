package com.qlsv.dto;
import java.util.List;
public record TeacherClassDTO(
    Integer lhpId, String ten, String monHoc, Integer soTc,
    Integer kiHocId, String kiHocTen,
    Long siSo, Integer siSoToiDa,
    List<BuoiHocDTO> lich
) {}
