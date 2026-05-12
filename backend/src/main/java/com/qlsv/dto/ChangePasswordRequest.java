package com.qlsv.dto;
import jakarta.validation.constraints.*;
public record ChangePasswordRequest(
    @NotBlank String oldPassword,
    @NotBlank @Size(min = 6, max = 100) String newPassword
) {}
