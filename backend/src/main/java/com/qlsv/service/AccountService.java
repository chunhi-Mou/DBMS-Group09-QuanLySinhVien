package com.qlsv.service;

import com.qlsv.dto.account.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.*;
import com.qlsv.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AccountService {

    private final ThanhVienRepository tvRepo;
    private final SinhVienRepository svRepo;
    private final GiangVienRepository gvRepo;
    private final NhanVienRepository nvRepo;
    private final NganhHocRepository nganhRepo;
    private final SinhVienNganhRepository svNganhRepo;
    private final LopHanhChinhRepository lhcRepo;
    private final PasswordEncoder encoder;

    public List<AccountListItem> list(String vaiTro) {
        var rows = (vaiTro == null || vaiTro.isBlank())
                ? tvRepo.findAll()
                : tvRepo.findByVaiTro(vaiTro);
        return rows.stream().map(this::toListItem).toList();
    }

    @Transactional
    public Integer create(CreateAccountRequest req) {
        if (tvRepo.existsByUsername(req.username()))
            throw ApiException.badRequest("Username '" + req.username() + "' đã tồn tại");

        var tv = new ThanhVien();
        tv.setUsername(req.username());
        tv.setPassword(encoder.encode(req.password()));
        tv.setHodem(req.hodem());
        tv.setTen(req.ten());
        tv.setEmail(req.email());
        tv.setDt(req.sdt());
        tv.setVaiTro(req.vaiTro());
        tv = tvRepo.save(tv);

        switch (req.vaiTro()) {
            case "SV" -> {
                if (req.ma() == null || req.ma().isBlank())
                    throw ApiException.badRequest("Thiếu mã SV");
                if (svRepo.existsByMaSv(req.ma()))
                    throw ApiException.badRequest("Mã SV đã tồn tại");
                var sv = new SinhVien();
                sv.setMaSv(req.ma());
                sv.setThanhVien(tv);
                if (req.lopHanhChinhId() != null)
                    sv.setLopHanhChinh(lhcRepo.findById(req.lopHanhChinhId())
                        .orElseThrow(() -> ApiException.notFound("Lớp hành chính")));
                svRepo.save(sv);
                if (req.nganhId() != null) {
                    var ng = nganhRepo.findById(req.nganhId())
                            .orElseThrow(() -> ApiException.notFound("Ngành"));
                    var link = new SinhVienNganh();
                    link.setSinhVien(sv);
                    link.setNganh(ng);
                    svNganhRepo.save(link);
                }
            }
            case "GV" -> {
                var gv = new GiangVien();
                gv.setThanhVien(tv);
                gvRepo.save(gv);
            }
            case "ADMIN" -> {
                var nv = new NhanVien();
                nv.setThanhVien(tv);
                nvRepo.save(nv);
            }
            default -> throw ApiException.badRequest("Vai trò không hợp lệ");
        }
        return tv.getId();
    }

    @Transactional
    public void update(Integer id, UpdateAccountRequest req) {
        var tv = tvRepo.findById(id).orElseThrow(() -> ApiException.notFound("Tài khoản"));
        if (req.hodem() != null) tv.setHodem(req.hodem());
        if (req.ten() != null) tv.setTen(req.ten());
        if (req.email() != null) tv.setEmail(req.email());
        if (req.sdt() != null) tv.setDt(req.sdt());
        tvRepo.save(tv);
    }

    @Transactional
    public void resetPassword(Integer id, ResetPasswordRequest req) {
        var tv = tvRepo.findById(id).orElseThrow(() -> ApiException.notFound("Tài khoản"));
        tv.setPassword(encoder.encode(req.newPassword()));
        tvRepo.save(tv);
    }

    @Transactional
    public void delete(Integer id) {
        var tv = tvRepo.findById(id).orElseThrow(() -> ApiException.notFound("Tài khoản"));
        switch (tv.getVaiTro()) {
            case "SV" -> svRepo.findByThanhVien_Id(id).ifPresent(svRepo::delete);
            case "GV" -> gvRepo.findByThanhVien_Id(id).ifPresent(gvRepo::delete);
            case "ADMIN" -> nvRepo.findByThanhVien_Id(id).ifPresent(nvRepo::delete);
        }
        tvRepo.delete(tv);
    }

    private AccountListItem toListItem(ThanhVien tv) {
        String hoTen = ((tv.getHodem() == null ? "" : tv.getHodem() + " ") + tv.getTen()).trim();
        var svOpt = "SV".equals(tv.getVaiTro()) ? svRepo.findByThanhVien_Id(tv.getId()) : java.util.Optional.<SinhVien>empty();
        String ma = svOpt.map(SinhVien::getMaSv).orElse(null);
        String lopHanhChinh = svOpt
            .map(sv -> sv.getLopHanhChinh() != null ? sv.getLopHanhChinh().getTenLop() : null)
            .orElse(null);
        return new AccountListItem(tv.getId(), tv.getUsername(), hoTen, tv.getEmail(),
                tv.getVaiTro(), ma, lopHanhChinh, tv.getHodem(), tv.getTen(), tv.getDt());
    }
}
