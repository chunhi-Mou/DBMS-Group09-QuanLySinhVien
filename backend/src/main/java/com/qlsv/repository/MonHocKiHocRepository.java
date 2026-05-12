package com.qlsv.repository;
import com.qlsv.model.MonHocKiHoc;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
public interface MonHocKiHocRepository extends JpaRepository<MonHocKiHoc, Integer> {
    @Query("SELECT mk FROM MonHocKiHoc mk WHERE mk.kiHoc.id = :kiHocId AND mk.monHoc.id IN :monHocIds")
    List<MonHocKiHoc> findByKiHocAndMonHocs(Integer kiHocId, List<Integer> monHocIds);

    java.util.List<MonHocKiHoc> findByKiHoc_Id(Integer kiHocId);
    void deleteByKiHoc_IdAndMonHoc_IdNotIn(Integer kiHocId, java.util.Collection<Integer> monHocIds);
    boolean existsByKiHoc_IdAndMonHoc_Id(Integer kiHocId, Integer monHocId);
}
