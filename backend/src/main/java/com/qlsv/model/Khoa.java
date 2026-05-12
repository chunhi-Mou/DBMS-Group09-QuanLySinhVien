package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "Khoa")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Khoa {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
    private String mota;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "truong_id")
    private Truong truong;
}
