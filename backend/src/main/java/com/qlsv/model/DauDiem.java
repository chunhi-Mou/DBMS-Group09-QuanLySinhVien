package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "DauDiem")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DauDiem {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
    private String mota;
}
