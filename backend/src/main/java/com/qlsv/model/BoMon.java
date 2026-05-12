package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "BoMon")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BoMon {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
    private String mota;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "khoa_id")
    private Khoa khoa;
}
