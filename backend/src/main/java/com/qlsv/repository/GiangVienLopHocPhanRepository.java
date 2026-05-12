package com.qlsv.repository;
import com.qlsv.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
public interface GiangVienLopHocPhanRepository extends JpaRepository<GiangVienLopHocPhan, GiangVienLopHocPhanId> {
    @Query("""
      SELECT g FROM GiangVienLopHocPhan g
      WHERE g.giangVien.thanhVien.username = :username
        AND g.lopHocPhan.monHocKiHoc.kiHoc.id = :kiHocId
    """)
    List<GiangVienLopHocPhan> findByUsernameAndKiHoc(String username, Integer kiHocId);

    @Query("SELECT g FROM GiangVienLopHocPhan g WHERE g.giangVien.thanhVien.username = :username")
    List<GiangVienLopHocPhan> findByUsername(String username);

    boolean existsByGiangVien_ThanhVien_UsernameAndLopHocPhan_Id(String username, Integer lhpId);

    List<GiangVienLopHocPhan> findByLopHocPhan_IdIn(List<Integer> lhpIds);

    java.util.List<GiangVienLopHocPhan> findByLopHocPhan_Id(Integer lhpId);
    void deleteByLopHocPhan_Id(Integer lhpId);
}
