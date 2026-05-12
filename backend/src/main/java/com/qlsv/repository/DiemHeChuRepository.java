package com.qlsv.repository;
import com.qlsv.model.DiemHeChu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
public interface DiemHeChuRepository extends JpaRepository<DiemHeChu, Integer> {
    List<DiemHeChu> findAllByOrderByDiem10MinDesc();

    @Query(value = """
      SELECT id, ten, diem4
      FROM   DiemHeChu
      WHERE  :diem BETWEEN diem10_min AND diem10_max
      LIMIT  1
    """, nativeQuery = true)
    List<Object[]> findByScoreRange(@Param("diem") Double diem);
}
