package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "MonHoc_DauDiem")
@IdClass(MonHocDauDiemId.class)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MonHocDauDiem {
    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "monhoc_id")
    private MonHoc monHoc;

    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "daudiem_id")
    private DauDiem dauDiem;

    private Float tile;
}
