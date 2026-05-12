package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "NganhHoc")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class NganhHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String ten;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "khoa_id")
    private Khoa khoa;
}
