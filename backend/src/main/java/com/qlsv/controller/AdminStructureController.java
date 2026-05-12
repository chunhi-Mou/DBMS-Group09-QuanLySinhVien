package com.qlsv.controller;

import com.qlsv.dto.structure.*;
import com.qlsv.service.StructureService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/structure")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminStructureController {
    private final StructureService svc;

    // Truong
    @GetMapping("/truongs")
    public List<TruongDTO> truongs() { return svc.listTruong(); }
    @PostMapping("/truongs")
    public Map<String,Integer> createTruong(@RequestBody TruongDTO d) { return Map.of("id", svc.createTruong(d)); }
    @PutMapping("/truongs/{id}")
    public void updateTruong(@PathVariable Integer id, @RequestBody TruongDTO d) { svc.updateTruong(id, d); }
    @DeleteMapping("/truongs/{id}")
    public void deleteTruong(@PathVariable Integer id) { svc.deleteTruong(id); }

    // Khoa
    @GetMapping("/khoas")
    public List<KhoaDTO> khoas(@RequestParam(required=false) Integer truongId) { return svc.listKhoa(truongId); }
    @PostMapping("/khoas")
    public Map<String,Integer> createKhoa(@RequestBody KhoaDTO d) { return Map.of("id", svc.createKhoa(d)); }
    @PutMapping("/khoas/{id}")
    public void updateKhoa(@PathVariable Integer id, @RequestBody KhoaDTO d) { svc.updateKhoa(id, d); }
    @DeleteMapping("/khoas/{id}")
    public void deleteKhoa(@PathVariable Integer id) { svc.deleteKhoa(id); }

    // BoMon
    @GetMapping("/bomons")
    public List<BoMonDTO> boMons(@RequestParam(required=false) Integer khoaId) { return svc.listBoMon(khoaId); }
    @PostMapping("/bomons")
    public Map<String,Integer> createBoMon(@RequestBody BoMonDTO d) { return Map.of("id", svc.createBoMon(d)); }
    @PutMapping("/bomons/{id}")
    public void updateBoMon(@PathVariable Integer id, @RequestBody BoMonDTO d) { svc.updateBoMon(id, d); }
    @DeleteMapping("/bomons/{id}")
    public void deleteBoMon(@PathVariable Integer id) { svc.deleteBoMon(id); }

    // Nganh
    @GetMapping("/nganhs")
    public List<NganhDTO> nganhs(@RequestParam(required=false) Integer khoaId) { return svc.listNganh(khoaId); }
    @PostMapping("/nganhs")
    public Map<String,Integer> createNganh(@RequestBody NganhDTO d) { return Map.of("id", svc.createNganh(d)); }
    @PutMapping("/nganhs/{id}")
    public void updateNganh(@PathVariable Integer id, @RequestBody NganhDTO d) { svc.updateNganh(id, d); }
    @DeleteMapping("/nganhs/{id}")
    public void deleteNganh(@PathVariable Integer id) { svc.deleteNganh(id); }

    // MonHoc
    @GetMapping("/monhocs")
    public List<MonHocDTO> monHocs(@RequestParam(required=false) Integer boMonId) { return svc.listMonHoc(boMonId); }
    @PostMapping("/monhocs")
    public Map<String,Integer> createMonHoc(@RequestBody MonHocDTO d) { return Map.of("id", svc.createMonHoc(d)); }
    @PutMapping("/monhocs/{id}")
    public void updateMonHoc(@PathVariable Integer id, @RequestBody MonHocDTO d) { svc.updateMonHoc(id, d); }
    @DeleteMapping("/monhocs/{id}")
    public void deleteMonHoc(@PathVariable Integer id) { svc.deleteMonHoc(id); }

    // Nganh <-> MonHoc
    @GetMapping("/nganhs/{nganhId}/monhocs")
    public List<NganhMonHocAssignment> getNganhMon(@PathVariable Integer nganhId) { return svc.getNganhMon(nganhId); }
    @PutMapping("/nganhs/{nganhId}/monhocs")
    public void assignMonToNganh(@PathVariable Integer nganhId, @Valid @RequestBody AssignMonToNganhRequest req) {
        svc.assignMonToNganh(nganhId, req);
    }

    // LopHanhChinh
    @GetMapping("/lophanhchinhs")
    public List<LopHanhChinhDTO> lopHanhChinhs(@RequestParam(required=false) Integer nganhId) { return svc.listLopHanhChinh(nganhId); }
    @PostMapping("/lophanhchinhs")
    public Map<String,Integer> createLopHanhChinh(@RequestBody LopHanhChinhDTO d) { return Map.of("id", svc.createLopHanhChinh(d)); }
    @PutMapping("/lophanhchinhs/{id}")
    public void updateLopHanhChinh(@PathVariable Integer id, @RequestBody LopHanhChinhDTO d) { svc.updateLopHanhChinh(id, d); }
    @DeleteMapping("/lophanhchinhs/{id}")
    public void deleteLopHanhChinh(@PathVariable Integer id) { svc.deleteLopHanhChinh(id); }
}
