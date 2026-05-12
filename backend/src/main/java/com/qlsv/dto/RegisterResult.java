package com.qlsv.dto;
import java.util.List;
public record RegisterResult(List<Integer> success, List<Failed> failed) {
    public record Failed(Integer lhpId, String lyDo) {}
}
