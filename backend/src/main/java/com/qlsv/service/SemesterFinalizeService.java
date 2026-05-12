package com.qlsv.service;

import com.qlsv.dto.report.FinalizeSemesterResult;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import com.qlsv.util.GpaCalculator;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SemesterFinalizeService {

    private final KiHocRepository kiRepo;
    private final DangKyHocRepository dkRepo;
    private final KetQuaMonRepository kqRepo;
    private final TongKetHocKiRepository tkRepo;
    private final LoaiHocLucRepository llRepo;

    record GpaItem(int sotc, Float diem10, Float diem4) implements GpaCalculator.Item {}

    @Transactional
    public FinalizeSemesterResult finalize(Integer kiHocId) {
        var ki = kiRepo.findById(kiHocId).orElseThrow(() -> ApiException.notFound("Kỳ"));
        var dks = dkRepo.findByKiHoc_Id(kiHocId);

        Set<String> maSvs = dks.stream()
            .map(d -> d.getSinhVien().getMaSv())
            .collect(Collectors.toCollection(LinkedHashSet::new));

        var heLuc = llRepo.findAllByOrderByDiemMinDesc();

        List<FinalizeSemesterResult.Done> done = new ArrayList<>();
        List<FinalizeSemesterResult.Skipped> skipped = new ArrayList<>();

        for (var maSv : maSvs) {
            var kqs = kqRepo.findByKiHocAndMaSv(kiHocId, maSv);
            if (kqs.isEmpty()) {
                skipped.add(new FinalizeSemesterResult.Skipped(maSv, "Chưa có kết quả môn nào trong kỳ"));
                continue;
            }
            var items = kqs.stream().map(k -> new GpaItem(
                k.getDangKyHoc().getLopHocPhan().getMonHocKiHoc().getMonHoc().getSotc(),
                k.getDiem(),
                k.getDiemHeChu() != null ? k.getDiemHeChu().getDiem4() : null
            )).toList();

            var r = GpaCalculator.calc(items);

            // Use diemMin/diemMax (actual LoaiHocLuc field names)
            var ll = heLuc.stream()
                .filter(h -> r.gpa4() >= h.getDiemMin() - 0.001f && r.gpa4() <= h.getDiemMax() + 0.001f)
                .findFirst().orElse(null);

            var sv = kqs.get(0).getDangKyHoc().getSinhVien();
            var existing = tkRepo.findBySinhVien_MaSvAndKiHoc_Id(maSv, kiHocId).orElseGet(TongKetHocKi::new);
            existing.setSinhVien(sv);
            existing.setKiHoc(ki);
            // Actual TongKetHocKi setter names
            existing.setGpaHe10(r.gpa10());
            existing.setGpaHe4(r.gpa4());
            existing.setTongtinchi(r.tongTc());
            existing.setSoTinChiDat(r.tcDat());
            existing.setLoaiHocLuc(ll);
            tkRepo.save(existing);

            done.add(new FinalizeSemesterResult.Done(
                maSv, r.gpa10(), r.gpa4(), r.tongTc(), r.tcDat(),
                ll != null ? ll.getTen() : null
            ));
        }

        return new FinalizeSemesterResult(done.size() + skipped.size(), done, skipped);
    }
}
