package com.qlsv.dto.report;
import java.util.List;
public record FinalizeSemesterResult(int total, List<Done> done, List<Skipped> skipped) {
    public record Done(String maSv, Float gpa10, Float gpa4, Integer tongTc, Integer tcDat, String hocLuc) {}
    public record Skipped(String maSv, String lyDo) {}
}
