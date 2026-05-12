package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "KipHoc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class KipHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
}
