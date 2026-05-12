package com.qlsv.service;

import com.qlsv.dto.StudentGradeBookResponse;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GradeViewService {

    private final DangKyHocRepository dkRepo;
    private final DiemThanhPhanRepository dtpRepo;
    private final MonHocDauDiemRepository mdRepo;
    private final KetQuaMonRepository ketQuaRepo;

    public StudentGradeBookResponse forStudent(String maSv, Integer kiHocId) {
        var dks = dkRepo.findByMaSvAndKiHoc(maSv, kiHocId);
        var dkIds = dks.stream().map(DangKyHoc::getId).toList();

        var dtps = dtpRepo.findByDangKyHoc_IdIn(dkIds);
        Map<Integer, List<DiemThanhPhan>> dtpByDk = dtps.stream()
            .collect(Collectors.groupingBy(d -> d.getDangKyHoc().getId()));

        var ketQua = ketQuaRepo.findByMaSvAndKiHoc(maSv, kiHocId).stream()
            .collect(Collectors.toMap(k -> k.getDangKyHoc().getId(), k -> k));

        var rows = dks.stream().map(dk -> {
            var mon = dk.getLopHocPhan().getMonHocKiHoc().getMonHoc();
            var tileMap = mdRepo.findByMonHoc_Id(mon.getId()).stream()
                .collect(Collectors.toMap(md -> md.getDauDiem().getId(), MonHocDauDiem::getTile));

            var tps = dtpByDk.getOrDefault(dk.getId(), List.of()).stream()
                .map(d -> new StudentGradeBookResponse.DiemTP(
                    d.getDauDiem().getTen(),
                    tileMap.getOrDefault(d.getDauDiem().getId(), 0f),
                    d.getDiem()
                )).toList();

            var kq = ketQua.get(dk.getId());
            return new StudentGradeBookResponse.MonGrade(
                mon.getTen(), mon.getSotc(), tps,
                kq == null ? null : kq.getDiem(),
                kq == null ? null : kq.getDiemHeChu() == null ? null : kq.getDiemHeChu().getTen(),
                kq == null ? null : kq.getDiemHeChu() == null ? null : kq.getDiemHeChu().getDiem4()
            );
        }).toList();
        return new StudentGradeBookResponse(kiHocId, rows);
    }
}
