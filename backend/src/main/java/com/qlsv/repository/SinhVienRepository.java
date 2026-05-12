package com.qlsv.repository;
import com.qlsv.model.SinhVien;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface SinhVienRepository extends JpaRepository<SinhVien, String> {
    Optional<SinhVien> findByThanhVien_Username(String username);
    Optional<SinhVien> findByThanhVien_Id(Integer thanhVienId);
    boolean existsByMaSv(String maSv);
}
