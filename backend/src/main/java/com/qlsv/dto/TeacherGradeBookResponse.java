package com.qlsv.dto;
import java.util.List;
public record TeacherGradeBookResponse(
    Integer lhpId, String tenLhp, String monHoc, Integer soTc,
    List<DauDiemDTO> dauDiems,
    List<GradeRowDTO> rows
) {}
