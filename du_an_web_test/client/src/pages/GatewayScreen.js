import React from 'react';
import { ShoppingBag, LogIn, ArrowRight, Star, Truck, ShieldCheck } from 'lucide-react'; 
import ShopLogo from '../assets/shop-logo-konen.png'; 
import GatewayHero from '../assets/gateway-hero.jpg'; 

export const GatewayScreen = ({ setPath }) => {
    return (
        <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 relative overflow-hidden font-sans selection:bg-pink-200 selection:text-pink-900">
            
            {/* =========================================
               BACKGROUND DECORATION (BLOBS)
               ========================================= */}
            <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0 pointer-events-none">
                <div className="absolute top-[-10%] left-[-10%] w-96 h-96 bg-purple-200 rounded-full mix-blend-multiply filter blur-3xl opacity-40 animate-blob"></div>
                <div className="absolute top-[-10%] right-[-10%] w-96 h-96 bg-yellow-200 rounded-full mix-blend-multiply filter blur-3xl opacity-40 animate-blob animation-delay-2000"></div>
                <div className="absolute bottom-[-20%] left-[20%] w-96 h-96 bg-pink-200 rounded-full mix-blend-multiply filter blur-3xl opacity-40 animate-blob animation-delay-4000"></div>
                <div className="absolute bottom-[10%] right-[-5%] w-72 h-72 bg-indigo-200 rounded-full mix-blend-multiply filter blur-3xl opacity-40 animate-blob animation-delay-2000"></div>
                
            </div>

            {/* =========================================
               MAIN CONTENT (Hero Section)
               ========================================= */}
            <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row items-center justify-between h-screen md:h-[calc(100vh-80px)] md:pb-0 pt-10 md:pt-0">

                {/* --- CỘT TRÁI: HÌNH ẢNH MINH HỌA (HERO) --- */}
                <div className="w-full md:w-1/2 flex justify-center md:justify-start mt-8 md:mt-0 relative order-2 md:order-1">
                     {/* Hiệu ứng nền sau ảnh */}
                     <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[120%] h-[120%] bg-white/40 rounded-full blur-3xl -z-10 animate-pulse"></div>
                     
                    <img
                        src={GatewayHero}
                        alt="Shopping Hero"
                        className="w-full max-w-lg object-contain drop-shadow-2xl mix-blend-multiply hover:scale-105 transition-transform duration-700"
                    />
                </div>

                {/* --- CỘT PHẢI: TEXT & LOGO --- */}
                <div className="w-full md:w-1/2 flex flex-col justify-center items-center text-center space-y-6 order-1 md:order-2">
                    
                    {/* 1. Greeting Text - Đã làm to hơn và dùng màu Gradient hòa hợp */}
                    <h2 className="mt-16 animate-fade-in-down text-2xl md:text-3xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-indigo-600 via-purple-600 to-pink-600 uppercase tracking-widest drop-shadow-sm">
                        CHÀO MỪNG ĐẾN VỚI
                    </h2>

                    {/* 2. LOGO LỚN - Đã tăng kích thước lớn hơn */}
                    <div className="relative group py-4">
                        <div className="absolute -inset-6 bg-gradient-to-r from-purple-200 to-pink-200 rounded-full blur-2xl opacity-40 group-hover:opacity-60 transition duration-700"></div>
                        <img 
                            src={ShopLogo} 
                            alt="AuraStore Logo" 
                            // Tăng kích thước từ w-48 lên w-80
                            className="relative w-56 md:w-80 h-auto object-contain drop-shadow-xl transform group-hover:scale-105 transition-transform duration-500 ease-out" 
                        />
                    </div>

                    
                    {/* 4. Description */}
                    <p className="text-lg md:text-xl text-slate-600 font-medium max-w-md leading-relaxed">
                        Điểm đến mua sắm <span className="text-indigo-700 font-bold">tin cậy</span> & <br/>
                        Hệ thống quản lý <span className="text-purple-700 font-bold">chuyên nghiệp</span> hàng đầu.
                    </p>

                    {/* 5. Buttons */}
                    <div className="flex flex-col sm:flex-row gap-4 w-full sm:w-auto pt-2">
                        {/* Nút Khám Phá */}
                        <button
                            onClick={() => setPath('/shop')}
                            className="group px-8 py-3.5 bg-gradient-to-r from-[#ee4d2d] to-[#ff6b4a] text-white font-bold rounded-full shadow-lg shadow-orange-200/60 hover:shadow-orange-300 hover:-translate-y-1 transition-all duration-300 flex items-center justify-center min-w-[180px]"
                        >
                            <ShoppingBag className="w-5 h-5 mr-2 group-hover:rotate-12 transition-transform" />
                            <span className="tracking-wide text-sm uppercase">Khám phá ngay</span>
                        </button>
                        
                        {/* Nút Đăng nhập */}
                        <button
                            onClick={() => setPath('/login')}
                            className="group px-8 py-3.5 bg-white text-gray-700 font-bold border border-gray-100 rounded-full shadow-md hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex items-center justify-center hover:text-indigo-600 min-w-[180px]"
                        >
                            <LogIn className="w-5 h-5 mr-2 group-hover:text-indigo-600 transition-colors" />
                            <span className="tracking-wide text-sm uppercase">Đăng nhập</span>
                            <ArrowRight className="w-4 h-4 ml-2 opacity-0 -translate-x-2 group-hover:opacity-100 group-hover:translate-x-0 transition-all text-indigo-600" />
                        </button>
                    </div>
                </div>
            </div>

            {/* =========================================
               FOOTER ICONS (LÙI XUỐNG SÁT MÉP)
               ========================================= */}
            <div className="absolute bottom-4 left-0 w-full z-20 flex justify-center items-center gap-3 md:gap-8 text-gray-600 text-xs md:text-sm animate-fade-in-up px-4">
                <div className="flex items-center gap-2 px-4 py-2 bg-white/70 backdrop-blur-md rounded-full shadow-sm border border-white/60 cursor-default hover:scale-105 transition-transform">
                        <ShieldCheck className="w-4 h-4 md:w-5 md:h-5 text-blue-600" /> 
                        <span className="font-semibold">Uy tín 100%</span>
                </div>
                <div className="flex items-center gap-2 px-4 py-2 bg-white/70 backdrop-blur-md rounded-full shadow-sm border border-white/60 cursor-default hover:scale-105 transition-transform">
                        <Star className="w-4 h-4 md:w-5 md:h-5 text-yellow-500" /> 
                        <span className="font-semibold">Chất lượng cao</span>
                </div>
                <div className="flex items-center gap-2 px-4 py-2 bg-white/70 backdrop-blur-md rounded-full shadow-sm border border-white/60 cursor-default hover:scale-105 transition-transform">
                        <Truck className="w-4 h-4 md:w-5 md:h-5 text-green-600" /> 
                        <span className="font-semibold">Giao siêu tốc</span>
                </div>
            </div>

        </div>
    );
};