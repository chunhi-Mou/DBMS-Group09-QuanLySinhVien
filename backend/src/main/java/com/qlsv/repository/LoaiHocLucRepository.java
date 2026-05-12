package com.qlsv.repository;
import com.qlsv.model.LoaiHocLuc;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface LoaiHocLucRepository extends JpaRepository<LoaiHocLuc, Integer> {
    List<LoaiHocLuc> findAllByOrderByDiemMinDesc();
}
