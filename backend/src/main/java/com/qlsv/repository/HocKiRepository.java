package com.qlsv.repository;
import com.qlsv.model.HocKi;
import org.springframework.data.jpa.repository.JpaRepository;
public interface HocKiRepository extends JpaRepository<HocKi, Integer> {
    java.util.List<HocKi> findAllByOrderByTenAsc();
}
