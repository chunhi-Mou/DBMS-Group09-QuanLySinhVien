package com.qlsv.service;

import com.qlsv.dto.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeachingService {

    private final GiangVienLopHocPhanRepository gvLhpRepo;
    private final DangKyHocRepository dkRepo;
    private final BuoiHocRepository buoiRepo;
    private final DiemThanhPhanRepository dtpRepo;
    private final MonHocDauDiemRepository mdRepo;
    private final KetQuaMonRepository kqRepo;
    private final KiHocRepository kiHocRepo;
    private final GradeService gradeService;

    public List<TeacherClassDTO> getClasses(String username, Integer kiHocId) {
        var list = (kiHocId == null)
            ? gvLhpRepo.findByUsername(username)
            : gvLhpRepo.findByUsernameAndKiHoc(username, kiHocId);

        var lhpIds = list.stream().map(g -> g.getLopHocPhan().getId()).distinct().toList();
        var buoiByLhp = buoiRepo.findByLopHocPhan_IdIn(lhpIds).stream()
            .collect(Collectors.groupingBy(b -> b.getLopHocPhan().getId()));

        return list.stream().map(g -> {
            var lhp = g.getLopHocPhan();
            var ki = lhp.getMonHocKiHoc().getKiHoc();
            long siSo = dkRepo.countByLopHocPhan_Id(lhp.getId());
            var lich = buoiByLhp.getOrDefault(lhp.getId(), List.of()).stream()
                .map(b -> new BuoiHocDTO(
                    b.getTuan().getId(), b.getNgay().getId(), b.getKipHoc().getId(),
                    b.getPhongHoc().getTen(),
                    fullName(b.getGiangVien().getThanhVien()),
                    lhp.getMonHocKiHoc().getMonHoc().getTen(),
                    lhp.getTen()
                )).toList();
            return new TeacherClassDTO(
                lhp.getId(), lhp.getTen(),
                lhp.getMonHocKiHoc().getMonHoc().getTen(),
                lhp.getMonHocKiHoc().getMonHoc().getSotc(),
                ki.getId(),
                ki.getNamHoc().getTen() + " - " + ki.getHocKi().getTen(),
                siSo, lhp.getSisotoida(), lich
            );
        }).toList();
    }

    public TeacherGradeBookResponse getGradeBook(String username, Integer lhpId) {
        gradeService.verifyTeacherOwnsLhp(username, lhpId);

        var dks = dkRepo.findByLopHocPhan_IdOrderBySinhVien_MaSvAsc(lhpId);
        if (dks.isEmpty()) {
            return new TeacherGradeBookResponse(lhpId, "", "", 0, List.of(), List.of());
        }

        var lhp = dks.get(0).getLopHocPhan();
        var monHoc = lhp.getMonHocKiHoc().getMonHoc();

        var dauDiems = mdRepo.findByMonHoc_Id(monHoc.getId()).stream()
            .map(md -> new DauDiemDTO(md.getDauDiem().getId(), md.getDauDiem().getTen(), md.getTile()))
            .toList();

        var rows = dks.stream().map(dk -> {
            var sv = dk.getSinhVien();
            var tv = sv.getThanhVien();
            var grades = dtpRepo.findByDangKyHoc_Id(dk.getId()).stream()
                .filter(d -> d.getDiem() != null)
                .collect(Collectors.toMap(d -> d.getDauDiem().getId(), DiemThanhPhan::getDiem, (a, b) -> a));

            var kq = kqRepo.findByDangKyHoc_Id(dk.getId()).orElse(null);
            return new GradeRowDTO(
                dk.getId(), sv.getMaSv(), fullName(tv),
                grades,
                kq != null ? kq.getDiem() : null,
                kq != null && kq.getDiemHeChu() != null ? kq.getDiemHeChu().getTen() : null
            );
        }).toList();

        return new TeacherGradeBookResponse(lhp.getId(), lhp.getTen(), monHoc.getTen(), monHoc.getSotc(), dauDiems, rows);
    }

    public TeacherScheduleResponse getSchedule(String username, Integer kiHocId) {
        var ki = kiHocRepo.findById(kiHocId).orElseThrow(() -> ApiException.notFound("Kỳ"));
        var buois = buoiRepo.findByTeacherAndKiHoc(username, kiHocId);

        var lhpInfo = buois.stream()
            .map(BuoiHoc::getLopHocPhan)
            .collect(Collectors.toMap(LopHocPhan::getId, l -> l, (a, b) -> a))
            .values().stream()
            .map(l -> new TeacherScheduleResponse.LhpInfo(
                l.getId(), l.getTen(), l.getMonHocKiHoc().getMonHoc().getTen()))
            .toList();

        var dtos = buois.stream().map(b -> new BuoiHocDTO(
            b.getTuan().getId(), b.getNgay().getId(), b.getKipHoc().getId(),
            b.getPhongHoc().getTen(),
            fullName(b.getGiangVien().getThanhVien()),
            b.getLopHocPhan().getMonHocKiHoc().getMonHoc().getTen(),
            b.getLopHocPhan().getTen()
        )).toList();

        return new TeacherScheduleResponse(
            kiHocId, ki.getNamHoc().getTen() + " - " + ki.getHocKi().getTen(),
            dtos, lhpInfo);
    }

    private static String fullName(ThanhVien tv) {
        return ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
    }
}
