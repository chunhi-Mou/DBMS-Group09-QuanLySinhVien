package com.qlsv.repository;
import com.qlsv.model.NganhHoc;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface NganhHocRepository extends JpaRepository<NganhHoc, Integer> {
    List<NganhHoc> findByKhoa_Id(Integer khoaId);
}
