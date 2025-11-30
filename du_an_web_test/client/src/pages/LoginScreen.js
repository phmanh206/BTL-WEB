import React, { useState } from 'react';
import { Eye, EyeOff, Facebook, QrCode, HelpCircle } from 'lucide-react'; 
import { login, register } from '../services/api'; 
import { roleToRoutes, ROLES } from '../utils/constants';
import ShopLogo from '../assets/shop-logo-konen.png'; 
import  Footer from '../components/Footer';

// --- COMPONENT INPUT FIELD (STYLE SHOPEE) ---
// Loại bỏ icon bên trái, chỉ giữ border và focus màu cam
const InputField = ({ type, value, onChange, placeholder, showToggle, onToggle, isShow }) => (
    <div className="mb-4">
        <div className="relative group">
            <input
                type={type}
                value={value}
                onChange={onChange}
                placeholder={placeholder}
                className="w-full px-4 py-3 border border-gray-300 rounded-sm focus:outline-none focus:border-[#ee4d2d] focus:ring-1 focus:ring-[#ee4d2d] transition duration-150 text-sm"
                required
            />
            {showToggle && (
                <button
                    type="button"
                    onClick={onToggle}
                    className="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600 focus:outline-none"
                >
                    {isShow ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
            )}
        </div>
    </div>
);

export const LoginScreen = ({ setPath, setUser, setIsLoggedIn }) => {
    // --- STATE CHUNG ---
    const [isRegistering, setIsRegistering] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');

    // --- STATE ĐĂNG NHẬP ---
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false); 

    // --- STATE ĐĂNG KÝ ---
    const [regFullName, setRegFullName] = useState('');
    const [regPhone, setRegPhone] = useState('');
    const [regPassword, setRegPassword] = useState('');
    const [regConfirmPassword, setRegConfirmPassword] = useState('');
    const [showRegPassword, setShowRegPassword] = useState(false);
    const [showRegConfirmPassword, setShowRegConfirmPassword] = useState(false);

    // ==========================================
    // LOGIC XỬ LÝ (GIỮ NGUYÊN)
    // ==========================================
    const handleLogin = async (e) => { 
        e.preventDefault();
        setError('');
        setIsLoading(true);
        try {
            const data = await login(username, password); 
            const user = data.user;
            localStorage.setItem('jwt_token', data.token);
            localStorage.setItem('user_role_name', user.roleName);
            localStorage.setItem('user_id', user.userId);
            localStorage.setItem('user_name', user.fullName);

            const fullUser = { ...user, roleName: user.roleName, must_change_password: user.mustChangePassword };
            setUser(fullUser);
            setIsLoggedIn(true);

            if (user.mustChangePassword) { setPath('/reset-password'); } 
            else if (user.roleName === 'Customer' || user.roleName === ROLES.CUSTOMER.name) { setPath('/shop'); } 
            else if (user.roleName === ROLES.OWNER.name) { setPath('/dashboard'); } 
            else { const defaultPath = roleToRoutes[user.roleName]?.[0]?.path || '/products'; setPath(defaultPath); }
        } catch (err) { setError(err.message || 'Lỗi đăng nhập.'); } 
        finally { setIsLoading(false); }
    };

    const handleRegister = async (e) => {
        e.preventDefault();
        setError('');
        if (!regFullName.trim() || !regPhone.trim() || !regPassword.trim()) return setError('Vui lòng điền đầy đủ thông tin.');
        if (regPassword.length < 6) return setError('Mật khẩu quá ngắn.');
        if (regPassword !== regConfirmPassword) return setError('Mật khẩu không khớp.');

        setIsLoading(true);
        try {
            await register(regFullName, regPhone, regPassword);
            alert('Đăng ký thành công! Vui lòng đăng nhập.');
            setIsRegistering(false);
            setUsername(regPhone); setPassword(''); setRegFullName(''); setRegPhone(''); setRegPassword(''); setRegConfirmPassword('');
        } catch (err) { setError(err.message || 'Đăng ký thất bại.'); } 
        finally { setIsLoading(false); }
    };

    const handleSocialLogin = (platform) => {
        alert(`Đăng nhập ${platform} đang phát triển!`);
    };

    // ==========================================
    // GIAO DIỆN (STYLE SHOPEE)
    // ==========================================
    return (
        <div className="min-h-screen flex flex-col font-sans bg-[#f5f5f5]">
            
            {/* 1. HEADER TRẮNG */}
            <header className="bg-white h-20 shadow-sm flex items-center justify-between px-6 lg:px-20 z-10">
                <div className="flex items-center gap-4">
                    <img src={ShopLogo} alt="Logo" className="h-12 w-12 object-contain" />
                    <span className="text-2xl font-semibold text-[#a87103]">
                        {isRegistering ? 'Đăng Ký' : 'Đăng Nhập'}
                    </span>
                </div>
                <a href="#" className="text-[#a87103] text-sm font-medium hover:underline flex items-center gap-1">
                    <HelpCircle className="w-4 h-4" /> Bạn cần giúp đỡ?
                </a>
            </header>

            {/* 2. BODY MÀU CAM */}
            <div className="flex-1 bg-gradient-to-br from-indigo-100 via-purple-100 to-pink-100 flex items-center justify-center px-4">
                <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0 pointer-events-none">
                <div className="absolute top-[-10%] left-[-10%] w-96 h-96 bg-purple-200 rounded-full mix-blend-multiply filter blur-3xl opacity-40 animate-blob"></div>
                <div className="absolute top-[-10%] right-[-10%] w-96 h-96 bg-yellow-200 rounded-full mix-blend-multiply filter blur-3xl opacity-40 animate-blob animation-delay-2000"></div>
                <div className="absolute bottom-[-20%] left-[20%] w-96 h-96 bg-pink-200 rounded-full mix-blend-multiply filter blur-3xl opacity-40 animate-blob animation-delay-4000"></div>
                <div className="absolute bottom-[10%] right-[-5%] w-72 h-72 bg-indigo-200 rounded-full mix-blend-multiply filter blur-3xl opacity-40 animate-blob animation-delay-2000"></div>
                
            </div>
                <div className="max-w-[1040px] w-full grid grid-cols-1 lg:grid-cols-5 gap-8 items-center h-full py-10">
                    
                    {/* Cột trái: Logo lớn & Slogan (Ẩn trên mobile) */}
                    <div className="hidden lg:flex lg:col-span-3 flex-col items-center text-white text-center">
                        <img src={ShopLogo} alt="Branding" className="w-80 h-80 object-contain drop-shadow-md mb-6" />
                        <p className="text-lg md:text-xl text-slate-600 font-medium max-w-md leading-relaxed">
                        Điểm đến mua sắm <span className="text-indigo-700 font-bold">tin cậy</span> & <br/>
                        Hệ thống quản lý <span className="text-purple-700 font-bold">chuyên nghiệp</span> hàng đầu.
                    </p>
                
                    </div>

                    {/* Cột phải: Form Đăng nhập (Card trắng) */}
                    <div className="lg:col-span-2 bg-white rounded-lg shadow-lg p-8 w-full relative">
                        
                        {/* Tab Header & QR Code */}
                        <div className="flex justify-between items-center mb-6">
                            <h2 className="text-xl font-medium text-yellow-800">
                                {isRegistering ? 'Đăng Ký' : 'Đăng Nhập'}
                            </h2>
                            
                          
                        </div>

                        {/* --- FORM --- */}
                        {isRegistering ? (
                            <form onSubmit={handleRegister} className="space-y-2">
                                <InputField type="text" value={regFullName} onChange={(e) => setRegFullName(e.target.value)} placeholder="Họ và Tên" />
                                <InputField type="text" value={regPhone} onChange={(e) => setRegPhone(e.target.value)} placeholder="Số điện thoại" />
                                <InputField type="password" value={regPassword} onChange={(e) => setRegPassword(e.target.value)} placeholder="Mật khẩu" showToggle={true} onToggle={() => setShowRegPassword(!showRegPassword)} isShow={showRegPassword} />
                                <InputField type="password" value={regConfirmPassword} onChange={(e) => setRegConfirmPassword(e.target.value)} placeholder="Xác nhận mật khẩu" showToggle={true} onToggle={() => setShowRegConfirmPassword(!showRegConfirmPassword)} isShow={showRegConfirmPassword} />

                                <button type="submit" disabled={isLoading} className="w-full bg-[#ee4d2d] text-white py-3 rounded-sm font-medium hover:bg-[#d73211] transition shadow-md uppercase text-sm tracking-wide mt-2">
                                    {isLoading ? 'ĐANG XỬ LÝ...' : 'ĐĂNG KÝ'}
                                </button>
                            </form>
                        ) : (
                            <form onSubmit={handleLogin} className="space-y-2">
                                <InputField type="text" value={username} onChange={(e) => setUsername(e.target.value)} placeholder="Số điện thoại / Tên đăng nhập" />
                                <InputField type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Mật khẩu" showToggle={true} onToggle={() => setShowPassword(!showPassword)} isShow={showPassword} />

                                <button type="submit" disabled={isLoading} className="w-full bg-[#c98a0cd5] text-white py-3 rounded-sm font-medium hover:bg-[#a3700a] transition shadow-md uppercase text-sm tracking-wide mt-4">
                                    {isLoading ? 'ĐANG ĐĂNG NHẬP...' : 'ĐĂNG NHẬP'}
                                </button>

                                <div className="flex justify-between text-xs text-blue-600 mt-2">
                                    <a href="#" className="hover:underline">Quên mật khẩu?</a>
                                    <a href="#" className="hover:underline">Đăng nhập với SMS</a>
                                </div>
                            </form>
                        )}

                        {/* Error Message */}
                        {error && <div className="mt-4 p-3 text-sm text-red-600 bg-red-50 border border-red-200 rounded-sm text-center">{error}</div>}

                        {/* Separator */}
                        <div className="flex items-center my-6">
                            <div className="flex-1 border-t border-gray-200"></div>
                            <span className="px-3 text-gray-400 text-xs uppercase">Hoặc</span>
                            <div className="flex-1 border-t border-gray-200"></div>
                        </div>

                        {/* Social Buttons */}
                        <div className="flex gap-2">
                            <button onClick={() => handleSocialLogin('Facebook')} className="flex-1 flex items-center justify-center gap-2 border border-gray-300 py-2 rounded-sm hover:bg-gray-50 transition">
                                <Facebook className="w-5 h-5 text-blue-600" /> <span className="text-sm text-gray-600">Facebook</span>
                            </button>
                            <button onClick={() => handleSocialLogin('Google')} className="flex-1 flex items-center justify-center gap-2 border border-gray-300 py-2 rounded-sm hover:bg-gray-50 transition">
                                <svg className="w-5 h-5" viewBox="0 0 24 24"><path d="M12.0003 20.45c-4.6667 0-8.45-3.7833-8.45-8.45 0-4.6667 3.7833-8.45 8.45-8.45 2.2833 0 4.35 0.8333 5.9667 2.35l-2.3833 2.3833c-0.9333-0.9-2.1667-1.45-3.5833-1.45-2.85 0-5.1667 2.3167-5.1667 5.1667s2.3167 5.1667 5.1667 5.1667c2.6167 0 4.4333-1.8833 4.5833-4.4833h-4.5833v-3.2667h7.9167c0.0833 0.5 0.1167 1.0333 0.1167 1.6 0 4.8833-3.5167 8.3833-8.3833 8.3833z" fill="#EA4335" /></svg>
                                <span className="text-sm text-gray-600">Google</span>
                            </button>
                        </div>

                        {/* Switch Mode Footer */}
                        <div className="mt-8 text-center text-sm text-gray-600">
                            {isRegistering ? (
                                <>Bạn đã có tài khoản? <button onClick={() => {setIsRegistering(false); setError('')}} className="text-[#ee4d2d] font-medium hover:underline">Đăng nhập</button></>
                            ) : (
                                <>Bạn mới biết đến AuraStore? <button onClick={() => {setIsRegistering(true); setError('')}} className="text-[#ee4d2d] font-medium hover:underline">Đăng ký</button></>
                            )}
                        </div>

                    </div>
                </div>
            </div>

            
            <Footer />
        </div>
    );
};