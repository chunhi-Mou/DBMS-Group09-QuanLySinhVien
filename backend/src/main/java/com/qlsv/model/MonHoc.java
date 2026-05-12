package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "MonHoc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MonHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String mamh;
    private String ten;
    private Integer sotc;
    @Column(columnDefinition = "TEXT") private String mota;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bomon_id")
    private BoMon boMon;
}
