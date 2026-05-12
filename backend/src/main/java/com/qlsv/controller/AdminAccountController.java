package com.qlsv.controller;

import com.qlsv.dto.account.*;
import com.qlsv.service.AccountService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/accounts")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminAccountController {
    private final AccountService svc;

    @GetMapping
    public List<AccountListItem> list(@RequestParam(required=false) String vaiTro) {
        return svc.list(vaiTro);
    }

    @PostMapping
    public Map<String,Integer> create(@Valid @RequestBody CreateAccountRequest req) {
        return Map.of("id", svc.create(req));
    }

    @PutMapping("/{id}")
    public void update(@PathVariable Integer id, @RequestBody UpdateAccountRequest req) {
        svc.update(id, req);
    }

    @PostMapping("/{id}/reset-password")
    public void resetPassword(@PathVariable Integer id, @Valid @RequestBody ResetPasswordRequest req) {
        svc.resetPassword(id, req);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Integer id) {
        svc.delete(id);
    }
}
