package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "NgayHoc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class NgayHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
}
