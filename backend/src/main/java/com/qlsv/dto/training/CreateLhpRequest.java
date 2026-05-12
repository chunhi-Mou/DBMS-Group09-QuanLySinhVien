package com.qlsv.dto.training;
import jakarta.validation.constraints.*;
public record CreateLhpRequest(
    @NotBlank String ten,
    @NotNull Integer monHocKiHocId,
    @NotNull @Min(1) Integer siSoToiDa
) {}
