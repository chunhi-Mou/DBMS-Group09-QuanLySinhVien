package com.qlsv.repository;
import com.qlsv.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface MonHocDauDiemRepository extends JpaRepository<MonHocDauDiem, MonHocDauDiemId> {
    List<MonHocDauDiem> findByMonHoc_Id(Integer monHocId);
    void deleteByMonHoc_Id(Integer monHocId);
}
