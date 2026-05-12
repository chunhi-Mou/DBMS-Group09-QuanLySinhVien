package com.qlsv.model;

import lombok.*;
import java.io.Serializable;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode
public class SinhVienNganhId implements Serializable {
    private String sinhVien;
    private Integer nganh;
}
