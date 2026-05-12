package com.qlsv.dto;
import java.util.Map;
public record GradeRowDTO(
    Integer dangKyHocId, String maSv, String hoTen,
    Map<Integer, Float> grades,
    Float diemTong, String heChu
) {}
