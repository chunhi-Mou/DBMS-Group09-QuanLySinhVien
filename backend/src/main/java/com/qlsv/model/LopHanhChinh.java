package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "LopHanhChinh")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class LopHanhChinh {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "tenlop", unique = true)
    private String tenLop;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nganh_id")
    private NganhHoc nganh;
}
