package com.qlsv.repository;

import com.qlsv.model.LopHanhChinh;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LopHanhChinhRepository extends JpaRepository<LopHanhChinh, Integer> {
    List<LopHanhChinh> findByNganh_Id(Integer nganhId);
}
