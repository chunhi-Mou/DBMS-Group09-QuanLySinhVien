package com.qlsv.repository;
import com.qlsv.model.NamHoc;
import org.springframework.data.jpa.repository.JpaRepository;
public interface NamHocRepository extends JpaRepository<NamHoc, Integer> {
    java.util.List<NamHoc> findAllByOrderByTenDesc();
    boolean existsByTen(String ten);
}
