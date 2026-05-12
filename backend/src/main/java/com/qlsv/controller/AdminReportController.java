package com.qlsv.controller;

import com.qlsv.dto.report.*;
import com.qlsv.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminReportController {
    private final SemesterFinalizeService finalizeSvc;
    private final ReportService reportSvc;

    @PostMapping("/ki-hocs/{id}/finalize")
    public FinalizeSemesterResult finalize(@PathVariable Integer id) {
        return finalizeSvc.finalize(id);
    }

    @GetMapping("/reports/hoc-luc")
    public HocLucReport hocLuc(@RequestParam Integer kiHocId) {
        return reportSvc.hocLuc(kiHocId);
    }
}
