package com.qlsv.repository;
import com.qlsv.model.KetQuaMon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;
public interface KetQuaMonRepository extends JpaRepository<KetQuaMon, Integer> {
    @Query("SELECT k FROM KetQuaMon k WHERE k.dangKyHoc.sinhVien.maSv = :maSv")
    List<KetQuaMon> findByMaSv(String maSv);

    @Query("""
      SELECT k FROM KetQuaMon k
      WHERE k.dangKyHoc.sinhVien.maSv = :maSv
        AND k.dangKyHoc.lopHocPhan.monHocKiHoc.kiHoc.id = :kiHocId
    """)
    List<KetQuaMon> findByMaSvAndKiHoc(String maSv, Integer kiHocId);

    Optional<KetQuaMon> findByDangKyHoc_Id(Integer dangKyHocId);

    @Query("""
      SELECT k FROM KetQuaMon k
      WHERE k.dangKyHoc.lopHocPhan.monHocKiHoc.kiHoc.id = :kiHocId
        AND k.dangKyHoc.sinhVien.maSv = :maSv
    """)
    List<KetQuaMon> findByKiHocAndMaSv(@org.springframework.data.repository.query.Param("kiHocId") Integer kiHocId, @org.springframework.data.repository.query.Param("maSv") String maSv);

    @org.springframework.data.jpa.repository.Query("""
      SELECT k.dangKyHoc.lopHocPhan.monHocKiHoc.monHoc.ten,
             COUNT(k),
             SUM(CASE WHEN k.diem IS NOT NULL AND k.diem < 4 THEN 1 ELSE 0 END)
      FROM KetQuaMon k
      GROUP BY k.dangKyHoc.lopHocPhan.monHocKiHoc.monHoc.ten
    """)
    java.util.List<Object[]> countFailRateByMon();
}
