package com.qlsv.service;

import com.qlsv.dto.ScheduleResponse;
import com.qlsv.repository.BuoiHocRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ScheduleService {
    private final BuoiHocRepository buoiRepo;

    public ScheduleResponse forStudent(String maSv, Integer kiHocId) {
        var items = buoiRepo.findByStudentAndKiHoc(maSv, kiHocId).stream().map(b -> {
            var tv = b.getGiangVien().getThanhVien();
            String gv = ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
            return new ScheduleResponse.Item(
                b.getTuan().getId(), b.getNgay().getId(), b.getKipHoc().getId(),
                b.getLopHocPhan().getMonHocKiHoc().getMonHoc().getTen(),
                b.getLopHocPhan().getTen(),
                b.getPhongHoc().getTen(),
                gv
            );
        }).toList();
        return new ScheduleResponse(kiHocId, items);
    }
}
