package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "DangKyHoc",
       uniqueConstraints = @UniqueConstraint(columnNames = {"sinhvien_id","lophocphan_id"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DangKyHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    private java.time.LocalDateTime ngaydangky;
    private String trangthai;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sinhvien_id", referencedColumnName = "masv")
    private SinhVien sinhVien;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lophocphan_id")
    private LopHocPhan lopHocPhan;
}
