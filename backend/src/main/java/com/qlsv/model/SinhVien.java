package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "SinhVien")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SinhVien {
    @Id @Column(name = "masv") private String maSv;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "thanhvien_id", unique = true)
    private ThanhVien thanhVien;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lophanhchinh_id")
    private LopHanhChinh lopHanhChinh;
}
