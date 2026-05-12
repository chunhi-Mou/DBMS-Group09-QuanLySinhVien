import http from '../axios';

export const teacherApi = {
  dashboard: () => http.get('/teacher/dashboard').then(r => r.data),
  classes: (kiHocId) => http.get('/teacher/classes', { params: kiHocId ? { kiHocId } : {} }).then(r => r.data),
  gradeBook: (lhpId) => http.get(`/teacher/lhp/${lhpId}/grades`).then(r => r.data),
  saveGrades: (lhpId, entries) => http.put(`/teacher/lhp/${lhpId}/grades`, { entries }).then(r => r.data),
  finalize: (lhpId) => http.post(`/teacher/lhp/${lhpId}/finalize`).then(r => r.data),
  schedule: (kiHocId) => http.get('/teacher/schedule', { params: { kiHocId } }).then(r => r.data),
};
