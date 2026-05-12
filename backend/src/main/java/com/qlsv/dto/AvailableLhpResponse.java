package com.qlsv.dto;
import java.util.List;
public record AvailableLhpResponse(Integer kiHocId, String kiHocTen, List<LopHocPhanDTO> lopHocPhans) {}
