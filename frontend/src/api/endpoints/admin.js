import http from '../axios';

export const adminApi = {
  // Accounts
  listAccounts: (vaiTro) => http.get('/admin/accounts', { params: { vaiTro } }).then(r => r.data),
  createAccount: (b) => http.post('/admin/accounts', b).then(r => r.data),
  updateAccount: (id, b) => http.put(`/admin/accounts/${id}`, b).then(r => r.data),
  resetPassword: (id, newPassword) => http.post(`/admin/accounts/${id}/reset-password`, { newPassword }).then(r => r.data),
  deleteAccount: (id) => http.delete(`/admin/accounts/${id}`).then(r => r.data),

  // Structure — Truong
  truongs: () => http.get('/admin/structure/truongs').then(r => r.data),
  createTruong: (b) => http.post('/admin/structure/truongs', b).then(r => r.data),
  updateTruong: (id, b) => http.put(`/admin/structure/truongs/${id}`, b).then(r => r.data),
  deleteTruong: (id) => http.delete(`/admin/structure/truongs/${id}`).then(r => r.data),

  // Structure — Khoa
  khoas: (truongId) => http.get('/admin/structure/khoas', { params: { truongId } }).then(r => r.data),
  createKhoa: (b) => http.post('/admin/structure/khoas', b).then(r => r.data),
  updateKhoa: (id, b) => http.put(`/admin/structure/khoas/${id}`, b).then(r => r.data),
  deleteKhoa: (id) => http.delete(`/admin/structure/khoas/${id}`).then(r => r.data),

  // Structure — BoMon
  boMons: (khoaId) => http.get('/admin/structure/bomons', { params: { khoaId } }).then(r => r.data),
  createBoMon: (b) => http.post('/admin/structure/bomons', b).then(r => r.data),
  updateBoMon: (id, b) => http.put(`/admin/structure/bomons/${id}`, b).then(r => r.data),
  deleteBoMon: (id) => http.delete(`/admin/structure/bomons/${id}`).then(r => r.data),

  // Structure — Nganh
  nganhs: (khoaId) => http.get('/admin/structure/nganhs', { params: { khoaId } }).then(r => r.data),
  createNganh: (b) => http.post('/admin/structure/nganhs', b).then(r => r.data),
  updateNganh: (id, b) => http.put(`/admin/structure/nganhs/${id}`, b).then(r => r.data),
  deleteNganh: (id) => http.delete(`/admin/structure/nganhs/${id}`).then(r => r.data),

  // Structure — MonHoc
  monHocs: (boMonId) => http.get('/admin/structure/monhocs', { params: { boMonId } }).then(r => r.data),
  createMonHoc: (b) => http.post('/admin/structure/monhocs', b).then(r => r.data),
  updateMonHoc: (id, b) => http.put(`/admin/structure/monhocs/${id}`, b).then(r => r.data),
  deleteMonHoc: (id) => http.delete(`/admin/structure/monhocs/${id}`).then(r => r.data),

  // Structure — Nganh <-> MonHoc
  getNganhMon: (nganhId) => http.get(`/admin/structure/nganhs/${nganhId}/monhocs`).then(r => r.data),
  setNganhMon: (nganhId, items) => http.put(`/admin/structure/nganhs/${nganhId}/monhocs`, { items }).then(r => r.data),

  // Structure — LopHanhChinh
  lopHanhChinhs: (nganhId) => http.get('/admin/structure/lophanhchinhs', { params: { nganhId } }).then(r => r.data),
  createLopHanhChinh: (b) => http.post('/admin/structure/lophanhchinhs', b).then(r => r.data),
  updateLopHanhChinh: (id, b) => http.put(`/admin/structure/lophanhchinhs/${id}`, b).then(r => r.data),
  deleteLopHanhChinh: (id) => http.delete(`/admin/structure/lophanhchinhs/${id}`).then(r => r.data),

  // Grade config — DauDiem
  dauDiems: () => http.get('/admin/grade-config/dau-diems').then(r => r.data),
  createDauDiem: (b) => http.post('/admin/grade-config/dau-diems', b).then(r => r.data),
  updateDauDiem: (id, b) => http.put(`/admin/grade-config/dau-diems/${id}`, b).then(r => r.data),
  deleteDauDiem: (id) => http.delete(`/admin/grade-config/dau-diems/${id}`).then(r => r.data),

  // Grade config — MonHoc-DauDiem
  getMonDauDiem: (monHocId) => http.get(`/admin/grade-config/monhocs/${monHocId}/dau-diems`).then(r => r.data),
  setMonDauDiem: (monHocId, items) => http.put(`/admin/grade-config/monhocs/${monHocId}/dau-diems`, { items }).then(r => r.data),

  // Grade config — DiemHeChu
  heChu: () => http.get('/admin/grade-config/he-chu').then(r => r.data),
  createHeChu: (b) => http.post('/admin/grade-config/he-chu', b).then(r => r.data),
  updateHeChu: (id, b) => http.put(`/admin/grade-config/he-chu/${id}`, b).then(r => r.data),
  deleteHeChu: (id) => http.delete(`/admin/grade-config/he-chu/${id}`).then(r => r.data),

  // Grade config — LoaiHocLuc
  hocLuc: () => http.get('/admin/grade-config/hoc-luc').then(r => r.data),
  createHocLuc: (b) => http.post('/admin/grade-config/hoc-luc', b).then(r => r.data),
  updateHocLuc: (id, b) => http.put(`/admin/grade-config/hoc-luc/${id}`, b).then(r => r.data),
  deleteHocLuc: (id) => http.delete(`/admin/grade-config/hoc-luc/${id}`).then(r => r.data),

  // Training: Năm học, Học kỳ, Kỳ học
  namHocs: () => http.get('/admin/training/nam-hocs').then(r => r.data),
  createNamHoc: (b) => http.post('/admin/training/nam-hocs', b).then(r => r.data),
  updateNamHoc: (id, b) => http.put(`/admin/training/nam-hocs/${id}`, b).then(r => r.data),
  deleteNamHoc: (id) => http.delete(`/admin/training/nam-hocs/${id}`).then(r => r.data),

  hocKis: () => http.get('/admin/training/hoc-kis').then(r => r.data),
  createHocKi: (b) => http.post('/admin/training/hoc-kis', b).then(r => r.data),
  updateHocKi: (id, b) => http.put(`/admin/training/hoc-kis/${id}`, b).then(r => r.data),
  deleteHocKi: (id) => http.delete(`/admin/training/hoc-kis/${id}`).then(r => r.data),

  kiHocs: (namId) => http.get('/admin/training/ki-hocs', { params: { namId } }).then(r => r.data),
  createKiHoc: (namHocId, hocKiId) => http.post('/admin/training/ki-hocs', null, { params: { namHocId, hocKiId } }).then(r => r.data),
  deleteKiHoc: (id) => http.delete(`/admin/training/ki-hocs/${id}`).then(r => r.data),

  monOfKi: (kiHocId) => http.get(`/admin/training/ki-hocs/${kiHocId}/mon-hocs`).then(r => r.data),
  assignMonToKi: (kiHocId, monHocIds) => http.put(`/admin/training/ki-hocs/${kiHocId}/mon-hocs`, { monHocIds }).then(r => r.data),

  // LopHocPhan
  adminLhps: (kiHocId) => http.get('/admin/training/lop-hoc-phans', { params: { kiHocId } }).then(r => r.data),
  createLhp: (b) => http.post('/admin/training/lop-hoc-phans', b).then(r => r.data),
  updateLhp: (id, b) => http.put(`/admin/training/lop-hoc-phans/${id}`, b).then(r => r.data),
  deleteLhp: (id) => http.delete(`/admin/training/lop-hoc-phans/${id}`).then(r => r.data),
  assignGv: (lhpId, giangVienIds) => http.put(`/admin/training/lop-hoc-phans/${lhpId}/giang-viens`, { giangVienIds }).then(r => r.data),

  // GV lookup
  giangViens: () => http.get('/admin/training/giang-viens').then(r => r.data),

  // Schedule lookups
  phongs: () => http.get('/admin/training/lookups/phongs').then(r => r.data),
  tuans: () => http.get('/admin/training/lookups/tuans').then(r => r.data),
  ngays: () => http.get('/admin/training/lookups/ngays').then(r => r.data),
  kips: () => http.get('/admin/training/lookups/kips').then(r => r.data),
  buoiByKi: (kiHocId) => http.get('/admin/training/buoi-hocs', { params: { kiHocId } }).then(r => r.data),
  createBuoi: (b) => http.post('/admin/training/buoi-hocs', b).then(r => r.data),
  deleteBuoi: (id) => http.delete(`/admin/training/buoi-hocs/${id}`).then(r => r.data),

  // Reports
  finalizeSemester: (kiHocId) => http.post(`/admin/ki-hocs/${kiHocId}/finalize`).then(r => r.data),
  reportHocLuc: (kiHocId) => http.get('/admin/reports/hoc-luc', { params: { kiHocId } }).then(r => r.data),

  // Dashboard
  adminDashboard: () => http.get('/admin/dashboard').then(r => r.data),
};
