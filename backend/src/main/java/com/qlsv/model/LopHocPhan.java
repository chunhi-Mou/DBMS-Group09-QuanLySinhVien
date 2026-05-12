package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "LopHocPhan")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class LopHocPhan {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
    private Integer nhom;
    private Integer tothuchanh;
    private Integer sisotoida;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "monhockihoc_id")
    private MonHocKiHoc monHocKiHoc;
}
