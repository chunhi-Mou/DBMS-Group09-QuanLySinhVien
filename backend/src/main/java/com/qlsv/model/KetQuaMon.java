package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "KetQuaMon")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class KetQuaMon {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dangkyhoc_id", unique = true)
    private DangKyHoc dangKyHoc;

    private Float diem;

    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "diemhechu_id")
    private DiemHeChu diemHeChu;
}
