package com.qlsv.repository;
import com.qlsv.model.BuoiHoc;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
public interface BuoiHocRepository extends JpaRepository<BuoiHoc, Integer> {
    List<BuoiHoc> findByLopHocPhan_Id(Integer lhpId);
    List<BuoiHoc> findByLopHocPhan_IdIn(List<Integer> lhpIds);

    @Query("""
      SELECT b FROM BuoiHoc b
      WHERE b.lopHocPhan.id IN (
        SELECT d.lopHocPhan.id FROM DangKyHoc d
        WHERE d.sinhVien.maSv = :maSv AND d.lopHocPhan.monHocKiHoc.kiHoc.id = :kiHocId
      )
    """)
    List<BuoiHoc> findByStudentAndKiHoc(String maSv, Integer kiHocId);

    @Query("""
      SELECT b FROM BuoiHoc b
      WHERE b.giangVien.thanhVien.username = :username
        AND b.lopHocPhan.monHocKiHoc.kiHoc.id = :kiHocId
    """)
    List<BuoiHoc> findByTeacherAndKiHoc(String username, Integer kiHocId);

    java.util.List<BuoiHoc> findByLopHocPhan_MonHocKiHoc_KiHoc_Id(Integer kiHocId);
}
