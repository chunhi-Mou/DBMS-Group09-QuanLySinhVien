import http from '../axios';

export const authApi = {
    login: (data) => http.post('/auth/login', data).then(r => r.data.data),
    changePassword: (data) => http.post('/auth/change-password', data).then(r => r.data),
};
