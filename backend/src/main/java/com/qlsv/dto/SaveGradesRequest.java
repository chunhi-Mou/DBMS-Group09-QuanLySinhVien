package com.qlsv.dto;
import jakarta.validation.constraints.*;
import java.util.List;
public record SaveGradesRequest(@NotEmpty List<Entry> entries) {
    public record Entry(
        @NotNull Integer dangKyHocId,
        @NotNull Integer dauDiemId,
        @DecimalMin("0.0") @DecimalMax("10.0") Float diem
    ) {}
}
