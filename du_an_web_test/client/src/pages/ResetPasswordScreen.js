import React, { useState } from 'react';
import { ShieldOff, Eye, EyeOff } from 'lucide-react'; // Import Eye
import { resetPassword } from '../services/api'; 

export const ResetPasswordScreen = ({ currentUser, setPath }) => {
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

    // State hiển thị
    const [showPass, setShowPass] = useState(false);
    const [showConfirm, setShowConfirm] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        if (password.length < 6) return setError('Mật khẩu phải có ít nhất 6 ký tự.');
        if (password !== confirmPassword) return setError('Mật khẩu không khớp.');
        if (!currentUser || !currentUser.id) return setError('Lỗi user ID.');

        setIsSubmitting(true);
        try {
            await resetPassword(currentUser.id, password); 
            alert('Đặt mật khẩu thành công! Vui lòng đăng nhập lại.');
            localStorage.clear();
            window.location.href = '/'; 
        } catch (err) {
            setError(err.message || 'Lỗi hệ thống.');
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 p-4">
            <div className="w-full max-w-md bg-white rounded-xl shadow-2xl p-8">
                <div className="text-center mb-6">
                    <ShieldOff className="w-10 h-10 text-orange-500 mx-auto mb-3" />
                    <h2 className="text-2xl font-bold text-gray-900">Yêu cầu Đổi Mật khẩu</h2>
                    <p className="text-sm text-gray-600 mt-2">Xin chào <strong>{currentUser?.fullName}</strong>. Vui lòng thiết lập mật khẩu mới.</p>
                </div>
                <form onSubmit={handleSubmit} className="space-y-4">
                    
                    {/* Mật khẩu mới */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu Mới</label>
                        <div className="relative">
                            <input
                                type={showPass ? "text" : "password"}
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg pr-10 focus:ring-2 focus:ring-orange-500 focus:outline-none"
                                required
                            />
                            <button
                                type="button"
                                onClick={() => setShowPass(!showPass)}
                                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-orange-600"
                            >
                                {showPass ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                            </button>
                        </div>
                    </div>

                    {/* Xác nhận mật khẩu */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Xác nhận lại</label>
                        <div className="relative">
                            <input
                                type={showConfirm ? "text" : "password"}
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg pr-10 focus:ring-2 focus:ring-orange-500 focus:outline-none"
                                required
                            />
                            <button
                                type="button"
                                onClick={() => setShowConfirm(!showConfirm)}
                                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-orange-600"
                            >
                                {showConfirm ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                            </button>
                        </div>
                    </div>

                    {error && <div className="p-3 text-sm text-red-700 bg-red-100 rounded-lg">{error}</div>}
                    
                    <button
                        type="submit"
                        disabled={isSubmitting}
                        className="w-full py-2 px-4 rounded-lg text-white bg-orange-600 hover:bg-orange-700 font-bold"
                    >
                        {isSubmitting ? 'Đang xử lý...' : 'Xác nhận & Đăng nhập lại'}
                    </button>
                </form>
            </div>
        </div>
    );
};