package com.qlsv.model;

import lombok.*;
import java.io.Serializable;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode
public class NganhHocMonHocId implements Serializable {
    private Integer nganh;
    private Integer monHoc;
}
