package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "BuoiHoc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BuoiHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "lophocphan_id") private LopHocPhan lopHocPhan;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "tuan_id") private TuanHoc tuan;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "ngay_id") private NgayHoc ngay;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "kiphoc_id") private KipHoc kipHoc;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "phonghoc_id") private PhongHoc phongHoc;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "giangvien_id") private GiangVien giangVien;
}
