import { BrowserRouter, Routes, Route } from 'react-router-dom';
import AuthLayout from '../layouts/AuthLayout';
import MainLayout from '../layouts/MainLayout';
import ProtectedRoute from './ProtectedRoute';
import RoleRoute from './RoleRoute';
import HomeRedirect from '../pages/HomeRedirect';
import Login from '../pages/auth/Login';
import ChangePassword from '../pages/ChangePassword';
import StudentDashboard from '../pages/student/Dashboard';
import DangKyTinChi from '../pages/student/DangKyTinChi';
import LichHoc from '../pages/student/LichHoc';
import BangDiem from '../pages/student/BangDiem';
import TeacherDashboard from '../pages/teacher/Dashboard';
import LopDay from '../pages/teacher/LopDay';
import NhapDiem from '../pages/teacher/NhapDiem';
import LichDay from '../pages/teacher/LichDay';
import AdminDashboard from '../pages/admin/Dashboard';
import TaiKhoan from '../pages/admin/TaiKhoan';
import KhoaBoMon from '../pages/admin/KhoaBoMon';
import NganhMonHoc from '../pages/admin/NganhMonHoc';
import CurriculumBuilder from '../pages/admin/NganhMonHoc/CurriculumBuilder';
import CauHinhDiem from '../pages/admin/CauHinhDiem';
import KiHocPage from '../pages/admin/KiHoc';
import AdminLopHocPhan from '../pages/admin/LopHocPhan';
import AdminLichHoc from '../pages/admin/LichHoc';
import TongKetKy from '../pages/admin/TongKetKy';
import BaoCaoHocLuc from '../pages/admin/BaoCaoHocLuc';

export default function AppRouter() {
    return (
        <BrowserRouter>
            <Routes>
                <Route element={<AuthLayout />}>
                    <Route path="/login" element={<Login />} />
                </Route>

                <Route element={<ProtectedRoute />}>
                    <Route element={<MainLayout />}>
                        <Route path="/" element={<HomeRedirect />} />
                        <Route path="/change-password" element={<ChangePassword />} />

                        <Route element={<RoleRoute allow={['SV']} />}>
                            <Route path="/student" element={<StudentDashboard />} />
                            <Route path="/student/registration" element={<DangKyTinChi />} />
                            <Route path="/student/schedule" element={<LichHoc />} />
                            <Route path="/student/grades" element={<BangDiem />} />
                        </Route>
                        <Route element={<RoleRoute allow={['GV']} />}>
                            <Route path="/teacher" element={<TeacherDashboard />} />
                            <Route path="/teacher/lop-day" element={<LopDay />} />
                            <Route path="/teacher/grades/:lhpId" element={<NhapDiem />} />
                            <Route path="/teacher/schedule" element={<LichDay />} />
                        </Route>
                        <Route element={<RoleRoute allow={['ADMIN']} />}>
                            <Route path="/admin" element={<AdminDashboard />} />
                            <Route path="/admin/accounts" element={<TaiKhoan />} />
                            <Route path="/admin/khoa-bomon" element={<KhoaBoMon />} />
                            <Route path="/admin/nganh-monhoc" element={<NganhMonHoc />} />
                            <Route path="/admin/nganh-monhoc/curriculum/:nganhId" element={<CurriculumBuilder />} />
                            <Route path="/admin/cau-hinh-diem" element={<CauHinhDiem />} />
                            <Route path="/admin/training/ki-hoc" element={<KiHocPage />} />
                            <Route path="/admin/training/lop-hoc-phan" element={<AdminLopHocPhan />} />
                            <Route path="/admin/training/lich-hoc" element={<AdminLichHoc />} />
                            <Route path="/admin/training/tong-ket" element={<TongKetKy />} />
                            <Route path="/admin/reports/hoc-luc" element={<BaoCaoHocLuc />} />
                        </Route>
                    </Route>
                </Route>
            </Routes>
        </BrowserRouter>
    );
}
