package com.qlsv.model;

import lombok.*;
import java.io.Serializable;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode
public class MonHocDauDiemId implements Serializable {
    private Integer monHoc;
    private Integer dauDiem;
}
