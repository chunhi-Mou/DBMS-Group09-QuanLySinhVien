package com.qlsv.service;

import com.qlsv.dto.training.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LopHocPhanService {

    private final LopHocPhanRepository lhpRepo;
    private final MonHocKiHocRepository mkRepo;
    private final DangKyHocRepository dkRepo;
    private final GiangVienRepository gvRepo;
    private final GiangVienLopHocPhanRepository gvLhpRepo;

    @Transactional(readOnly = true)
    public List<LopHocPhanDTO> list(Integer kiHocId) {
        var rows = (kiHocId == null)
            ? lhpRepo.findAll()
            : lhpRepo.findByMonHocKiHoc_KiHoc_Id(kiHocId);
        return rows.stream().map(this::toDto).toList();
    }

    @Transactional
    public Integer create(CreateLhpRequest req) {
        var mk = mkRepo.findById(req.monHocKiHocId())
            .orElseThrow(() -> ApiException.notFound("MonHoc_KiHoc"));
        var lhp = LopHocPhan.builder()
            .ten(req.ten()).monHocKiHoc(mk).sisotoida(req.siSoToiDa())
            .build();
        return lhpRepo.save(lhp).getId();
    }

    @Transactional
    public void update(Integer id, CreateLhpRequest req) {
        var lhp = lhpRepo.findById(id).orElseThrow(() -> ApiException.notFound("LHP"));
        lhp.setTen(req.ten());
        lhp.setSisotoida(req.siSoToiDa());
        lhpRepo.save(lhp);
    }

    @Transactional
    public void delete(Integer id) {
        if (dkRepo.countByLopHocPhan_Id(id) > 0)
            throw ApiException.badRequest("LHP đã có sinh viên đăng ký, không thể xóa");
        gvLhpRepo.deleteByLopHocPhan_Id(id);
        lhpRepo.deleteById(id);
    }

    @Transactional
    public void assignGv(Integer lhpId, AssignGvToLhpRequest req) {
        var lhp = lhpRepo.findById(lhpId).orElseThrow(() -> ApiException.notFound("LHP"));
        gvLhpRepo.deleteByLopHocPhan_Id(lhpId);
        var links = new java.util.ArrayList<GiangVienLopHocPhan>();
        for (Integer gvId : req.giangVienIds()) {
            var gv = gvRepo.findById(gvId).orElseThrow(() -> ApiException.notFound("GV " + gvId));
            var link = new GiangVienLopHocPhan();
            link.setGiangVien(gv);
            link.setLopHocPhan(lhp);
            links.add(link);
        }
        gvLhpRepo.saveAll(links);
    }

    private LopHocPhanDTO toDto(LopHocPhan lhp) {
        long siSo = dkRepo.countByLopHocPhan_Id(lhp.getId());
        var gvs = gvLhpRepo.findByLopHocPhan_Id(lhp.getId()).stream()
            .map(g -> {
                var tv = g.getGiangVien().getThanhVien();
                String name = ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
                // GiangVien has no maGv — use username as identifier
                return new LopHocPhanDTO.GvInfo(g.getGiangVien().getThanhVienId(), tv.getUsername(), name);
            }).toList();
        var mh = lhp.getMonHocKiHoc().getMonHoc();
        var ki = lhp.getMonHocKiHoc().getKiHoc();
        return new LopHocPhanDTO(
            lhp.getId(), lhp.getTen(), lhp.getNhom(), lhp.getTothuchanh(), lhp.getMonHocKiHoc().getId(),
            mh.getId(), mh.getTen(), mh.getSotc(),
            ki.getId(), ki.getNamHoc().getTen() + " - " + ki.getHocKi().getTen(),
            lhp.getSisotoida(), siSo, gvs
        );
    }
}
