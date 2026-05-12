package com.qlsv.controller;

import com.qlsv.dto.*;
import com.qlsv.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.security.Principal;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService svc;

    @PostMapping("/login")
    public Map<String,Object> login(@Valid @RequestBody LoginRequest req) {
        return Map.of("success", true, "data", svc.login(req));
    }

    @PostMapping("/change-password")
    public Map<String,Object> changePassword(@Valid @RequestBody ChangePasswordRequest req, Principal principal) {
        svc.changePassword(principal.getName(), req);
        return Map.of("success", true, "message", "Đổi mật khẩu thành công");
    }
}
