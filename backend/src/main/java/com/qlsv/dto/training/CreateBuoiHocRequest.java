package com.qlsv.dto.training;
import jakarta.validation.constraints.NotNull;
public record CreateBuoiHocRequest(
    @NotNull Integer lhpId,
    @NotNull Integer tuanId,
    @NotNull Integer ngayId,
    @NotNull Integer kipId,
    @NotNull Integer phongHocId,
    @NotNull Integer giangVienId
) {}
