package com.qlsv.repository;
import com.qlsv.model.DangKyHoc;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
public interface DangKyHocRepository extends JpaRepository<DangKyHoc, Integer> {
    long countByLopHocPhan_Id(Integer lhpId);
    List<DangKyHoc> findBySinhVien_MaSv(String maSv);

    @Query("SELECT d FROM DangKyHoc d WHERE d.sinhVien.maSv = :maSv AND d.lopHocPhan.monHocKiHoc.kiHoc.id = :kiHocId")
    List<DangKyHoc> findByMaSvAndKiHoc(String maSv, Integer kiHocId);

    boolean existsBySinhVien_MaSvAndLopHocPhan_Id(String maSv, Integer lhpId);
    List<DangKyHoc> findByLopHocPhan_IdOrderBySinhVien_MaSvAsc(Integer lhpId);

    @Query("SELECT d FROM DangKyHoc d WHERE d.lopHocPhan.monHocKiHoc.kiHoc.id = :kiHocId")
    List<DangKyHoc> findByKiHoc_Id(@Param("kiHocId") Integer kiHocId);

    @Query(value = """
      SELECT dkh.lophocphan_id
      FROM   DangKyHoc    dkh
      JOIN   LopHocPhan   lhp ON dkh.lophocphan_id   = lhp.id
      JOIN   MonHoc_KiHoc mkh ON lhp.monhockihoc_id  = mkh.id
      JOIN   KetQuaMon    kqm ON dkh.id              = kqm.dangkyhoc_id
      WHERE  dkh.sinhvien_id = :masv
        AND  mkh.monhoc_id   = :monhocId
        AND  kqm.diem       >= 4
    """, nativeQuery = true)
    List<Integer> findPassedLopHocPhanIds(@Param("masv") String masv, @Param("monhocId") Integer monhocId);

    @Query(value = """
      SELECT
          SUM(kqm.diem  * mh.sotc) / SUM(mh.sotc) AS gpa_he10,
          SUM(dhc.diem4 * mh.sotc) / SUM(mh.sotc) AS gpa_he4,
          SUM(mh.sotc)                             AS tong_tinchi,
          SUM(CASE WHEN kqm.diem >= 4
                   THEN mh.sotc ELSE 0 END)        AS tinchi_dat
      FROM   DangKyHoc    dkh
      JOIN   LopHocPhan   lhp ON dkh.lophocphan_id  = lhp.id
      JOIN   MonHoc_KiHoc mkh ON lhp.monhockihoc_id = mkh.id
      JOIN   MonHoc        mh ON mkh.monhoc_id       = mh.id
      JOIN   KetQuaMon    kqm ON dkh.id             = kqm.dangkyhoc_id
      JOIN   DiemHeChu    dhc ON kqm.diemhechu_id   = dhc.id
      WHERE  dkh.sinhvien_id = :masv
        AND  mkh.kihoc_id    = :kihocId
    """, nativeQuery = true)
    List<Object[]> calcGpaBySvAndKi(@Param("masv") String masv, @Param("kihocId") Integer kihocId);
}
