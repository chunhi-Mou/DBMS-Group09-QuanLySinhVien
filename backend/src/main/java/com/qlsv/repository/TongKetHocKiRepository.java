package com.qlsv.repository;
import com.qlsv.model.TongKetHocKi;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;
public interface TongKetHocKiRepository extends JpaRepository<TongKetHocKi, Integer> {
    List<TongKetHocKi> findBySinhVien_MaSvOrderByKiHoc_IdAsc(String maSv);

    Optional<TongKetHocKi> findBySinhVien_MaSvAndKiHoc_Id(String maSv, Integer kiHocId);
    List<TongKetHocKi> findByKiHoc_Id(Integer kiHocId);

    @Query("""
      SELECT t.loaiHocLuc.ten as loai, COUNT(t) as so
      FROM TongKetHocKi t
      WHERE t.kiHoc.id = :kiHocId
      GROUP BY t.loaiHocLuc.ten
    """)
    List<Object[]> countByLoaiHocLucGroup(@Param("kiHocId") Integer kiHocId);

    @Query("""
      SELECT t.kiHoc.id as kiId, AVG(t.gpaHe4) as gpa
      FROM TongKetHocKi t
      GROUP BY t.kiHoc.id
      ORDER BY t.kiHoc.id
    """)
    List<Object[]> avgGpaPerKi();
}
