package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "GiangVien")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class GiangVien {
    @Id @Column(name = "thanhvien_id") private Integer thanhVienId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "thanhvien_id")
    private ThanhVien thanhVien;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bomon_id")
    private BoMon boMon;

    private String hocham;
}
