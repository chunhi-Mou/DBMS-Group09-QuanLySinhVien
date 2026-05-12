package com.qlsv.seed;

import java.util.List;

public final class SeedFileMap {
    public record Item(String table, String file) {}

    public static final List<Item> ORDER = List.of(
        new Item("DiaChi", "DiaChi.json"),
        new Item("Truong", "Truong.json"),
        new Item("Khoa", "Khoa.json"),
        new Item("BoMon", "BoMon.json"),
        new Item("ThanhVien", "ThanhVien.json"),
        new Item("SinhVien", "SinhVien.json"),
        new Item("GiangVien", "GiangVien.json"),
        new Item("NhanVien", "NhanVien.json"),
        new Item("NganhHoc", "NganhHoc.json"),
        new Item("LopHanhChinh", "LopHanhChinh.json"),
        new Item("SinhVien_Nganh", "SinhVien_Nganh.json"),
        new Item("MonHoc", "MonHoc.json"),
        new Item("NganhHoc_MonHoc", "NganhHoc_MonHoc.json"),
        new Item("DauDiem", "DauDiem.json"),
        new Item("MonHoc_DauDiem", "MonHoc_DauDiem.json"),
        new Item("NamHoc", "NamHoc.json"),
        new Item("HocKi", "HocKi.json"),
        new Item("KiHoc", "KiHoc.json"),
        new Item("MonHoc_KiHoc", "MonHoc_KiHoc.json"),
        new Item("LopHocPhan", "LopHocPhan.json"),
        new Item("GiangVien_LopHocPhan", "GiangVien_LopHocPhan.json"),
        new Item("PhongHoc", "PhongHoc.json"),
        new Item("TuanHoc", "TuanHoc.json"),
        new Item("NgayHoc", "NgayHoc.json"),
        new Item("KipHoc", "KipHoc.json"),
        new Item("BuoiHoc", "BuoiHoc.json"),
        new Item("DangKyHoc", "DangKyHoc.json"),
        new Item("DiemThanhPhan", "DiemThanhPhan.json"),
        new Item("DiemHeChu", "DiemHeChu.json"),
        new Item("KetQuaMon", "KetQuaMon.json"),
        new Item("LoaiHocLuc", "LoaiHocLuc.json"),
        new Item("TONGKET_HOCKI", "TONGKET_HOCKI.json")
    );
}
