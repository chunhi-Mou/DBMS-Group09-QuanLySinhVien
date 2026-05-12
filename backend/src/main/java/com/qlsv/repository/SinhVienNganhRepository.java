package com.qlsv.repository;
import com.qlsv.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
public interface SinhVienNganhRepository extends JpaRepository<SinhVienNganh, SinhVienNganhId> {
    @Query("SELECT sn FROM SinhVienNganh sn WHERE sn.sinhVien.maSv = :maSv")
    List<SinhVienNganh> findByMaSv(String maSv);
    List<SinhVienNganh> findByNganh_Id(Integer nganhId);

    @org.springframework.data.jpa.repository.Query("SELECT sn.nganh.khoa.ten, COUNT(sn) FROM SinhVienNganh sn GROUP BY sn.nganh.khoa.ten")
    java.util.List<Object[]> countByKhoa();
}
