package com.qlsv.service;

import com.qlsv.dto.StudentDashboardResponse;
import com.qlsv.exception.ApiException;
import com.qlsv.model.SinhVien;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class StudentDashboardService {

    private final SinhVienRepository svRepo;
    private final TongKetHocKiRepository tkRepo;

    public StudentDashboardResponse get(String maSv) {
        SinhVien sv = svRepo.findById(maSv).orElseThrow(() -> ApiException.notFound("Sinh viên"));
        var tv = sv.getThanhVien();
        String hoten = ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();

        var history = tkRepo.findBySinhVien_MaSvOrderByKiHoc_IdAsc(maSv);
        var historyDtos = history.stream().map(t -> new StudentDashboardResponse.KiSummary(
            t.getKiHoc().getId(),
            t.getKiHoc().getNamHoc().getTen() + " - " + t.getKiHoc().getHocKi().getTen(),
            t.getGpaHe10(), t.getGpaHe4(),
            t.getLoaiHocLuc() == null ? null : t.getLoaiHocLuc().getTen(),
            t.getSoTinChiDat()
        )).toList();

        var last = history.isEmpty() ? null : history.get(history.size() - 1);
        int tcLuy = history.stream().mapToInt(t -> t.getSoTinChiDat() == null ? 0 : t.getSoTinChiDat()).sum();

        return new StudentDashboardResponse(
            hoten, maSv,
            last == null ? null : last.getGpaHe10(),
            last == null ? null : last.getGpaHe4(),
            last == null || last.getLoaiHocLuc() == null ? null : last.getLoaiHocLuc().getTen(),
            tcLuy,
            historyDtos
        );
    }
}
