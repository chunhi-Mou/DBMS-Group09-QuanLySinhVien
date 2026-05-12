package com.qlsv.controller;

import com.qlsv.dto.training.*;
import com.qlsv.repository.GiangVienRepository;
import com.qlsv.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/training")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminTrainingController {

    private final SemesterService semesterService;
    private final LopHocPhanService lhpService;
    private final AdminScheduleService scheduleService;
    private final GiangVienRepository gvRepo;

    // NamHoc
    @GetMapping("/nam-hocs")
    public List<NamHocDTO> nams() { return semesterService.listNamHoc(); }

    @PostMapping("/nam-hocs")
    public Map<String, Integer> createNam(@RequestBody NamHocDTO d) {
        return Map.of("id", semesterService.createNamHoc(d));
    }

    @PutMapping("/nam-hocs/{id}")
    public void updateNam(@PathVariable Integer id, @RequestBody NamHocDTO d) {
        semesterService.updateNamHoc(id, d);
    }

    @DeleteMapping("/nam-hocs/{id}")
    public void deleteNam(@PathVariable Integer id) { semesterService.deleteNamHoc(id); }

    // HocKi
    @GetMapping("/hoc-kis")
    public List<HocKiDTO> hocKis() { return semesterService.listHocKi(); }

    @PostMapping("/hoc-kis")
    public Map<String, Integer> createHocKi(@RequestBody HocKiDTO d) {
        return Map.of("id", semesterService.createHocKi(d));
    }

    @PutMapping("/hoc-kis/{id}")
    public void updateHocKi(@PathVariable Integer id, @RequestBody HocKiDTO d) {
        semesterService.updateHocKi(id, d);
    }

    @DeleteMapping("/hoc-kis/{id}")
    public void deleteHocKi(@PathVariable Integer id) { semesterService.deleteHocKi(id); }

    // KiHoc
    @GetMapping("/ki-hocs")
    public List<KiHocDTO> kiHocs(@RequestParam(required = false) Integer namId) {
        return semesterService.listKiHoc(namId);
    }

    @PostMapping("/ki-hocs")
    public Map<String, Integer> createKiHoc(@RequestParam Integer namHocId, @RequestParam Integer hocKiId) {
        return Map.of("id", semesterService.createKiHoc(namHocId, hocKiId));
    }

    @DeleteMapping("/ki-hocs/{id}")
    public void deleteKiHoc(@PathVariable Integer id) { semesterService.deleteKiHoc(id); }

    @GetMapping("/ki-hocs/{kiHocId}/mon-hocs")
    public List<MonHocKiHocDTO> monOfKi(@PathVariable Integer kiHocId) {
        return semesterService.listMonOfKi(kiHocId);
    }

    @PutMapping("/ki-hocs/{kiHocId}/mon-hocs")
    public void assignMonToKi(@PathVariable Integer kiHocId, @Valid @RequestBody AssignMonToKiRequest req) {
        semesterService.assignMonToKi(kiHocId, req);
    }

    // LopHocPhan
    @GetMapping("/lop-hoc-phans")
    public List<LopHocPhanDTO> lhps(@RequestParam(required = false) Integer kiHocId) {
        return lhpService.list(kiHocId);
    }

    @PostMapping("/lop-hoc-phans")
    public Map<String, Integer> createLhp(@Valid @RequestBody CreateLhpRequest req) {
        return Map.of("id", lhpService.create(req));
    }

    @PutMapping("/lop-hoc-phans/{id}")
    public void updateLhp(@PathVariable Integer id, @Valid @RequestBody CreateLhpRequest req) {
        lhpService.update(id, req);
    }

    @DeleteMapping("/lop-hoc-phans/{id}")
    public void deleteLhp(@PathVariable Integer id) { lhpService.delete(id); }

    @PutMapping("/lop-hoc-phans/{id}/giang-viens")
    public void assignGv(@PathVariable Integer id, @Valid @RequestBody AssignGvToLhpRequest req) {
        lhpService.assignGv(id, req);
    }

    // GiangVien lookup (for AssignGv UI)
    @GetMapping("/giang-viens")
    public List<Map<String, Object>> giangViens() {
        return gvRepo.findAll().stream().map(g -> {
            var tv = g.getThanhVien();
            String hoTen = ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
            return Map.<String, Object>of("id", g.getThanhVienId(), "username", tv.getUsername(), "hoTen", hoTen);
        }).toList();
    }

    // Schedule lookups
    @GetMapping("/lookups/phongs")
    public List<PhongHocDTO> phongs() { return scheduleService.phongs(); }

    @GetMapping("/lookups/tuans")
    public List<TuanHocDTO> tuans() { return scheduleService.tuans(); }

    @GetMapping("/lookups/ngays")
    public List<NgayHocDTO> ngays() { return scheduleService.ngays(); }

    @GetMapping("/lookups/kips")
    public List<KipHocDTO> kips() { return scheduleService.kips(); }

    // BuoiHoc
    @GetMapping("/buoi-hocs")
    public List<BuoiHocAdminDTO> buoiByKi(@RequestParam Integer kiHocId) {
        return scheduleService.listByKi(kiHocId);
    }

    @PostMapping("/buoi-hocs")
    public Map<String, Integer> createBuoi(@Valid @RequestBody CreateBuoiHocRequest req) {
        return Map.of("id", scheduleService.create(req));
    }

    @DeleteMapping("/buoi-hocs/{id}")
    public void deleteBuoi(@PathVariable Integer id) { scheduleService.delete(id); }
}
