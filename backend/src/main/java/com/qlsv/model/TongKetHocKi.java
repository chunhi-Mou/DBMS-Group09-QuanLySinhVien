package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "TONGKET_HOCKI",
       uniqueConstraints = @UniqueConstraint(columnNames = {"sinhvien_id","kihoc_id"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TongKetHocKi {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sinhvien_id", referencedColumnName = "masv")
    private SinhVien sinhVien;

    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "kihoc_id") private KiHoc kiHoc;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "loaihocluc_id") private LoaiHocLuc loaiHocLuc;

    @Column(name = "gpa_he10") private Float gpaHe10;
    @Column(name = "gpa_he4") private Float gpaHe4;
    private Integer tongtinchi;
    @Column(name = "sotinchi_dat") private Integer soTinChiDat;

    @Column(name = "created_at", insertable = false, updatable = false)
    private java.time.LocalDateTime createdAt;
}
