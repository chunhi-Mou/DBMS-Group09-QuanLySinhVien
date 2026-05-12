package com.qlsv.service;

import com.qlsv.dto.*;
import com.qlsv.exception.ApiException;
import com.qlsv.model.SinhVien;
import com.qlsv.repository.*;
import com.qlsv.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final ThanhVienRepository tvRepo;
    private final SinhVienRepository svRepo;
    private final PasswordEncoder enc;
    private final JwtUtil jwt;

    public LoginResponse login(LoginRequest req) {
        var tv = tvRepo.findByUsername(req.username())
            .orElseThrow(() -> ApiException.unauthorized("Sai tài khoản hoặc mật khẩu"));
        if (!enc.matches(req.password(), tv.getPassword()))
            throw ApiException.unauthorized("Sai tài khoản hoặc mật khẩu");

        String maSv = "SV".equals(tv.getVaiTro())
            ? svRepo.findByThanhVien_Username(tv.getUsername()).map(SinhVien::getMaSv).orElse(null)
            : null;

        String hoten = (tv.getHodem() == null ? "" : tv.getHodem() + " ") + (tv.getTen() == null ? "" : tv.getTen());
        String token = jwt.generate(tv.getUsername(), tv.getVaiTro(), tv.getId());
        return new LoginResponse(token, tv.getVaiTro(), hoten.trim(), tv.getId(), maSv);
    }

    @Transactional
    public void changePassword(String username, ChangePasswordRequest req) {
        var tv = tvRepo.findByUsername(username)
            .orElseThrow(() -> ApiException.notFound("Không tìm thấy tài khoản"));
        if (!enc.matches(req.oldPassword(), tv.getPassword()))
            throw ApiException.badRequest("Mật khẩu cũ không đúng");
        tv.setPassword(enc.encode(req.newPassword()));
        tvRepo.save(tv);
    }
}
