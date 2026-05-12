package com.qlsv.model;

import lombok.*;
import java.io.Serializable;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode
public class GiangVienLopHocPhanId implements Serializable {
    private Integer giangVien;
    private Integer lopHocPhan;
}
