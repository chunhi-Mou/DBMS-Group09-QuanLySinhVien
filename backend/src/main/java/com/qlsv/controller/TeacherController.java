package com.qlsv.controller;

import com.qlsv.dto.*;
import com.qlsv.exception.ApiException;
import com.qlsv.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/teacher")
@PreAuthorize("hasRole('GV')")
@RequiredArgsConstructor
public class TeacherController {

    private final TeacherDashboardService dashboardService;
    private final TeachingService teachingService;
    private final GradeService gradeService;

    @GetMapping("/dashboard")
    public TeacherDashboardResponse dashboard(Principal p) {
        if (p == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Session expired. Please log in again.");
        }
        return dashboardService.get(p.getName());
    }

    @GetMapping("/classes")
    public List<TeacherClassDTO> classes(Principal p,
                                         @RequestParam(required = false) Integer kiHocId) {
        if (p == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Session expired. Please log in again.");
        }
        return teachingService.getClasses(p.getName(), kiHocId);
    }

    @GetMapping("/lhp/{lhpId}/grades")
    public TeacherGradeBookResponse gradeBook(Principal p,
                                               @PathVariable Integer lhpId) {
        if (p == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Session expired. Please log in again.");
        }
        return teachingService.getGradeBook(p.getName(), lhpId);
    }

    @PutMapping("/lhp/{lhpId}/grades")
    public void saveGrades(Principal p,
                           @PathVariable Integer lhpId,
                           @Valid @RequestBody SaveGradesRequest req) {
        if (p == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Session expired. Please log in again.");
        }
        gradeService.saveGrades(p.getName(), lhpId, req);
    }

    @PostMapping("/lhp/{lhpId}/finalize")
    public FinalizeResult finalize(Principal p,
                                   @PathVariable Integer lhpId) {
        if (p == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Session expired. Please log in again.");
        }
        gradeService.verifyTeacherOwnsLhp(p.getName(), lhpId);
        return gradeService.finalize(lhpId);
    }

    @GetMapping("/schedule")
    public TeacherScheduleResponse schedule(Principal p,
                                            @RequestParam Integer kiHocId) {
        if (p == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Session expired. Please log in again.");
        }
        return teachingService.getSchedule(p.getName(), kiHocId);
    }
}
