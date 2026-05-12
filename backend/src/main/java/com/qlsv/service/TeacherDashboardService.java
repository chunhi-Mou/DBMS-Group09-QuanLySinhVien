package com.qlsv.service;

import com.qlsv.dto.TeacherDashboardResponse;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeacherDashboardService {

    private final GiangVienLopHocPhanRepository gvLhpRepo;
    private final GiangVienRepository gvRepo;
    private final DangKyHocRepository dkRepo;
    private final KiHocRepository kiHocRepo;

    public TeacherDashboardResponse get(String username) {
        var gv = gvRepo.findByThanhVien_Username(username)
            .orElseThrow(() -> ApiException.notFound("Giảng viên"));
        var tv = gv.getThanhVien();
        String hoTen = ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
        String maGv = tv.getUsername();

        var allLhp = gvLhpRepo.findByUsername(username);

        Map<Integer, List<GiangVienLopHocPhan>> byKi = allLhp.stream()
            .collect(Collectors.groupingBy(g -> g.getLopHocPhan().getMonHocKiHoc().getKiHoc().getId()));

        Integer kyHienTai = kiHocRepo.findAllByOrderByIdDesc().stream()
            .findFirst().map(KiHoc::getId).orElse(null);

        int soLopKy = byKi.getOrDefault(kyHienTai, List.of()).size();
        long tongSvKy = byKi.getOrDefault(kyHienTai, List.of()).stream()
            .mapToLong(g -> dkRepo.countByLopHocPhan_Id(g.getLopHocPhan().getId()))
            .sum();

        var theoKi = byKi.entrySet().stream()
            .map(e -> {
                var ki = e.getValue().get(0).getLopHocPhan().getMonHocKiHoc().getKiHoc();
                long sv = e.getValue().stream()
                    .mapToLong(g -> dkRepo.countByLopHocPhan_Id(g.getLopHocPhan().getId())).sum();
                return new TeacherDashboardResponse.KiClasses(
                    ki.getId(),
                    ki.getNamHoc().getTen() + " - " + ki.getHocKi().getTen(),
                    e.getValue().size(), sv
                );
            })
            .sorted(Comparator.comparing(TeacherDashboardResponse.KiClasses::kiHocId))
            .toList();

        return new TeacherDashboardResponse(hoTen, maGv, soLopKy, tongSvKy, theoKi);
    }
}
