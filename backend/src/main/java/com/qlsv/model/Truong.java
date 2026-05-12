package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity @Table(name = "Truong")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Truong {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;
    private String mota;

    @OneToMany(mappedBy = "truong", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<DiaChi> diachs;
}
