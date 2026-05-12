package com.qlsv.repository;
import com.qlsv.model.ThanhVien;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
public interface ThanhVienRepository extends JpaRepository<ThanhVien, Integer> {
    Optional<ThanhVien> findByUsername(String username);
    boolean existsByUsername(String username);
    List<ThanhVien> findByVaiTro(String vaiTro);
}
