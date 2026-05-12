package com.qlsv.controller;

import com.qlsv.repository.KiHocRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/kihoc")
@RequiredArgsConstructor
public class CommonController {
    private final KiHocRepository kiHocRepo;

    @GetMapping
    public Map<String, Object> list() {
        var data = kiHocRepo.findAllByOrderByIdDesc().stream().map(k -> Map.of(
            "id", k.getId(),
            "ten", k.getNamHoc().getTen() + " - " + k.getHocKi().getTen()
        )).toList();
        return Map.of("success", true, "data", data);
    }
}
