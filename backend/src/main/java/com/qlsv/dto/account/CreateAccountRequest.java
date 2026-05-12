package com.qlsv.dto.account;

import jakarta.validation.constraints.*;

public record CreateAccountRequest(
    @NotBlank @Size(max = 50) String username,
    @NotBlank @Size(min = 6) String password,
    @NotBlank String hodem,
    @NotBlank String ten,
    @Email String email,
    String sdt,
    @NotBlank @Pattern(regexp = "SV|GV|ADMIN") String vaiTro,
    String ma,
    Integer nganhId,
    Integer lopHanhChinhId
) {}
