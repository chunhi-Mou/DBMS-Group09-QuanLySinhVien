package com.qlsv.repository;
import com.qlsv.model.MonHoc;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface MonHocRepository extends JpaRepository<MonHoc, Integer> {
    List<MonHoc> findByBoMon_Id(Integer boMonId);
}
