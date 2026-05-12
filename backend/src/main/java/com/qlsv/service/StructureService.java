package com.qlsv.service;

import com.qlsv.dto.structure.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class StructureService {

    private final TruongRepository truongRepo;
    private final KhoaRepository khoaRepo;
    private final BoMonRepository boMonRepo;
    private final NganhHocRepository nganhRepo;
    private final MonHocRepository monHocRepo;
    private final NganhHocMonHocRepository nmRepo;
    private final LopHanhChinhRepository lhcRepo;

    // ===== Truong =====
    public List<TruongDTO> listTruong() {
        return truongRepo.findAll().stream()
            .map(t -> new TruongDTO(t.getId(), t.getTen(), t.getMota())).toList();
    }
    @Transactional public Integer createTruong(TruongDTO d) {
        var t = Truong.builder().ten(d.ten()).mota(d.mota()).build();
        return truongRepo.save(t).getId();
    }
    @Transactional public void updateTruong(Integer id, TruongDTO d) {
        var t = truongRepo.findById(id).orElseThrow(() -> ApiException.notFound("Trường"));
        t.setTen(d.ten()); t.setMota(d.mota());
        truongRepo.save(t);
    }
    @Transactional public void deleteTruong(Integer id) { truongRepo.deleteById(id); }

    // ===== Khoa =====
    public List<KhoaDTO> listKhoa(Integer truongId) {
        var rows = truongId == null ? khoaRepo.findAll() : khoaRepo.findByTruong_Id(truongId);
        return rows.stream().map(k -> new KhoaDTO(k.getId(), k.getTen(), k.getMota(),
            k.getTruong() != null ? k.getTruong().getId() : null)).toList();
    }
    @Transactional public Integer createKhoa(KhoaDTO d) {
        var t = truongRepo.findById(d.truongId()).orElseThrow(() -> ApiException.notFound("Trường"));
        var k = Khoa.builder().ten(d.ten()).mota(d.mota()).truong(t).build();
        return khoaRepo.save(k).getId();
    }
    @Transactional public void updateKhoa(Integer id, KhoaDTO d) {
        var k = khoaRepo.findById(id).orElseThrow(() -> ApiException.notFound("Khoa"));
        k.setTen(d.ten()); k.setMota(d.mota());
        if (d.truongId() != null) k.setTruong(truongRepo.findById(d.truongId()).orElseThrow());
        khoaRepo.save(k);
    }
    @Transactional public void deleteKhoa(Integer id) { khoaRepo.deleteById(id); }

    // ===== BoMon =====
    public List<BoMonDTO> listBoMon(Integer khoaId) {
        var rows = khoaId == null ? boMonRepo.findAll() : boMonRepo.findByKhoa_Id(khoaId);
        return rows.stream().map(b -> new BoMonDTO(b.getId(), b.getTen(), b.getMota(),
            b.getKhoa() != null ? b.getKhoa().getId() : null)).toList();
    }
    @Transactional public Integer createBoMon(BoMonDTO d) {
        var k = khoaRepo.findById(d.khoaId()).orElseThrow(() -> ApiException.notFound("Khoa"));
        var b = BoMon.builder().ten(d.ten()).mota(d.mota()).khoa(k).build();
        return boMonRepo.save(b).getId();
    }
    @Transactional public void updateBoMon(Integer id, BoMonDTO d) {
        var b = boMonRepo.findById(id).orElseThrow(() -> ApiException.notFound("Bộ môn"));
        b.setTen(d.ten()); b.setMota(d.mota());
        if (d.khoaId() != null) b.setKhoa(khoaRepo.findById(d.khoaId()).orElseThrow());
        boMonRepo.save(b);
    }
    @Transactional public void deleteBoMon(Integer id) { boMonRepo.deleteById(id); }

    // ===== Nganh =====
    public List<NganhDTO> listNganh(Integer khoaId) {
        var rows = khoaId == null ? nganhRepo.findAll() : nganhRepo.findByKhoa_Id(khoaId);
        return rows.stream().map(n -> new NganhDTO(n.getId(), n.getTen(),
            n.getKhoa() != null ? n.getKhoa().getId() : null)).toList();
    }
    @Transactional public Integer createNganh(NganhDTO d) {
        var k = khoaRepo.findById(d.khoaId()).orElseThrow(() -> ApiException.notFound("Khoa"));
        var n = NganhHoc.builder().ten(d.ten()).khoa(k).build();
        return nganhRepo.save(n).getId();
    }
    @Transactional public void updateNganh(Integer id, NganhDTO d) {
        var n = nganhRepo.findById(id).orElseThrow(() -> ApiException.notFound("Ngành"));
        n.setTen(d.ten());
        if (d.khoaId() != null) n.setKhoa(khoaRepo.findById(d.khoaId()).orElseThrow());
        nganhRepo.save(n);
    }
    @Transactional public void deleteNganh(Integer id) { nganhRepo.deleteById(id); }

    // ===== MonHoc =====
    public List<MonHocDTO> listMonHoc(Integer boMonId) {
        var rows = boMonId == null ? monHocRepo.findAll() : monHocRepo.findByBoMon_Id(boMonId);
        return rows.stream().map(m -> new MonHocDTO(m.getId(), m.getMamh(), m.getTen(), m.getSotc(), m.getMota(),
            m.getBoMon() != null ? m.getBoMon().getId() : null)).toList();
    }
    @Transactional public Integer createMonHoc(MonHocDTO d) {
        var b = boMonRepo.findById(d.boMonId()).orElseThrow(() -> ApiException.notFound("Bộ môn"));
        var m = MonHoc.builder().mamh(d.mamh()).ten(d.ten()).sotc(d.sotc()).mota(d.mota()).boMon(b).build();
        return monHocRepo.save(m).getId();
    }
    @Transactional public void updateMonHoc(Integer id, MonHocDTO d) {
        var m = monHocRepo.findById(id).orElseThrow(() -> ApiException.notFound("Môn"));
        m.setMamh(d.mamh()); m.setTen(d.ten()); m.setSotc(d.sotc()); m.setMota(d.mota());
        if (d.boMonId() != null) m.setBoMon(boMonRepo.findById(d.boMonId()).orElseThrow());
        monHocRepo.save(m);
    }
    @Transactional public void deleteMonHoc(Integer id) { monHocRepo.deleteById(id); }

    // ===== Nganh <-> MonHoc =====
    public List<NganhMonHocAssignment> getNganhMon(Integer nganhId) {
        return nmRepo.findByNganh_Id(nganhId).stream()
            .map(nm -> new NganhMonHocAssignment(
                nm.getMonHoc().getId(), nm.getMonHoc().getTen(),
                nm.getMonHoc().getSotc(), nm.getLoai()))
            .toList();
    }

    @Transactional
    public void assignMonToNganh(Integer nganhId, AssignMonToNganhRequest req) {
        var ng = nganhRepo.findById(nganhId).orElseThrow(() -> ApiException.notFound("Ngành"));
        nmRepo.deleteByNganh_Id(nganhId);
        for (var it : req.items()) {
            var m = monHocRepo.findById(it.monHocId())
                .orElseThrow(() -> ApiException.notFound("Môn " + it.monHocId()));
            var link = new NganhHocMonHoc();
            link.setNganh(ng);
            link.setMonHoc(m);
            link.setLoai(it.loai());
            nmRepo.save(link);
        }
    }

    // ===== LopHanhChinh =====
    public List<LopHanhChinhDTO> listLopHanhChinh(Integer nganhId) {
        var rows = nganhId == null ? lhcRepo.findAll() : lhcRepo.findByNganh_Id(nganhId);
        return rows.stream().map(l -> new LopHanhChinhDTO(l.getId(), l.getTenLop(),
            l.getNganh() != null ? l.getNganh().getId() : null)).toList();
    }
    @Transactional public Integer createLopHanhChinh(LopHanhChinhDTO d) {
        var ng = nganhRepo.findById(d.nganhId()).orElseThrow(() -> ApiException.notFound("Ngành"));
        var l = LopHanhChinh.builder().tenLop(d.tenLop()).nganh(ng).build();
        return lhcRepo.save(l).getId();
    }
    @Transactional public void updateLopHanhChinh(Integer id, LopHanhChinhDTO d) {
        var l = lhcRepo.findById(id).orElseThrow(() -> ApiException.notFound("Lớp hành chính"));
        l.setTenLop(d.tenLop());
        if (d.nganhId() != null) l.setNganh(nganhRepo.findById(d.nganhId()).orElseThrow());
        lhcRepo.save(l);
    }
    @Transactional public void deleteLopHanhChinh(Integer id) { lhcRepo.deleteById(id); }
}
