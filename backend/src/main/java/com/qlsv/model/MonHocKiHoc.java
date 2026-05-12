package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "MonHoc_KiHoc",
    uniqueConstraints = @UniqueConstraint(columnNames = {"monhoc_id", "kihoc_id"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MonHocKiHoc {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "monhoc_id")
    private MonHoc monHoc;

    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "kihoc_id")
    private KiHoc kiHoc;
}
