package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "KiHoc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class KiHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "namhoc_id")
    private NamHoc namHoc;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hocki_id")
    private HocKi hocKi;
}
