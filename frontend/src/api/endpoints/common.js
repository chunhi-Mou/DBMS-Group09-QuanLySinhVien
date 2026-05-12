import http from '../axios';
export const commonApi = {
  kiHocList: () => http.get('/kihoc').then(r => r.data.data),
};
