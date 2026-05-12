package com.qlsv.service;

import com.qlsv.dto.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.model.DiemThanhPhanId;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GradeService {

    private final DiemThanhPhanRepository dtpRepo;
    private final MonHocDauDiemRepository mdRepo;
    private final DiemHeChuRepository dhcRepo;
    private final DangKyHocRepository dkRepo;
    private final KetQuaMonRepository kqRepo;
    private final LopHocPhanRepository lhpRepo;
    private final GiangVienLopHocPhanRepository gvLhpRepo;

    public void verifyTeacherOwnsLhp(String username, Integer lhpId) {
        if (!gvLhpRepo.existsByGiangVien_ThanhVien_UsernameAndLopHocPhan_Id(username, lhpId))
            throw ApiException.forbidden("Bạn không dạy lớp học phần này");
    }

    @Transactional
    public void saveGrades(String username, Integer lhpId, SaveGradesRequest req) {
        verifyTeacherOwnsLhp(username, lhpId);
        for (var e : req.entries()) {
            var dk = dkRepo.findById(e.dangKyHocId())
                .orElseThrow(() -> ApiException.notFound("DangKyHoc " + e.dangKyHocId()));
            if (!Objects.equals(dk.getLopHocPhan().getId(), lhpId))
                throw ApiException.badRequest("DangKyHoc không thuộc LHP");

            var id = new DiemThanhPhanId(e.dangKyHocId(), e.dauDiemId());
            var dtp = dtpRepo.findById(id).orElseGet(() -> {
                var d = new DiemThanhPhan();
                d.setDangKyHoc(dk);
                d.setDauDiem(DauDiem.builder().id(e.dauDiemId()).build());
                return d;
            });
            dtp.setDiem(e.diem());
            dtpRepo.save(dtp);
        }
    }

    @Transactional
    public FinalizeResult finalize(Integer lhpId) {
        var lhp = lhpRepo.findById(lhpId).orElseThrow(() -> ApiException.notFound("LHP"));
        var monHoc = lhp.getMonHocKiHoc().getMonHoc();
        var dauDiems = mdRepo.findByMonHoc_Id(monHoc.getId());
        if (dauDiems.isEmpty()) throw ApiException.badRequest("Môn chưa cấu hình đầu điểm");

        var heChus = dhcRepo.findAllByOrderByDiem10MinDesc();
        var dks = dkRepo.findByLopHocPhan_IdOrderBySinhVien_MaSvAsc(lhpId);

        List<FinalizeResult.Done> done = new ArrayList<>();
        List<FinalizeResult.Failed> fails = new ArrayList<>();

        for (var dk : dks) {
            var dtps = dtpRepo.findByDangKyHoc_Id(dk.getId());
            Map<Integer, Float> byDauDiem = dtps.stream()
                .filter(d -> d.getDiem() != null)
                .collect(Collectors.toMap(
                    d -> d.getDauDiem().getId(),
                    DiemThanhPhan::getDiem,
                    (a, b) -> a));

            boolean missing = dauDiems.stream()
                .anyMatch(md -> !byDauDiem.containsKey(md.getDauDiem().getId()));
            if (missing) {
                fails.add(new FinalizeResult.Failed(dk.getId(), "Thiếu đầu điểm"));
                continue;
            }

            float tong = 0f;
            for (var md : dauDiems) {
                tong += byDauDiem.get(md.getDauDiem().getId()) * md.getTile();
            }
            float tongRounded = Math.round(tong * 100f) / 100f;

            var hcOpt = heChus.stream()
                .filter(h -> tongRounded >= h.getDiem10Min() && tongRounded <= h.getDiem10Max())
                .findFirst();
            if (hcOpt.isEmpty()) {
                fails.add(new FinalizeResult.Failed(dk.getId(), "Không tìm được hệ chữ cho điểm " + tongRounded));
                continue;
            }
            var hc = hcOpt.get();

            var kq = kqRepo.findByDangKyHoc_Id(dk.getId()).orElseGet(KetQuaMon::new);
            kq.setDangKyHoc(dk);
            kq.setDiem(tongRounded);
            kq.setDiemHeChu(hc);
            kqRepo.save(kq);

            done.add(new FinalizeResult.Done(dk.getId(), tongRounded, hc.getTen(), hc.getDiem4()));
        }

        return new FinalizeResult(done, fails);
    }
}
