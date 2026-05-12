package com.qlsv.service;

import com.qlsv.dto.report.HocLucReport;
import com.qlsv.exception.ApiException;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final KiHocRepository kiRepo;
    private final TongKetHocKiRepository tkRepo;

    @Transactional(readOnly = true)
    public HocLucReport hocLuc(Integer kiHocId) {
        var ki = kiRepo.findById(kiHocId).orElseThrow(() -> ApiException.notFound("Kỳ"));

        var dist = tkRepo.countByLoaiHocLucGroup(kiHocId).stream()
            .map(arr -> new HocLucReport.DistRow((String) arr[0], (Long) arr[1]))
            .toList();

        var sv = tkRepo.findByKiHoc_Id(kiHocId).stream()
            .map(t -> {
                var tv = t.getSinhVien().getThanhVien();
                String name = ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
                return new HocLucReport.StudentRow(
                    t.getSinhVien().getMaSv(), name,
                    t.getGpaHe10(), t.getGpaHe4(), t.getTongtinchi(), t.getSoTinChiDat(),
                    t.getLoaiHocLuc() != null ? t.getLoaiHocLuc().getTen() : null
                );
            }).toList();

        return new HocLucReport(
            kiHocId, ki.getNamHoc().getTen() + " - " + ki.getHocKi().getTen(),
            dist, sv
        );
    }
}
