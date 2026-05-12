package com.qlsv.repository;
import com.qlsv.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
public interface DiemThanhPhanRepository extends JpaRepository<DiemThanhPhan, DiemThanhPhanId> {
    List<DiemThanhPhan> findByDangKyHoc_IdIn(List<Integer> dkIds);
    List<DiemThanhPhan> findByDangKyHoc_Id(Integer dkId);

    @Query(value = """
      SELECT SUM(dtp.diem * mdd.tile) AS diem_tong
      FROM   DiemThanhPhan  dtp
      JOIN   MonHoc_DauDiem mdd
          ON dtp.daudiem_id  = mdd.daudiem_id
         AND mdd.monhoc_id   = :monhocId
      WHERE  dtp.dangkyhoc_id = :dangkyhocId
    """, nativeQuery = true)
    Double calcWeightedScore(@Param("dangkyhocId") Integer dangkyhocId, @Param("monhocId") Integer monhocId);
}
