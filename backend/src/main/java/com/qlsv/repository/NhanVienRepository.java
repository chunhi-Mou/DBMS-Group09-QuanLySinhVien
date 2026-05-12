package com.qlsv.repository;
import com.qlsv.model.NhanVien;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface NhanVienRepository extends JpaRepository<NhanVien, Integer> {
    Optional<NhanVien> findByThanhVien_Id(Integer thanhVienId);
}
