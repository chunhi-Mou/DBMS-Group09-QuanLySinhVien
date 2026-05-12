package com.qlsv.dto.training;
import jakarta.validation.constraints.NotNull;
import java.util.List;
public record AssignGvToLhpRequest(@NotNull List<Integer> giangVienIds) {}
