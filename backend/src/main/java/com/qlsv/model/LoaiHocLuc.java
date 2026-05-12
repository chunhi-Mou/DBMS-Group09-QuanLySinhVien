package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "LoaiHocLuc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class LoaiHocLuc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
    @Column(name = "diem_min") private Float diemMin;
    @Column(name = "diem_max") private Float diemMax;
    private String mota;
}
