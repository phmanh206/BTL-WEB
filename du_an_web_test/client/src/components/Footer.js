import React from 'react';
import { Facebook, Phone, Mail, MapPin, CheckCircle } from 'lucide-react'; 
import ShopLogo from '../assets/shop-logo-konen.png'; 

const Footer = () => {
  return (
    <footer className="bg-[#403a3a] text-white pt-12 pb-8 text-sm font-sans border-t-4 border-[#070008]">
      <div className="max-w-7xl mx-auto px-4">
        
        {/* --- Top Section --- */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-10 border-b border-gray-600 pb-10">
            <div className="mb-5">
                    {/* Logo GO! giả lập bằng CSS */}
                        <img src={ShopLogo} alt="Branding" className="w-40 h-40 object-contain drop-shadow-md mb-6" />
                </div>
            {/* Cột 1: Logo & Bản quyền */}
            <div>
                <h3 className="font-bold text-base mb-5 uppercase text-[#ee4d2d] tracking-wide">Về Aura</h3>
                
                <p className="text-gray-400 text-xs leading-relaxed mb-4">
                    Bản quyền © 2025 AuraStore<br/>
                    Mọi quyền được bảo lưu.
                </p>
                <ul className="space-y-2 text-gray-300 text-xs">
                    <li><a href="#" className="hover:text-[#ee4d2d] transition-colors hover:underline">Chính sách bảo mật</a></li>
                    <li><a href="#" className="hover:text-[#ee4d2d] transition-colors hover:underline">Chính sách đổi, trả hàng hóa</a></li>
                    <li><a href="#" className="hover:text-[#ee4d2d] transition-colors hover:underline">Câu hỏi thường gặp</a></li>
                </ul>
            </div>

            {/* Cột 2: Cam Kết */}
            <div>
                <h3 className="font-bold text-base mb-5 uppercase text-[#ee4d2d] tracking-wide">CAM KẾT</h3>
                <ul className="space-y-4 text-gray-300 text-xs">
                    <li className="flex items-start gap-2">
                        <CheckCircle className="w-4 h-4 text-[#ee4d2d] shrink-0" />
                        <span>Luôn có sản phẩm trong catalogue</span>
                    </li>
                    <li className="flex items-start gap-2">
                        <CheckCircle className="w-4 h-4 text-[#ee4d2d] shrink-0" />
                        <span>Đổi trả hàng trong 7 ngày</span>
                    </li>
                    <li className="flex items-start gap-2">
                        <CheckCircle className="w-4 h-4 text-[#ee4d2d] shrink-0" />
                        <span>Nói không với hàng quá hạn</span>
                    </li>
                    <li className="flex items-start gap-2">
                        <CheckCircle className="w-4 h-4 text-[#ee4d2d] shrink-0" />
                        <span>Hoàn tiền nếu sai sót</span>
                    </li>
                </ul>
            </div>

            {/* Cột 3: Đừng Bỏ Lỡ */}
            <div>
                <h3 className="font-bold text-base mb-5 uppercase text-[#ee4d2d] tracking-wide">ĐỪNG BỎ LỠ</h3>
                <ul className="space-y-3 text-gray-300 text-xs font-medium">
                    <li><a href="#" className="hover:text-white hover:underline flex items-center gap-2">🔥 Chương trình khuyến mãi</a></li>
                    <li><a href="#" className="hover:text-white hover:underline flex items-center gap-2">👍 Theo dõi trên Facebook</a></li>
                    <li><a href="#" className="hover:text-white hover:underline flex items-center gap-2">📧 Đăng ký nhận tin</a></li>
                </ul>
            </div>

           
        </div>

        {/* --- Bottom Section: Thông tin công ty --- */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 text-xs text-gray-400">
            <div>
                <h4 className="font-bold text-white mb-3 uppercase tracking-wider">CÔNG TY TNHH DỊCH VỤ EB</h4>
                <p className="mb-1.5 flex items-start gap-2">
                    <MapPin className="w-3.5 h-3.5 mt-0.5 shrink-0 text-gray-500" />
                    <span>Số 163, Phan Đăng Lưu, Phường 01, Quận Phú Nhuận, Thành phố Hồ Chí Minh, Việt Nam</span>
                </p>
                <p className="mb-1 flex items-center gap-4 ml-5">
                    <span>Tel: (84-08) 3995 8368</span>
                    <span>Fax: (84-08) 3995 8423</span>
                </p>
            </div>
            
            <div className="lg:text-right">
                <h4 className="font-bold text-white mb-3 uppercase tracking-wider">LIÊN HỆ</h4>
                <div className="inline-block text-left">
                    <p className="mb-1.5 flex items-center gap-2 justify-end">
                        <span className="font-semibold text-gray-300">Phòng chăm sóc khách hàng:</span> 
                        <span className="text-[#ee4d2d] font-bold text-sm">1900 1880</span>
                        <Phone className="w-3.5 h-3.5 text-[#ee4d2d]" />
                    </p>
                    <p className="mb-1 flex items-center gap-2 justify-end">
                        <span className="font-semibold text-gray-300">Email:</span> 
                        <a href="mailto:crv.dvkh@vn.centralretail.com" className="hover:text-white transition-colors">cskh@aurastore.com</a>
                        <Mail className="w-3.5 h-3.5 text-gray-500" />
                    </p>
                </div>
            </div>
        </div>
        
        {/* --- Floating Action Buttons (Zalo/Phone) --- */}
        <div className="fixed bottom-6 right-6 flex flex-col gap-3 z-50">
            <button className="w-12 h-12 bg-blue-500 rounded-full shadow-lg flex items-center justify-center text-white hover:scale-110 transition-transform animate-bounce">
                <span className="font-bold text-[10px]">Zalo</span>
            </button>
            <button className="w-12 h-12 bg-[#ee4d2d] rounded-full shadow-lg flex items-center justify-center text-white hover:scale-110 transition-transform animate-pulse">
                <Phone className="w-6 h-6" />
            </button>
        </div>

      </div>
    </footer>
  );
};

export default Footer;