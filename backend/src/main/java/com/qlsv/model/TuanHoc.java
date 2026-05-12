package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "TuanHoc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TuanHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
}
