package com.qlsv.repository;
import com.qlsv.model.BoMon;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface BoMonRepository extends JpaRepository<BoMon, Integer> {
    List<BoMon> findByKhoa_Id(Integer khoaId);
}
