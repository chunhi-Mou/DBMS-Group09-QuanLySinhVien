package com.qlsv.dto;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
public record RegisterRequest(@NotEmpty List<Integer> lopHocPhanIds) {}
