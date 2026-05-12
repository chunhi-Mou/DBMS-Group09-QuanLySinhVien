package com.qlsv.repository;
import com.qlsv.model.KiHoc;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface KiHocRepository extends JpaRepository<KiHoc, Integer> {
    List<KiHoc> findAllByOrderByIdDesc();

    @org.springframework.data.jpa.repository.Query("SELECT k FROM KiHoc k WHERE k.namHoc.id = :namId ORDER BY k.hocKi.id")
    java.util.List<KiHoc> findByNamHocId(@org.springframework.data.repository.query.Param("namId") Integer namId);

    boolean existsByNamHoc_IdAndHocKi_Id(Integer namId, Integer hocKiId);
}
