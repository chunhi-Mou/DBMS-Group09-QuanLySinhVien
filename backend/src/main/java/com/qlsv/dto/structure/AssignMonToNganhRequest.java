package com.qlsv.dto.structure;
import jakarta.validation.constraints.*;
import java.util.List;
public record AssignMonToNganhRequest(@NotNull List<Item> items) {
    public record Item(@NotNull Integer monHocId, @Pattern(regexp="BB|TC") String loai) {}
}
