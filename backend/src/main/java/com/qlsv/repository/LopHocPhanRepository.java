package com.qlsv.repository;
import com.qlsv.model.LopHocPhan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
public interface LopHocPhanRepository extends JpaRepository<LopHocPhan, Integer> {
    @Query("""
      SELECT lhp FROM LopHocPhan lhp
      WHERE lhp.monHocKiHoc.kiHoc.id = :kiHocId
        AND lhp.monHocKiHoc.monHoc.id IN :monHocIds
    """)
    List<LopHocPhan> findByKiHocAndMonHocIds(Integer kiHocId, List<Integer> monHocIds);

    List<LopHocPhan> findByMonHocKiHoc_Id(Integer monHocKiHocId);
    List<LopHocPhan> findByMonHocKiHoc_KiHoc_Id(Integer kiHocId);

    @Query(value = """
      SELECT lhp.id,
             lhp.ten,
             lhp.sisotoida,
             COUNT(dkh.id)  AS sisohientai,
             mh.ten         AS mon_hoc,
             mh.sotc
      FROM   LopHocPhan    lhp
      JOIN   MonHoc_KiHoc  mkh ON lhp.monhockihoc_id = mkh.id
      JOIN   MonHoc         mh ON mkh.monhoc_id       = mh.id
      LEFT   JOIN DangKyHoc dkh ON dkh.lophocphan_id  = lhp.id
      WHERE  mkh.kihoc_id = :kihocId
        AND  mkh.monhoc_id IN (
             SELECT nm.monhoc_id
             FROM   NganhHoc_MonHoc nm
             JOIN   SinhVien_Nganh  sn ON nm.nganh_id = sn.nganh_id
             WHERE  sn.sinhvien_id = :masv
        )
      GROUP  BY lhp.id, lhp.ten, lhp.sisotoida, mh.ten, mh.sotc
    """, nativeQuery = true)
    List<Object[]> findAvailableSectionsWithCapacity(@Param("kihocId") Integer kihocId, @Param("masv") String masv);
}
