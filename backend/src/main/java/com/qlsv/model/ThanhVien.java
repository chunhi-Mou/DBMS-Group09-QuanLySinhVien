package com.qlsv.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity @Table(name = "ThanhVien")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ThanhVien {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(unique = true) private String username;
    private String password;
    private String hodem;
    private String ten;
    private LocalDate ngaysinh;
    private String email;
    private String dt;
    @Column(name = "vaitro") private String vaiTro;   // "SV" | "GV" | "ADMIN"

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "diachi_id")
    private DiaChi diaChi;
}
