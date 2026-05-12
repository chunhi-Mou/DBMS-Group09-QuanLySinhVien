import http from '../axios';
export const studentApi = {
  dashboard: () => http.get('/student/dashboard').then(r => r.data.data),
  available: (kiHocId) => http.get('/student/registration/available', { params: { kiHocId } }).then(r => r.data.data),
  register: (lopHocPhanIds) => http.post('/student/registration', { lopHocPhanIds }).then(r => r.data.data),
  cancel: (dangKyHocId) => http.delete(`/student/registration/${dangKyHocId}`).then(r => r.data),
  schedule: (kiHocId) => http.get('/student/schedule', { params: { kiHocId } }).then(r => r.data.data),
  grades: (kiHocId) => http.get('/student/grades', { params: { kiHocId } }).then(r => r.data.data),
};
