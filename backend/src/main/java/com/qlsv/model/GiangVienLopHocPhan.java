package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "GiangVien_LopHocPhan")
@IdClass(GiangVienLopHocPhanId.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class GiangVienLopHocPhan {
    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "giangvien_id")
    private GiangVien giangVien;

    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "lophocphan_id")
    private LopHocPhan lopHocPhan;
}
