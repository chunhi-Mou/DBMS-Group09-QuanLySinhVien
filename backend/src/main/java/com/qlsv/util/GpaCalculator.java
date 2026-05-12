package com.qlsv.util;

import java.util.List;

public final class GpaCalculator {
    private GpaCalculator() {}

    public interface Item {
        int sotc();
        Float diem10();
        Float diem4();
    }

    public record Result(float gpa10, float gpa4, int tongTc, int tcDat) {}

    public static Result calc(List<? extends Item> items) {
        if (items.isEmpty()) return new Result(0f, 0f, 0, 0);
        int tong = 0, dat = 0;
        double sum10 = 0, sum4 = 0;
        for (var it : items) {
            int tc = it.sotc();
            tong += tc;
            if (it.diem10() != null && it.diem10() >= 4f) dat += tc;
            if (it.diem10() != null) sum10 += it.diem10() * tc;
            if (it.diem4()  != null) sum4  += it.diem4()  * tc;
        }
        if (tong == 0) return new Result(0f, 0f, 0, 0);
        float g10 = Math.round(sum10 / tong * 100f) / 100f;
        float g4  = Math.round(sum4  / tong * 100f) / 100f;
        return new Result(g10, g4, tong, dat);
    }
}
