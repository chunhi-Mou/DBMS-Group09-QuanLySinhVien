package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "DiemThanhPhan")
@IdClass(DiemThanhPhanId.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DiemThanhPhan {
    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "dangkyhoc_id")
    private DangKyHoc dangKyHoc;

    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "daudiem_id")
    private DauDiem dauDiem;

    private Float diem;
}
