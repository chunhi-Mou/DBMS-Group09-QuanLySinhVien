package com.qlsv.dto;
import java.util.List;
public record TeacherScheduleResponse(Integer kiHocId, String tenKi, List<BuoiHocDTO> buoi, List<LhpInfo> lhp) {
    public record LhpInfo(Integer lhpId, String ten, String monHoc) {}
}
