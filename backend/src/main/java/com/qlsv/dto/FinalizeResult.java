package com.qlsv.dto;
import java.util.List;
public record FinalizeResult(List<Done> done, List<Failed> failed) {
    public record Done(Integer dangKyHocId, Float diemTong, String heChu, Float diem4) {}
    public record Failed(Integer dangKyHocId, String lyDo) {}
}
