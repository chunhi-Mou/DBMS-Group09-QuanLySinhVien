package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "DiemHeChu")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DiemHeChu {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
    private Float diem4;
    @Column(name = "diem10_min") private Float diem10Min;
    @Column(name = "diem10_max") private Float diem10Max;
    private String mota;
}
