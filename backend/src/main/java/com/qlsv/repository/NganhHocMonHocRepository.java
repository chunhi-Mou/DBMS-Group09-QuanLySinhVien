package com.qlsv.repository;
import com.qlsv.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
public interface NganhHocMonHocRepository extends JpaRepository<NganhHocMonHoc, NganhHocMonHocId> {
    @Query("SELECT nm FROM NganhHocMonHoc nm WHERE nm.nganh.id IN :nganhIds")
    List<NganhHocMonHoc> findByNganhIds(List<Integer> nganhIds);
    List<NganhHocMonHoc> findByNganh_Id(Integer nganhId);
    void deleteByNganh_Id(Integer nganhId);
}
