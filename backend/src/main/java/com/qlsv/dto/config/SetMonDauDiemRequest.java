package com.qlsv.dto.config;
import jakarta.validation.constraints.*;
import java.util.List;
public record SetMonDauDiemRequest(@NotEmpty List<Item> items) {
    public record Item(@NotNull Integer dauDiemId,
                       @NotNull @DecimalMin("0.0") @DecimalMax("1.0") Float tile) {}
}
