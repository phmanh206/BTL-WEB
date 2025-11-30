// /client/src/services/api.js

import axios from 'axios';

const api = axios.create({
    baseURL: '/api', 
    headers: {
        'Content-Type': 'application/json',
    },
    validateStatus: (status) => status >= 200 && status < 500, 
});

// INTERCEPTOR
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('jwt_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, (error) => Promise.reject(error));

// --- AUTH ---
export const login = async (username, password) => {
    const response = await api.post('/auth/login', { username, password });
    if (response.status !== 200) throw response.data || { message: 'Lỗi đăng nhập.' };
    return response.data;
};

export const register = async (fullName, phone, password) => {
    const response = await api.post('/auth/register', { fullName, phone, password });
    if (response.status !== 201 && response.status !== 200) throw response.data || { message: 'Đăng ký thất bại.' };
    return response.data;
};

export const updatePassword = async (userId, oldPassword, newPassword) => {
    const response = await api.post('/auth/change-password', { userId, oldPassword, newPassword });
    if (response.status !== 200) throw response.data || { message: 'Đổi mật khẩu thất bại.' };
    return response.data;
};

export const resetPassword = async (userId, newPassword) => {
    const response = await api.post('/auth/reset-password', { userId, newPassword });
    if (response.status !== 200) throw response.data || { message: 'Đặt lại mật khẩu thất bại.' };
    return response.data;
};

// --- DATA LISTING ---

export const getProducts = async () => {
    const response = await api.get('/products');
    if (response.status !== 200) throw response.data || { message: 'Lỗi tải sản phẩm.' };
    return response.data;
};

// MỚI THÊM: Hàm lấy Danh mục (Fix lỗi ShopScreen)
export const getCategories = async () => {
    const response = await api.get('/categories');
    if (response.status !== 200) throw response.data || { message: 'Lỗi tải danh mục.' };
    return response.data;
};

export const getCustomers = async () => {
    const response = await api.get('/customers');
    if (response.status !== 200) throw response.data || { message: 'Lỗi tải khách hàng.' };
    return response.data;
};

export const getUsers = async () => {
    const response = await api.get('/users');
    if (response.status !== 200) throw response.data || { message: 'Lỗi tải nhân viên.' };
    return response.data;
};

export const getOrders = async () => {
    const response = await api.get('/orders');
    if (response.status !== 200) throw response.data || { message: 'Lỗi tải đơn hàng.' };
    return response.data;
};

export const getSalaries = async () => {
    const response = await api.get('/salaries');
    if (response.status !== 200) throw response.data || { message: 'Lỗi tải bảng lương.' };
    return response.data;
};

export const getStockInReceipts = async () => {
    const response = await api.get('/stockin');
    if (response.status !== 200) throw response.data || { message: 'Lỗi tải phiếu nhập.' };
    return response.data;
};

// --- DASHBOARD ---
export const getMonthlySummaryData = async (year) => {
    const response = await api.get(`/dashboard/summary?year=${year}`); 
    if (response.status !== 200) throw response.data || { message: 'Lỗi Dashboard Summary.' };
    return response.data;
};

export const getDashboardCurrentStats = async () => {
    const response = await api.get('/dashboard/current-stats'); 
    if (response.status !== 200) throw response.data || { message: 'Lỗi Dashboard Stats.' };
    return response.data;
};

export default api;