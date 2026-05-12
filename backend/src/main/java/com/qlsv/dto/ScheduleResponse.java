package com.qlsv.dto;
import java.util.List;
public record ScheduleResponse(Integer kiHocId, List<Item> items) {
    public record Item(Integer tuan, Integer ngay, Integer kip, String monHoc, String lopHocPhan, String phong, String giangVien) {}
}
