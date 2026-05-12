import axios from 'axios';
const http = axios.create({ baseURL: '/api', timeout: 15000 });

http.interceptors.request.use((cfg) => {
    const token = localStorage.getItem('token');
    if (token) cfg.headers.Authorization = `Bearer ${token}`;
    return cfg;
});

http.interceptors.response.use(
    (res) => res,
    (err) => {
        if (err.response?.status === 401 && location.pathname !== '/login') {
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            location.href = '/login';
        }
        return Promise.reject(err);
    }
);

export default http;
