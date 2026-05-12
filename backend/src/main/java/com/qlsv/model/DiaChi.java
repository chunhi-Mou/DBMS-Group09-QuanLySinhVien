package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "DiaChi")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DiaChi {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String sonha;
    private String toanha;
    private String xompho;
    private String phuongxa;
    private String quanhuyen;
    private String tinhthanh;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "truong_id")
    private Truong truong;
}
