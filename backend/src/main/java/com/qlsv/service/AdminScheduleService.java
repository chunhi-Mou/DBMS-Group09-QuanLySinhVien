package com.qlsv.service;

import com.qlsv.dto.training.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminScheduleService {

    private final BuoiHocRepository buoiRepo;
    private final LopHocPhanRepository lhpRepo;
    private final TuanHocRepository tuanRepo;
    private final NgayHocRepository ngayRepo;
    private final KipHocRepository kipRepo;
    private final PhongHocRepository phongRepo;
    private final GiangVienRepository gvRepo;

    public List<PhongHocDTO> phongs() {
        return phongRepo.findAll().stream().map(p -> new PhongHocDTO(p.getId(), p.getTen())).toList();
    }
    public List<TuanHocDTO> tuans() {
        return tuanRepo.findAll().stream().map(t -> new TuanHocDTO(t.getId(), t.getTen())).toList();
    }
    public List<NgayHocDTO> ngays() {
        return ngayRepo.findAll().stream().map(n -> new NgayHocDTO(n.getId(), n.getTen())).toList();
    }
    public List<KipHocDTO> kips() {
        return kipRepo.findAll().stream().map(k -> new KipHocDTO(k.getId(), k.getTen())).toList();
    }

    public List<BuoiHocAdminDTO> listByKi(Integer kiHocId) {
        return buoiRepo.findByLopHocPhan_MonHocKiHoc_KiHoc_Id(kiHocId).stream()
            .map(this::toDto).toList();
    }

    @Transactional
    public Integer create(CreateBuoiHocRequest req) {
        var lhp = lhpRepo.findById(req.lhpId()).orElseThrow(() -> ApiException.notFound("LHP"));
        var b = new BuoiHoc();
        b.setLopHocPhan(lhp);
        b.setTuan(tuanRepo.findById(req.tuanId()).orElseThrow(() -> ApiException.notFound("Tuần")));
        b.setNgay(ngayRepo.findById(req.ngayId()).orElseThrow(() -> ApiException.notFound("Ngày")));
        b.setKipHoc(kipRepo.findById(req.kipId()).orElseThrow(() -> ApiException.notFound("Kíp")));
        b.setPhongHoc(phongRepo.findById(req.phongHocId()).orElseThrow(() -> ApiException.notFound("Phòng")));
        b.setGiangVien(gvRepo.findById(req.giangVienId()).orElseThrow(() -> ApiException.notFound("GV")));
        try {
            return buoiRepo.save(b).getId();
        } catch (DataIntegrityViolationException ex) {
            throw ApiException.badRequest("Trùng phòng hoặc trùng giảng viên ở cùng tuần+ngày+kíp");
        }
    }

    @Transactional
    public void delete(Integer id) { buoiRepo.deleteById(id); }

    private BuoiHocAdminDTO toDto(BuoiHoc b) {
        var tv = b.getGiangVien().getThanhVien();
        String name = ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
        return new BuoiHocAdminDTO(
            b.getId(),
            b.getLopHocPhan().getId(), b.getLopHocPhan().getTen(),
            b.getLopHocPhan().getMonHocKiHoc().getMonHoc().getTen(),
            b.getTuan().getId(), b.getNgay().getId(), b.getKipHoc().getId(),
            b.getPhongHoc().getId(), b.getPhongHoc().getTen(),
            b.getGiangVien().getThanhVienId(), name
        );
    }
}
