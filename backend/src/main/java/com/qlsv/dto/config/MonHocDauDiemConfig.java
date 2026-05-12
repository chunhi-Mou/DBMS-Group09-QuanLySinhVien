package com.qlsv.dto.config;
import java.util.List;
public record MonHocDauDiemConfig(Integer monHocId, String tenMon, List<Item> items) {
    public record Item(Integer dauDiemId, String tenDauDiem, Float tile) {}
}
