import React, { useState, useEffect, useMemo } from 'react';
import { ShoppingCart, Search, Filter, LogIn, LogOut, User, Star, ArrowLeft, History, Key } from 'lucide-react'; // Thêm icon Key
import { getProducts, getCategories } from '../services/api';
import { formatCurrency, normalizeSearchableValue } from '../utils/helpers';

// Component ShopScreen nhận props để xử lý giao diện
export const ShopScreen = ({ setPath, isLoggedIn, currentUser, onLogout }) => {
    const [products, setProducts] = useState([]);
    const [categories, setCategories] = useState([]);
    const [selectedCategory, setSelectedCategory] = useState('All');
    const [searchTerm, setSearchTerm] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [cartCount, setCartCount] = useState(0);

    // Tải dữ liệu (Giữ nguyên logic cũ)
    useEffect(() => {
        const fetchData = async () => {
            try {
                const [prodData, catData] = await Promise.all([
                    getProducts(),
                    getCategories().catch(() => [])
                ]);
                setProducts(prodData.filter(p => p.isActive));
                setCategories(catData);
            } catch (error) {
                console.error("Lỗi tải dữ liệu shop:", error);
            } finally {
                setIsLoading(false);
            }
        };
        fetchData();
    }, []);

    const filteredProducts = useMemo(() => {
        return products.filter(p => {
            const matchCat = selectedCategory === 'All' || p.category_id === parseInt(selectedCategory);
            const matchSearch = normalizeSearchableValue(p.name).includes(normalizeSearchableValue(searchTerm));
            return matchCat && matchSearch;
        });
    }, [products, selectedCategory, searchTerm]);

    const handleAddToCart = () => {
        setCartCount(prev => prev + 1);
        alert("Đã thêm vào giỏ hàng!");
    };

    // --- RENDER ---
    return (
        <div className="min-h-screen bg-gray-50 font-sans">
            
            {/* HEADER LINH HOẠT */}
            <header className="bg-white shadow-md sticky top-0 z-50">
                <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
                    
                    {/* Logo & Back */}
                    <div className="flex items-center cursor-pointer" onClick={() => setPath(isLoggedIn ? '/shop' : '/')}>
                        {/* Nếu chưa đăng nhập thì hiện nút Back về Gateway, nếu đã đăng nhập thì click logo reload trang shop */}
                        {!isLoggedIn && <ArrowLeft className="w-6 h-6 text-gray-500 mr-2" />}
                        <span className="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-indigo-600 to-purple-600">
                            AuraStore
                        </span>
                    </div>

                    {/* Search Bar (Desktop) */}
                    <div className="hidden md:block flex-1 max-w-xl mx-8">
                        <div className="relative">
                            <input 
                                type="text" 
                                placeholder="Tìm kiếm sản phẩm..." 
                                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-full focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                            />
                            <Search className="w-5 h-5 text-gray-400 absolute left-3 top-2.5" />
                        </div>
                    </div>

                    {/* ACTIONS KHI ĐÃ / CHƯA ĐĂNG NHẬP */}
                    <div className="flex items-center space-x-4">
                        
                        {/* Giỏ hàng (Luôn hiện) */}
                        <div className="relative cursor-pointer p-2 hover:bg-gray-100 rounded-full">
                            <ShoppingCart className="w-6 h-6 text-gray-700" />
                            {cartCount > 0 && (
                                <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold px-1.5 py-0.5 rounded-full">
                                    {cartCount}
                                </span>
                            )}
                        </div>

                        {isLoggedIn ? (
                            // --- GIAO DIỆN ĐÃ ĐĂNG NHẬP (KHÁCH HÀNG) ---
                            <>
                                {/* Nút Lịch sử mua hàng */}
                                <button 
                                    onClick={() => alert("Chức năng xem đơn hàng cũ đang phát triển!")} // Hoặc setPath('/my-orders')
                                    className="hidden sm:flex items-center text-gray-600 hover:text-indigo-600 font-medium transition"
                                    title="Lịch sử mua hàng"
                                >
                                    <History className="w-5 h-5 mr-1" />
                                    <span className="hidden lg:inline">Đơn hàng</span>
                                </button>

                                {/* Thông tin User & Logout */}
                                <div className="flex items-center space-x-2 pl-3 border-l border-gray-200">
                                    <div className="hidden sm:flex flex-col items-end mr-2">
                                        <span className="text-sm font-bold text-gray-800">Xin chào, {currentUser?.fullName}</span>
                                        <span className="text-xs text-green-600 font-medium">Thành viên</span>
                                    </div>
                                    
                                    {/* Icon User */}
                                    <div className="h-9 w-9 bg-indigo-100 rounded-full flex items-center justify-center text-indigo-600 shadow-sm">
                                        <User className="w-5 h-5" />
                                    </div>

                                    {/* Nút Đổi Mật Khẩu (MỚI) */}
                                    <button 
                                        onClick={() => setPath('/change-password')}
                                        title="Đổi mật khẩu"
                                        className="p-2 text-gray-400 hover:text-orange-600 hover:bg-orange-50 rounded-full transition"
                                    >
                                        <Key className="w-5 h-5" />
                                    </button>

                                    {/* Nút Đăng xuất */}
                                    <button 
                                        onClick={onLogout}
                                        title="Đăng xuất"
                                        className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-full transition"
                                    >
                                        <LogOut className="w-5 h-5" />
                                    </button>
                                </div>
                            </>
                        ) : (
                            // --- GIAO DIỆN CHƯA ĐĂNG NHẬP (KHÁCH VÃNG LAI) ---
                            <button 
                                onClick={() => setPath('/login')}
                                className="flex items-center px-5 py-2 bg-indigo-600 text-white font-medium rounded-full hover:bg-indigo-700 transition shadow-sm hover:shadow-md"
                            >
                                <LogIn className="w-4 h-4 mr-2" /> 
                                Đăng nhập/ Đăng ký
                            </button>
                        )}
                    </div>
                </div>
            </header>

            {/* --- BODY (Giữ nguyên phần hiển thị sản phẩm) --- */}
            <div className="max-w-7xl mx-auto px-4 py-6 flex flex-col md:flex-row gap-6">
                
                {/* SIDEBAR DANH MỤC */}
                <aside className="w-full md:w-64 flex-shrink-0">
                    <div className="bg-white p-4 rounded-xl shadow-sm sticky top-20">
                        <h3 className="font-bold text-gray-800 mb-3 flex items-center">
                            <Filter className="w-5 h-5 mr-2" /> Danh mục
                        </h3>
                        <ul className="space-y-1 max-h-[70vh] overflow-y-auto custom-scrollbar">
                            <li>
                                <button onClick={() => setSelectedCategory('All')} className={`w-full text-left px-3 py-2 rounded-md transition ${selectedCategory === 'All' ? 'bg-indigo-50 text-indigo-700 font-semibold' : 'text-gray-600 hover:bg-gray-50'}`}>
                                    Tất cả sản phẩm
                                </button>
                            </li>
                            {categories.map(cat => (
                                <li key={cat.category_id}>
                                    <button onClick={() => setSelectedCategory(cat.category_id)} className={`w-full text-left px-3 py-2 rounded-md transition ${selectedCategory === cat.category_id ? 'bg-indigo-50 text-indigo-700 font-semibold' : 'text-gray-600 hover:bg-gray-50'}`}>
                                            {cat.category_name}
                                    </button>
                                </li>
                            ))}
                        </ul>
                    </div>
                </aside>

                {/* GRID SẢN PHẨM */}
                <main className="flex-1">
                    <h2 className="text-xl font-bold text-gray-800 mb-4">
                        {selectedCategory === 'All' ? 'Sản phẩm nổi bật' : categories.find(c => c.category_id === selectedCategory)?.category_name}
                    </h2>

                    {isLoading ? (
                        <div className="text-center py-20 text-gray-500">Đang tải sản phẩm...</div>
                    ) : filteredProducts.length === 0 ? (
                        <div className="text-center py-20 bg-white rounded-xl shadow-sm">
                            <p className="text-gray-500">Không tìm thấy sản phẩm nào.</p>
                        </div>
                    ) : (
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                            {filteredProducts.map(product => (
                                <div key={product.id} className="bg-white rounded-xl border border-gray-100 shadow-sm hover:shadow-lg transition-shadow duration-300 overflow-hidden flex flex-col group">
                                    <div className="h-48 bg-gray-100 relative overflow-hidden">
                                        <img src={`https://placehold.co/400x300/eef2ff/4f46e5?text=${encodeURIComponent(product.name.substring(0, 20))}`} alt={product.name} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                                        {/* Chỉ hiện nút Mua nhanh */}
                                    </div>
                                    <div className="p-4 flex-1 flex flex-col">
                                        <div className="text-xs text-indigo-500 font-semibold mb-1 uppercase tracking-wide">{product.categoryName || 'Sản phẩm'}</div>
                                        <h3 className="text-gray-900 font-medium text-base line-clamp-2 mb-2 flex-grow" title={product.name}>{product.name}</h3>
                                        <div className="flex items-center mb-3">
                                                <span className="text-xs text-yellow-500 flex"><Star className="w-3 h-3 fill-current"/><Star className="w-3 h-3 fill-current"/><Star className="w-3 h-3 fill-current"/><Star className="w-3 h-3 fill-current"/><Star className="w-3 h-3 fill-current"/></span> <span className="text-xs text-gray-400 ml-1">(5.0)</span>
                                        </div>
                                        <div className="mt-auto flex items-center justify-between">
                                            <span className="text-lg font-bold text-red-600">{formatCurrency(product.price)}</span>
                                            <button onClick={handleAddToCart} className="p-2 bg-indigo-50 text-indigo-600 rounded-full hover:bg-indigo-600 hover:text-white transition-colors">
                                                <ShoppingCart className="w-5 h-5" />
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </main>
            </div>
        </div>
    );
};