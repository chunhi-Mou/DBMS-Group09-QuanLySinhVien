package com.qlsv.controller;

import com.qlsv.dto.config.*;
import com.qlsv.service.GradeConfigService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/grade-config")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminGradeConfigController {
    private final GradeConfigService svc;

    // Dau diem
    @GetMapping("/dau-diems")
    public List<DauDiemAdminDTO> listDauDiem() { return svc.listDauDiem(); }
    @PostMapping("/dau-diems")
    public Map<String,Integer> createDauDiem(@RequestBody DauDiemAdminDTO d) { return Map.of("id", svc.createDauDiem(d)); }
    @PutMapping("/dau-diems/{id}")
    public void updateDauDiem(@PathVariable Integer id, @RequestBody DauDiemAdminDTO d) { svc.updateDauDiem(id, d); }
    @DeleteMapping("/dau-diems/{id}")
    public void deleteDauDiem(@PathVariable Integer id) { svc.deleteDauDiem(id); }

    // MonHoc-DauDiem
    @GetMapping("/monhocs/{monHocId}/dau-diems")
    public MonHocDauDiemConfig getMonDauDiem(@PathVariable Integer monHocId) { return svc.getMonDauDiem(monHocId); }
    @PutMapping("/monhocs/{monHocId}/dau-diems")
    public void setMonDauDiem(@PathVariable Integer monHocId, @Valid @RequestBody SetMonDauDiemRequest req) {
        svc.setMonDauDiem(monHocId, req);
    }

    // DiemHeChu
    @GetMapping("/he-chu")
    public List<DiemHeChuDTO> listHeChu() { return svc.listDiemHeChu(); }
    @PostMapping("/he-chu")
    public Map<String,Integer> createHeChu(@RequestBody DiemHeChuDTO d) { return Map.of("id", svc.createDiemHeChu(d)); }
    @PutMapping("/he-chu/{id}")
    public void updateHeChu(@PathVariable Integer id, @RequestBody DiemHeChuDTO d) { svc.updateDiemHeChu(id, d); }
    @DeleteMapping("/he-chu/{id}")
    public void deleteHeChu(@PathVariable Integer id) { svc.deleteDiemHeChu(id); }

    // LoaiHocLuc
    @GetMapping("/hoc-luc")
    public List<LoaiHocLucDTO> listHocLuc() { return svc.listLoaiHocLuc(); }
    @PostMapping("/hoc-luc")
    public Map<String,Integer> createHocLuc(@RequestBody LoaiHocLucDTO d) { return Map.of("id", svc.createLoaiHocLuc(d)); }
    @PutMapping("/hoc-luc/{id}")
    public void updateHocLuc(@PathVariable Integer id, @RequestBody LoaiHocLucDTO d) { svc.updateLoaiHocLuc(id, d); }
    @DeleteMapping("/hoc-luc/{id}")
    public void deleteHocLuc(@PathVariable Integer id) { svc.deleteLoaiHocLuc(id); }
}
