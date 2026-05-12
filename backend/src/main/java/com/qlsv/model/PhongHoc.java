package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "PhongHoc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PhongHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
    private Integer succhua;
}
