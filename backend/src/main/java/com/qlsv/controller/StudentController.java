package com.qlsv.controller;

import com.qlsv.dto.*;
import com.qlsv.repository.SinhVienRepository;
import com.qlsv.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Map;

@RestController
@RequestMapping("/api/student")
@PreAuthorize("hasRole('SV')")
@RequiredArgsConstructor
public class StudentController {

    private final SinhVienRepository svRepo;
    private final StudentDashboardService dashSvc;
    private final RegistrationService regSvc;
    private final ScheduleService schSvc;
    private final GradeViewService gradeSvc;

    private String maSv(Principal p) {
        return svRepo.findByThanhVien_Username(p.getName())
            .orElseThrow(() -> com.qlsv.exception.ApiException.notFound("Sinh viên")).getMaSv();
    }

    @GetMapping("/dashboard")
    public Map<String, Object> dashboard(Principal p) {
        return Map.of("success", true, "data", dashSvc.get(maSv(p)));
    }

    @GetMapping("/registration/available")
    public Map<String, Object> available(@RequestParam Integer kiHocId, Principal p) {
        return Map.of("success", true, "data", regSvc.getAvailable(maSv(p), kiHocId));
    }

    @PostMapping("/registration")
    public Map<String, Object> register(@Valid @RequestBody RegisterRequest req, Principal p) {
        return Map.of("success", true, "data", regSvc.register(maSv(p), req));
    }

    @DeleteMapping("/registration/{id}")
    public Map<String, Object> cancel(@PathVariable("id") Integer id, Principal p) {
        regSvc.cancel(maSv(p), id);
        return Map.of("success", true);
    }

    @GetMapping("/schedule")
    public Map<String, Object> schedule(@RequestParam Integer kiHocId, Principal p) {
        return Map.of("success", true, "data", schSvc.forStudent(maSv(p), kiHocId));
    }

    @GetMapping("/grades")
    public Map<String, Object> grades(@RequestParam Integer kiHocId, Principal p) {
        return Map.of("success", true, "data", gradeSvc.forStudent(maSv(p), kiHocId));
    }
}
