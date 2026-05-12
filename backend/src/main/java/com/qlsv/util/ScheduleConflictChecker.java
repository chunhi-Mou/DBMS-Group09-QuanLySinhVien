package com.qlsv.util;

import com.qlsv.model.BuoiHoc;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public final class ScheduleConflictChecker {
    private ScheduleConflictChecker() {}

    public static String slotKey(BuoiHoc b) {
        return b.getTuan().getId() + ":" + b.getNgay().getId() + ":" + b.getKipHoc().getId();
    }

    /** Returns slot keys that appear in both lists (conflicts). */
    public static Set<String> intersect(List<BuoiHoc> a, List<BuoiHoc> b) {
        Set<String> ka = a.stream().map(ScheduleConflictChecker::slotKey).collect(Collectors.toSet());
        Set<String> kb = b.stream().map(ScheduleConflictChecker::slotKey).collect(Collectors.toSet());
        ka.retainAll(kb);
        return ka;
    }
}
