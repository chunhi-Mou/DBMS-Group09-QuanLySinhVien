package com.qlsv.service;

import com.qlsv.dto.config.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GradeConfigService {

    private final MonHocDauDiemRepository mdRepo;
    private final DauDiemRepository ddRepo;
    private final MonHocRepository monHocRepo;
    private final DiemHeChuRepository dhcRepo;
    private final LoaiHocLucRepository llRepo;

    // ===== DauDiem =====
    public List<DauDiemAdminDTO> listDauDiem() {
        return ddRepo.findAll().stream()
            .map(d -> new DauDiemAdminDTO(d.getId(), d.getTen(), d.getMota())).toList();
    }
    @Transactional public Integer createDauDiem(DauDiemAdminDTO d) {
        var x = DauDiem.builder().ten(d.ten()).mota(d.mota()).build();
        return ddRepo.save(x).getId();
    }
    @Transactional public void updateDauDiem(Integer id, DauDiemAdminDTO d) {
        var x = ddRepo.findById(id).orElseThrow(() -> ApiException.notFound("Đầu điểm"));
        x.setTen(d.ten()); x.setMota(d.mota());
        ddRepo.save(x);
    }
    @Transactional public void deleteDauDiem(Integer id) { ddRepo.deleteById(id); }

    // ===== MonHoc DauDiem config =====
    public MonHocDauDiemConfig getMonDauDiem(Integer monHocId) {
        var m = monHocRepo.findById(monHocId).orElseThrow(() -> ApiException.notFound("Môn"));
        var items = mdRepo.findByMonHoc_Id(monHocId).stream()
            .map(md -> new MonHocDauDiemConfig.Item(
                md.getDauDiem().getId(), md.getDauDiem().getTen(), md.getTile()))
            .toList();
        return new MonHocDauDiemConfig(m.getId(), m.getTen(), items);
    }

    @Transactional
    public void setMonDauDiem(Integer monHocId, SetMonDauDiemRequest req) {
        var m = monHocRepo.findById(monHocId).orElseThrow(() -> ApiException.notFound("Môn"));
        double sum = 0;
        for (var it : req.items()) sum += it.tile();
        if (Math.abs(sum - 1.0) > 0.001)
            throw ApiException.badRequest("Tổng tỉ lệ phải = 1.0 (hiện " + sum + ")");
        mdRepo.deleteByMonHoc_Id(monHocId);
        for (var it : req.items()) {
            var dd = ddRepo.findById(it.dauDiemId())
                .orElseThrow(() -> ApiException.notFound("Đầu điểm " + it.dauDiemId()));
            var md = new MonHocDauDiem();
            md.setMonHoc(m);
            md.setDauDiem(dd);
            md.setTile(it.tile());
            mdRepo.save(md);
        }
    }

    // ===== DiemHeChu =====
    public List<DiemHeChuDTO> listDiemHeChu() {
        return dhcRepo.findAllByOrderByDiem10MinDesc().stream()
            .map(d -> new DiemHeChuDTO(d.getId(), d.getTen(), d.getDiem10Min(), d.getDiem10Max(), d.getDiem4()))
            .toList();
    }
    @Transactional public Integer createDiemHeChu(DiemHeChuDTO d) {
        var x = DiemHeChu.builder().ten(d.ten()).diem10Min(d.diem10Min()).diem10Max(d.diem10Max()).diem4(d.diem4()).build();
        return dhcRepo.save(x).getId();
    }
    @Transactional public void updateDiemHeChu(Integer id, DiemHeChuDTO d) {
        var x = dhcRepo.findById(id).orElseThrow(() -> ApiException.notFound("Hệ chữ"));
        x.setTen(d.ten()); x.setDiem10Min(d.diem10Min()); x.setDiem10Max(d.diem10Max()); x.setDiem4(d.diem4());
        dhcRepo.save(x);
    }
    @Transactional public void deleteDiemHeChu(Integer id) { dhcRepo.deleteById(id); }

    // ===== LoaiHocLuc =====
    public List<LoaiHocLucDTO> listLoaiHocLuc() {
        return llRepo.findAllByOrderByDiemMinDesc().stream()
            .map(l -> new LoaiHocLucDTO(l.getId(), l.getTen(), l.getDiemMin(), l.getDiemMax())).toList();
    }
    @Transactional public Integer createLoaiHocLuc(LoaiHocLucDTO d) {
        var x = LoaiHocLuc.builder().ten(d.ten()).diemMin(d.diemMin()).diemMax(d.diemMax()).build();
        return llRepo.save(x).getId();
    }
    @Transactional public void updateLoaiHocLuc(Integer id, LoaiHocLucDTO d) {
        var x = llRepo.findById(id).orElseThrow(() -> ApiException.notFound("Loại học lực"));
        x.setTen(d.ten()); x.setDiemMin(d.diemMin()); x.setDiemMax(d.diemMax());
        llRepo.save(x);
    }
    @Transactional public void deleteLoaiHocLuc(Integer id) { llRepo.deleteById(id); }
}
