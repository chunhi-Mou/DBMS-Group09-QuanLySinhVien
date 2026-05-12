package com.qlsv.model;

import lombok.*;
import java.io.Serializable;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode
public class DiemThanhPhanId implements Serializable {
    private Integer dangKyHoc;
    private Integer dauDiem;
}
