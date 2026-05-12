import { Layout, Menu } from 'antd';
import { useNavigate, useLocation } from 'react-router-dom';
import {
    Home, BookOpen, Calendar, GraduationCap, Users, Building2,
    Layers, Settings, ClipboardList, BarChart3, Lock
} from 'lucide-react';

const ICON = (I) => <I size={16} />;

const ITEMS = {
    SV: [
        { key: '/student', icon: ICON(Home), label: 'Trang chủ' },
        { key: '/student/registration', icon: ICON(BookOpen), label: 'Đăng ký tín chỉ' },
        { key: '/student/schedule', icon: ICON(Calendar), label: 'Lịch học' },
        { key: '/student/grades', icon: ICON(GraduationCap), label: 'Bảng điểm' },
        { key: '/change-password', icon: ICON(Lock), label: 'Đổi mật khẩu' },
    ],
    GV: [
        { key: '/teacher', icon: ICON(Home), label: 'Trang chủ' },
        { key: '/teacher/lop-day', icon: ICON(BookOpen), label: 'Lớp đang dạy' },
        { key: '/teacher/schedule', icon: ICON(Calendar), label: 'Lịch dạy' },
        { key: '/change-password', icon: ICON(Lock), label: 'Đổi mật khẩu' },
    ],
    ADMIN: [
        { key: '/admin', icon: ICON(Home), label: 'Trang chủ' },
        { key: '/admin/accounts', icon: ICON(Users), label: 'Tài khoản' },
        {
            type: 'group', label: 'Cấu trúc', children: [
                { key: '/admin/khoa-bomon', icon: ICON(Building2), label: 'Khoa & Bộ môn' },
                { key: '/admin/nganh-monhoc', icon: ICON(Layers), label: 'Ngành & Môn học' },
                { key: '/admin/cau-hinh-diem', icon: ICON(Settings), label: 'Cấu hình điểm' },
            ]
        },
        {
            type: 'group', label: 'Đào tạo', children: [
                { key: '/admin/training/ki-hoc', icon: ICON(Calendar), label: 'Năm học & Kỳ' },
                { key: '/admin/training/lop-hoc-phan', icon: ICON(BookOpen), label: 'Lớp học phần' },
                { key: '/admin/training/lich-hoc', icon: ICON(Calendar), label: 'Lịch học' },
                { key: '/admin/training/tong-ket', icon: ICON(ClipboardList), label: 'Tổng kết kỳ' },
            ]
        },
        {
            type: 'group', label: 'Báo cáo', children: [
                { key: '/admin/reports/hoc-luc', icon: ICON(BarChart3), label: 'Báo cáo học lực' },
            ]
        },
        { key: '/change-password', icon: ICON(Lock), label: 'Đổi mật khẩu' },
    ]
};

export default function RoleSidebar({ role }) {
    const nav = useNavigate();
    const loc = useLocation();
    return (
        <Layout.Sider width={240} style={{ background: 'var(--sidebar-bg, #1a1a1a)' }}>
            <div style={{ 
                color: '#fff', 
                padding: '16px 16px 12px', 
                fontWeight: 700, 
                fontSize: 18,
                borderBottom: '1px solid rgba(255,255,255,0.08)',
                marginBottom: 4
            }}>QLSV</div>
            <Menu
                mode="inline"
                theme="dark"
                className="sidebar-menu"
                style={{ 
                    background: 'var(--sidebar-bg, #1a1a1a)',
                    borderRight: 'none'
                }}
                selectedKeys={[loc.pathname]}
                items={ITEMS[role] || []}
                onClick={(e) => nav(e.key)}
            />
            <style>{`
                .sidebar-menu .ant-menu-item {
                    margin: 2px 0 !important;
                    padding: 12px 16px !important;
                    height: auto !important;
                    line-height: 1.4 !important;
                    border-radius: 0 !important;
                    color: var(--sidebar-text, #e0e0e0) !important;
                    transition: all 200ms cubic-bezier(0.16, 1, 0.3, 1) !important;
                    border-left: 3px solid transparent;
                }
                .sidebar-menu .ant-menu-item:hover {
                    background: var(--sidebar-hover-bg, #252525) !important;
                    color: #fff !important;
                }
                .sidebar-menu .ant-menu-item-selected {
                    background: var(--sidebar-active-bg, #2d2d2d) !important;
                    color: #fff !important;
                    border-left: 3px solid var(--color-primary, #C00000) !important;
                    font-weight: 500;
                }
                .sidebar-menu .ant-menu-item-group-title {
                    color: var(--sidebar-text-muted, #999999) !important;
                    font-size: 11px !important;
                    text-transform: uppercase !important;
                    letter-spacing: 0.5px !important;
                    padding: 16px 16px 4px !important;
                }
            `}</style>
        </Layout.Sider>
    );
}
