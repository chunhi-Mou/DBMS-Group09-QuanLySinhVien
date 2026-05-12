package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "SinhVien_Nganh")
@IdClass(SinhVienNganhId.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SinhVienNganh {
    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sinhvien_id", referencedColumnName = "masv")
    private SinhVien sinhVien;

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nganh_id")
    private NganhHoc nganh;
}
