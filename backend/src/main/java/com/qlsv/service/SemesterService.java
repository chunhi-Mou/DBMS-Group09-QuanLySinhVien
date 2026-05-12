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
public class SemesterService {

    private final NamHocRepository namRepo;
    private final HocKiRepository hkRepo;
    private final KiHocRepository kiRepo;
    private final MonHocKiHocRepository mkRepo;
    private final MonHocRepository monHocRepo;

    public List<NamHocDTO> listNamHoc() {
        return namRepo.findAllByOrderByTenDesc().stream()
            .map(n -> new NamHocDTO(n.getId(), n.getTen())).toList();
    }
    @Transactional public Integer createNamHoc(NamHocDTO d) {
        if (namRepo.existsByTen(d.ten())) throw ApiException.badRequest("Năm học đã tồn tại");
        return namRepo.save(NamHoc.builder().ten(d.ten()).build()).getId();
    }
    @Transactional public void updateNamHoc(Integer id, NamHocDTO d) {
        var n = namRepo.findById(id).orElseThrow(() -> ApiException.notFound("Năm học"));
        n.setTen(d.ten()); namRepo.save(n);
    }
    @Transactional public void deleteNamHoc(Integer id) { namRepo.deleteById(id); }

    public List<HocKiDTO> listHocKi() {
        return hkRepo.findAllByOrderByTenAsc().stream()
            .map(h -> new HocKiDTO(h.getId(), h.getTen())).toList();
    }
    @Transactional public Integer createHocKi(HocKiDTO d) {
        return hkRepo.save(HocKi.builder().ten(d.ten()).build()).getId();
    }
    @Transactional public void updateHocKi(Integer id, HocKiDTO d) {
        var h = hkRepo.findById(id).orElseThrow(() -> ApiException.notFound("Học kỳ"));
        h.setTen(d.ten()); hkRepo.save(h);
    }
    @Transactional public void deleteHocKi(Integer id) { hkRepo.deleteById(id); }

    public List<KiHocDTO> listKiHoc(Integer namId) {
        var rows = (namId == null)
            ? kiRepo.findAllByOrderByIdDesc()
            : kiRepo.findByNamHocId(namId);
        return rows.stream().map(k -> new KiHocDTO(
            k.getId(),
            k.getNamHoc().getId(), k.getNamHoc().getTen(),
            k.getHocKi().getId(), k.getHocKi().getTen()
        )).toList();
    }

    @Transactional
    public Integer createKiHoc(Integer namHocId, Integer hocKiId) {
        if (kiRepo.existsByNamHoc_IdAndHocKi_Id(namHocId, hocKiId))
            throw ApiException.badRequest("Kỳ này đã tồn tại trong năm học");
        var n = namRepo.findById(namHocId).orElseThrow(() -> ApiException.notFound("Năm học"));
        var h = hkRepo.findById(hocKiId).orElseThrow(() -> ApiException.notFound("Học kỳ"));
        return kiRepo.save(KiHoc.builder().namHoc(n).hocKi(h).build()).getId();
    }
    @Transactional public void deleteKiHoc(Integer id) { kiRepo.deleteById(id); }

    public List<MonHocKiHocDTO> listMonOfKi(Integer kiHocId) {
        return mkRepo.findByKiHoc_Id(kiHocId).stream()
            .map(mk -> new MonHocKiHocDTO(
                mk.getId(), mk.getMonHoc().getId(),
                mk.getMonHoc().getTen(), mk.getMonHoc().getSotc()
            )).toList();
    }

    @Transactional
    public void assignMonToKi(Integer kiHocId, AssignMonToKiRequest req) {
        var ki = kiRepo.findById(kiHocId).orElseThrow(() -> ApiException.notFound("Kỳ"));
        if (req.monHocIds().isEmpty()) {
            mkRepo.findByKiHoc_Id(kiHocId).forEach(mkRepo::delete);
        } else {
            mkRepo.deleteByKiHoc_IdAndMonHoc_IdNotIn(kiHocId, req.monHocIds());
        }
        for (Integer monId : req.monHocIds()) {
            if (!mkRepo.existsByKiHoc_IdAndMonHoc_Id(kiHocId, monId)) {
                var m = monHocRepo.findById(monId).orElseThrow(() -> ApiException.notFound("Môn " + monId));
                var mk = new MonHocKiHoc();
                mk.setKiHoc(ki);
                mk.setMonHoc(m);
                mkRepo.save(mk);
            }
        }
    }
}
