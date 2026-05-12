package com.qlsv.service;

import com.qlsv.dto.report.AdminDashboardResponse;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private final SinhVienRepository svRepo;
    private final GiangVienRepository gvRepo;
    private final LopHocPhanRepository lhpRepo;
    private final MonHocRepository monHocRepo;
    private final KiHocRepository kiRepo;
    private final TongKetHocKiRepository tkRepo;
    private final KetQuaMonRepository kqRepo;
    private final SinhVienNganhRepository svNganhRepo;

    @Transactional(readOnly = true)
    public AdminDashboardResponse get() {
        long sv = svRepo.count(), gv = gvRepo.count(), lhp = lhpRepo.count(), mh = monHocRepo.count();

        var kyHienTai = kiRepo.findAllByOrderByIdDesc().stream().findFirst().orElse(null);
        Integer kiId = kyHienTai != null ? kyHienTai.getId() : null;
        String kiTen = kyHienTai != null
            ? kyHienTai.getNamHoc().getTen() + " " + kyHienTai.getHocKi().getTen() : "Chưa có";

        List<AdminDashboardResponse.HocLucDist> dist = (kiId == null) ? List.of()
            : tkRepo.countByLoaiHocLucGroup(kiId).stream()
                .map(arr -> new AdminDashboardResponse.HocLucDist((String) arr[0], (Long) arr[1]))
                .toList();

        var svTheoKhoa = svNganhRepo.countByKhoa().stream()
            .map(arr -> new AdminDashboardResponse.KhoaSv((String) arr[0], (Long) arr[1]))
            .toList();

        var gpaQuaKi = tkRepo.avgGpaPerKi().stream()
            .map(arr -> {
                Integer kId = (Integer) arr[0];
                Double avg = (Double) arr[1];
                var k = kiRepo.findById(kId).orElse(null);
                String name = (k != null) ? k.getNamHoc().getTen() + " " + k.getHocKi().getTen() : ("Kỳ " + kId);
                return new AdminDashboardResponse.GpaPerKi(name, avg != null ? avg.floatValue() : 0f);
            }).toList();

        var topTruot = kqRepo.countFailRateByMon().stream()
            .filter(arr -> (Long) arr[1] >= 5)
            .map(arr -> {
                String mon = (String) arr[0];
                long total = (Long) arr[1];
                long failed = ((Number) arr[2]).longValue();
                float rate = Math.round(failed * 10000f / total) / 100f;
                return new AdminDashboardResponse.MonTruot(mon, rate, total);
            })
            .sorted(Comparator.comparingDouble(AdminDashboardResponse.MonTruot::tyLeTruot).reversed())
            .limit(10).toList();

        var kiHocList = kiRepo.findAllByOrderByIdDesc().stream()
            .map(k -> new AdminDashboardResponse.KiHocItem(k.getId(), k.getNamHoc().getTen() + " " + k.getHocKi().getTen()))
            .toList();

        return new AdminDashboardResponse(sv, gv, lhp, mh, kiId, kiTen, dist, svTheoKhoa, gpaQuaKi, topTruot, kiHocList);
    }
}
