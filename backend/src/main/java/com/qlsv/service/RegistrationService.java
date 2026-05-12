package com.qlsv.service;

import com.qlsv.dto.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import com.qlsv.util.ScheduleConflictChecker;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RegistrationService {

    private final SinhVienNganhRepository svNganhRepo;
    private final NganhHocMonHocRepository nmRepo;
    private final MonHocKiHocRepository mkRepo;
    private final LopHocPhanRepository lhpRepo;
    private final DangKyHocRepository dkRepo;
    private final BuoiHocRepository buoiRepo;
    private final KetQuaMonRepository ketQuaRepo;
    private final SinhVienRepository svRepo;
    private final GiangVienLopHocPhanRepository gvLhpRepo;
    private final KiHocRepository kiHocRepo;

    public AvailableLhpResponse getAvailable(String maSv, Integer kiHocId) {
        var kiHoc = kiHocRepo.findById(kiHocId)
            .orElseThrow(() -> ApiException.notFound("Kỳ học không tồn tại"));
        String tenKi = kiHoc.getNamHoc().getTen() + " - " + kiHoc.getHocKi().getTen();

        var nganhIds = svNganhRepo.findByMaSv(maSv).stream()
            .map(sn -> sn.getNganh().getId()).toList();
        if (nganhIds.isEmpty()) return new AvailableLhpResponse(kiHocId, tenKi, List.of());

        var nm = nmRepo.findByNganhIds(nganhIds);
        Map<Integer, String> loaiByMonHoc = nm.stream()
            .collect(Collectors.toMap(
                x -> x.getMonHoc().getId(),
                NganhHocMonHoc::getLoai,
                (a, b) -> a));

        var monHocIds = new ArrayList<>(loaiByMonHoc.keySet());
        if (monHocIds.isEmpty()) return new AvailableLhpResponse(kiHocId, tenKi, List.of());

        var mks = mkRepo.findByKiHocAndMonHocs(kiHocId, monHocIds);
        if (mks.isEmpty()) return new AvailableLhpResponse(kiHocId, tenKi, List.of());

        var mkMonHocIds = mks.stream().map(m -> m.getMonHoc().getId()).distinct().toList();
        var lhps = lhpRepo.findByKiHocAndMonHocIds(kiHocId, mkMonHocIds);
        var lhpIds = lhps.stream().map(LopHocPhan::getId).toList();

        var buoiByLhp = buoiRepo.findByLopHocPhan_IdIn(lhpIds).stream()
            .collect(Collectors.groupingBy(b -> b.getLopHocPhan().getId()));

        var dkList = dkRepo.findByMaSvAndKiHoc(maSv, kiHocId);
        Set<Integer> daDangKyLhpIds = dkList.stream()
            .map(d -> d.getLopHocPhan().getId()).collect(Collectors.toSet());
        Map<Integer, Integer> dangKyHocIdByLhp = dkList.stream()
            .collect(Collectors.toMap(
                d -> d.getLopHocPhan().getId(),
                DangKyHoc::getId,
                (a, b) -> a));

        Set<Integer> monDaPass = ketQuaRepo.findByMaSv(maSv).stream()
            .filter(k -> k.getDiem() != null && k.getDiem() >= 4f)
            .map(k -> k.getDangKyHoc().getLopHocPhan().getMonHocKiHoc().getMonHoc().getId())
            .collect(Collectors.toSet());

        var gvByLhp = gvLhpRepo.findByLopHocPhan_IdIn(lhpIds).stream()
            .collect(Collectors.groupingBy(
                g -> g.getLopHocPhan().getId(),
                Collectors.mapping(g -> {
                    var tv = g.getGiangVien().getThanhVien();
                    return ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
                }, Collectors.toList())));

        var dtos = lhps.stream().map(lhp -> {
            int monHocId = lhp.getMonHocKiHoc().getMonHoc().getId();
            long siSo = dkRepo.countByLopHocPhan_Id(lhp.getId());
            var buois = buoiByLhp.getOrDefault(lhp.getId(), List.of());
            return new LopHocPhanDTO(
                lhp.getId(), lhp.getTen(), lhp.getNhom(), lhp.getTothuchanh(), monHocId,
                lhp.getMonHocKiHoc().getMonHoc().getTen(),
                lhp.getMonHocKiHoc().getMonHoc().getSotc(),
                lhp.getSisotoida(), siSo,
                siSo >= lhp.getSisotoida(),
                daDangKyLhpIds.contains(lhp.getId()),
                monDaPass.contains(monHocId),
                dangKyHocIdByLhp.get(lhp.getId()),
                loaiByMonHoc.getOrDefault(monHocId, "BB"),
                buois.stream().map(b -> {
                    var tv = b.getGiangVien().getThanhVien();
                    return new BuoiHocDTO(
                        b.getTuan().getId(), b.getNgay().getId(), b.getKipHoc().getId(),
                        b.getPhongHoc().getTen(),
                        ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim(),
                        lhp.getMonHocKiHoc().getMonHoc().getTen(),
                        lhp.getTen()
                    );
                }).toList(),
                gvByLhp.getOrDefault(lhp.getId(), List.of())
            );
        }).toList();

        return new AvailableLhpResponse(kiHocId, tenKi, dtos);
    }

    @Transactional
    public RegisterResult register(String maSv, RegisterRequest req) {
        List<Integer> ok = new ArrayList<>();
        List<RegisterResult.Failed> fails = new ArrayList<>();

        var sv = svRepo.findById(maSv).orElseThrow(() -> ApiException.notFound("Sinh viên"));

        Set<Integer> monDaPass = ketQuaRepo.findByMaSv(maSv).stream()
            .filter(k -> k.getDiem() != null && k.getDiem() >= 4f)
            .map(k -> k.getDangKyHoc().getLopHocPhan().getMonHocKiHoc().getMonHoc().getId())
            .collect(Collectors.toSet());

        List<BuoiHoc> existingSchedule = null;

        for (Integer lhpId : req.lopHocPhanIds()) {
            var lhpOpt = lhpRepo.findById(lhpId);
            if (lhpOpt.isEmpty()) {
                fails.add(new RegisterResult.Failed(lhpId, "Lớp học phần không tồn tại"));
                continue;
            }
            var lhp = lhpOpt.get();

            if (monDaPass.contains(lhp.getMonHocKiHoc().getMonHoc().getId())) {
                fails.add(new RegisterResult.Failed(lhpId, "Đã qua môn này"));
                continue;
            }

            if (dkRepo.existsBySinhVien_MaSvAndLopHocPhan_Id(maSv, lhpId)) {
                fails.add(new RegisterResult.Failed(lhpId, "Đã đăng ký lớp này"));
                continue;
            }

            long sisoNow = dkRepo.countByLopHocPhan_Id(lhpId);
            if (sisoNow >= lhp.getSisotoida()) {
                fails.add(new RegisterResult.Failed(lhpId, "Lớp đã đầy"));
                continue;
            }

            Integer kiId = lhp.getMonHocKiHoc().getKiHoc().getId();
            if (existingSchedule == null) {
                existingSchedule = new ArrayList<>(buoiRepo.findByStudentAndKiHoc(maSv, kiId));
            }

            List<BuoiHoc> lichLhp = buoiRepo.findByLopHocPhan_Id(lhpId);
            var conflicts = ScheduleConflictChecker.intersect(existingSchedule, lichLhp);
            if (!conflicts.isEmpty()) {
                fails.add(new RegisterResult.Failed(lhpId, "Trùng giờ học"));
                continue;
            }

            dkRepo.save(DangKyHoc.builder()
                .sinhVien(sv)
                .lopHocPhan(lhp)
                .ngaydangky(java.time.LocalDateTime.now())
                .trangthai("DA_DANG_KY")
                .build());
            existingSchedule.addAll(lichLhp);
            ok.add(lhpId);
        }
        return new RegisterResult(ok, fails);
    }

    @Transactional
    public void cancel(String maSv, Integer dangKyHocId) {
        var dk = dkRepo.findById(dangKyHocId)
            .orElseThrow(() -> ApiException.notFound("Đăng ký không tồn tại"));
        if (!dk.getSinhVien().getMaSv().equals(maSv))
            throw ApiException.forbidden("Không phải đăng ký của bạn");
        dkRepo.delete(dk);
    }
}
