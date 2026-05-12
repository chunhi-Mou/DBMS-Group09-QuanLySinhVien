package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "NganhHoc_MonHoc")
@IdClass(NganhHocMonHocId.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class NganhHocMonHoc {
    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "nganh_id")
    private NganhHoc nganh;

    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "monhoc_id")
    private MonHoc monHoc;

    private String loai;     // "BB" hoặc "TC"
}
