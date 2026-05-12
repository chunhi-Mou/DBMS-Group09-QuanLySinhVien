package com.qlsv.repository;
import com.qlsv.model.Khoa;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface KhoaRepository extends JpaRepository<Khoa, Integer> {
    List<Khoa> findByTruong_Id(Integer truongId);
}
