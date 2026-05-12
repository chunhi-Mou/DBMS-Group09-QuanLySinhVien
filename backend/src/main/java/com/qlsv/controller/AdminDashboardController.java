package com.qlsv.controller;

import com.qlsv.dto.report.AdminDashboardResponse;
import com.qlsv.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminDashboardController {
    private final AdminDashboardService svc;

    @GetMapping("/dashboard")
    public AdminDashboardResponse dashboard() { return svc.get(); }
}
