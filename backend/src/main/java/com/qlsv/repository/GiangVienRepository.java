package com.qlsv.repository;
import com.qlsv.model.GiangVien;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface GiangVienRepository extends JpaRepository<GiangVien, Integer> {
    Optional<GiangVien> findByThanhVien_Username(String username);
    Optional<GiangVien> findByThanhVien_Id(Integer thanhVienId);
}
