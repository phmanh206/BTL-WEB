// C:\Users\Admin\Downloads\DUANWEB(1)\client\src\pages\UsersScreen.js

import React, { useState, useMemo, useEffect } from 'react';
import { UserCheck, Search, Plus, Edit, Settings } from 'lucide-react';
// Import API thật để lấy dữ liệu và gửi yêu cầu
import { getUsers, createUser, updateUser, resetUserPassword } from '../services/api'; 
// Import các hằng số và hàm tiện ích
import { ROLES } from '../utils/constants';
import { formatCurrency, normalizeSearchableValue, getRoleId } from '../utils/helpers';
// Import Modal component
import { UserFormModal } from '../components/UserFormModal'; 

export const UsersScreen = ({ currentUser }) => {
    const [users, setUsers] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState(''); 
    
    // State quản lý Modal và người dùng đang chỉnh sửa
    const [isUserModalOpen, setIsUserModalOpen] = useState(false);
    const [editingUser, setEditingUser] = useState(null); 

    // Chỉ Owner mới có quyền quản lý nhân viên
    const canEdit = currentUser.roleName === ROLES.OWNER.name;

    // --- LẤY DỮ LIỆU TỪ API ---
    const fetchUsers = async () => {
        setIsLoading(true);
        setError(null);
        try {
            // Giả định API /api/users trả về danh sách nhân viên đầy đủ
            const data = await getUsers(); 
            // Dữ liệu trả về: [{ user_id: 'OWNER1', fullName: '...', roleName: 'Owner', ...}, ...]
            setUsers(data);
        } catch (err) {
            setError(err.message || 'Không thể tải danh sách nhân viên từ máy chủ.');
            console.error(err);
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        if (canEdit) {
            fetchUsers();
        } else {
            setIsLoading(false);
            setError('Bạn không có quyền truy cập trang quản lý nhân viên.');
        }
    }, [canEdit]); 

    // --- LOGIC TÌM KIẾM TOÀN DIỆN TRÊN CLIENT ---
    const filteredUsers = useMemo(() => {
        if (!searchTerm) return users;
        const lowerCaseSearch = normalizeSearchableValue(searchTerm);

        return users.filter(u => {
            return Object.values(u).some(value => {
                return normalizeSearchableValue(value).includes(lowerCaseSearch);
            });
        });
    }, [users, searchTerm]);
    
    // --- HÀM XỬ LÝ HÀNH ĐỘNG ---

    // Hàm xử lý khi nhấn nút Thêm nhân viên
    const handleAddNew = () => {
        setEditingUser(null);
        setIsUserModalOpen(true);
    };

    // Hàm xử lý khi nhấn nút Sửa
    const handleEdit = (user) => {
        setEditingUser(user);
        setIsUserModalOpen(true);
    };

    // Hàm xử lý Reset Mật khẩu
    const handleResetPassword = async (userToReset) => {
        if (userToReset.roleName === ROLES.OWNER.name && currentUser.roleName !== ROLES.OWNER.name) {
            alert('Bạn không có quyền reset mật khẩu Owner.');
            return;
        }
        
        if (window.confirm(`Bạn có chắc chắn muốn RESET MẬT KHẨU cho tài khoản ${userToReset.fullName} không? Mật khẩu sẽ được đặt lại về Mã NV và họ BUỘC phải đổi khi đăng nhập.`)) {
            try {
                // TODO: Gọi API reset mật khẩu (Backend sẽ đặt lại password_hash và must_change_password=TRUE)
                // await resetUserPassword(userToReset.id); 
                alert(`[API CALL] Đã gửi yêu cầu reset mật khẩu cho ${userToReset.fullName}.`);
                fetchUsers(); // Tải lại dữ liệu để cập nhật cờ "Cần đổi MK"
            } catch (err) {
                alert(`Reset mật khẩu thất bại: ${err.message}`);
            }
        }
    };

    // Hàm lưu dữ liệu từ modal (Thêm mới hoặc Cập nhật)
    const handleSaveUser = async (data, isNew) => {
        try {
            if (isNew) {
                // await createUser(data); // GỌI API THÊM MỚI
                alert(`[API CALL] Tạo tài khoản ${data.username} thành công.`);
            } else {
                // await updateUser(data.id, data); // GỌI API CẬP NHẬT
                alert(`[API CALL] Cập nhật thông tin cho ${data.fullName} thành công.`);
            }
            fetchUsers(); // Tải lại dữ liệu sau khi thành công
        } catch (err) {
            alert(`Thao tác thất bại: ${err.message}`);
        }
    };

    // --- RENDER HỌC (Loading, Error) ---
    if (isLoading) {
        return <p className="p-6 text-center text-xl text-blue-600 font-semibold">Đang tải danh sách nhân viên từ Server...</p>;
    }
    
    if (error) {
        return <p className="p-6 text-center text-xl text-red-600 font-semibold">Lỗi: {error}</p>;
    }

    return (
        <div className="space-y-6 p-4 md:p-6">
            <h1 className="text-3xl font-bold text-gray-900">Quản lý Nhân viên (Users)</h1>
            

            <div className="bg-white p-4 rounded-xl shadow-lg">
                <div className="flex flex-col sm:flex-row justify-between items-center mb-4 gap-3">
                    {/* Ô TÌM KIẾM */}
                    <div className="relative flex-grow w-full sm:w-auto">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Tìm kiếm theo mã, tên, tài khoản, vai trò..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500 transition duration-150"
                        />
                    </div>
                    {canEdit && (
                        <button 
                            onClick={handleAddNew}
                            className="flex items-center bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition duration-200 w-full sm:w-auto"
                        >
                            <Plus className="w-5 h-5 mr-1" /> Thêm nhân viên
                        </button>
                    )}
                </div>

                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mã NV</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Họ tên</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tài khoản</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Vai trò</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">P.Ban / Loại NV</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Lương cơ bản</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trạng thái</th>
                                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Hành động</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {filteredUsers.map((u) => {
                                // Backend nên trả về commissionRate và status dưới dạng camelCase/snake_case
                                const commissionText = u.commission_rate > 0 ? ` (+${(u.commission_rate * 100).toFixed(1)}% HH)` : '';

                                return (
                                    <tr key={u.id} className="hover:bg-gray-50">
                                        <td className="px-4 py-4 whitespace-nowrap text-sm font-medium text-blue-600">{u.id}</td>
                                        <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900">{u.fullName}</td>
                                        <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900 font-mono">{u.username}</td>
                                        <td className="px-4 py-4 whitespace-nowrap text-sm text-indigo-600 font-semibold">{u.roleName}</td>
                                        <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-700">{u.department} / {u.employee_type}</td>
                                        <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-900">{formatCurrency(u.base_salary)}{commissionText}</td>
                                        <td className="px-4 py-4 whitespace-nowrap text-sm">
                                            {u.status === 'Active' ? <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Active</span> : <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">Inactive</span>}
                                            {/* Giả định Backend trả về must_change_password */}
                                            {u.must_change_password && <span className="ml-2 px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">Cần đổi MK</span>}
                                        </td>
                                        <td className="px-4 py-4 whitespace-nowrap text-right text-sm font-medium">
                                            {canEdit && (
                                                <button 
                                                    title="Sửa thông tin" 
                                                    onClick={() => handleEdit(u)}
                                                    className="text-indigo-600 hover:text-indigo-900 mr-3 p-1 rounded-full hover:bg-indigo-100 transition"
                                                >
                                                    <Edit className="w-5 h-5" />
                                                </button>
                                            )}
                                            {canEdit && (
                                                <button 
                                                    title="Reset Mật khẩu (Buộc đổi)" 
                                                    onClick={() => handleResetPassword(u)}
                                                    className="text-orange-600 hover:text-orange-900 mr-3 p-1 rounded-full hover:bg-orange-100 transition"
                                                >
                                                    <Settings className="w-5 h-5" />
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                )}
                            )}
                        </tbody>
                    </table>
                    {filteredUsers.length === 0 && <p className="text-center py-8 text-gray-500">Không tìm thấy nhân viên nào.</p>}
                </div>
            </div>
            
            {/* Modal Thêm/Sửa */}
            {canEdit && (
                <UserFormModal 
                    isOpen={isUserModalOpen}
                    onClose={() => setIsUserModalOpen(false)}
                    initialData={editingUser}
                    onSave={handleSaveUser}
                    currentUsers={users} // Truyền danh sách hiện tại để tính ID mới
                    currentUser={currentUser}
                />
            )}
        </div>
    );
};