package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "NhanVien")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class NhanVien {
    @Id @Column(name = "thanhvien_id") private Integer thanhVienId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "thanhvien_id")
    private ThanhVien thanhVien;

    private String vitri;
}
