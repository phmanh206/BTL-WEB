// C:\Users\Admin\Downloads\DUANWEB(1)\client\src\pages\ProductsScreen.js

import React, { useState, useMemo, useEffect } from 'react';
import { Package, Search, Plus, Edit, Trash2 } from 'lucide-react';
// Import API thật để lấy dữ liệu từ Server
import { getProducts } from '../services/api'; 
// Import các hằng số và hàm tiện ích
import { ROLES } from '../utils/constants';
import { formatCurrency, normalizeSearchableValue } from '../utils/helpers';

export const ProductsScreen = ({ userRoleName }) => {
    const [products, setProducts] = useState([]); 
    const [isLoading, setIsLoading] = useState(true); 
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState(''); 
    
    // Khả năng chỉnh sửa/xóa (Permissions)
    const canEdit = [ROLES.OWNER.name, ROLES.WAREHOUSE.name].includes(userRoleName);
    const canDelete = userRoleName === ROLES.OWNER.name;
    
    // --- LẤY DỮ LIỆU TỪ API ---
    useEffect(() => {
        const fetchProducts = async () => {
            setIsLoading(true);
            setError(null);
            try {
                // Gọi API /api/products để lấy danh sách sản phẩm
                const data = await getProducts(); 
                // Dữ liệu trả về: [{ id: 'SP1', name: '...', price: ..., stockQuantity: ...}, ...]
                setProducts(data);
            } catch (err) {
                // Hiển thị lỗi từ Server (err.message)
                setError(err.message || 'Không thể tải dữ liệu sản phẩm từ máy chủ.');
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        };
        fetchProducts();
    }, []); // Chạy một lần khi component mount

    // --- LOGIC TÌM KIẾM TOÀN DIỆN TRÊN CLIENT ---
    const filteredProducts = useMemo(() => {
        if (!searchTerm) return products;
        const lowerCaseSearch = normalizeSearchableValue(searchTerm);

        return products.filter(p => {
            // Kiểm tra tất cả các trường
            return Object.values(p).some(value => {
                return normalizeSearchableValue(value).includes(lowerCaseSearch);
            });
        });
    }, [products, searchTerm]);

    // --- RENDER HỌC (Loading, Error) ---
    if (isLoading) {
        return <p className="p-6 text-center text-xl text-blue-600 font-semibold">Đang tải dữ liệu sản phẩm từ Server...</p>;
    }
    
    if (error) {
        return <p className="p-6 text-center text-xl text-red-600 font-semibold">Lỗi: {error}</p>;
    }

    return (
        <div className="space-y-6 p-4 md:p-6">
            <h1 className="text-3xl font-bold text-gray-900">Quản lý Sản phẩm (Products)</h1>
            <p className="text-gray-500">Quyền: Owner, Warehouse (chỉnh sửa); Sales, Online Sales, Shipper (chỉ xem)</p>

            <div className="bg-white p-4 rounded-xl shadow-lg">
                <div className="flex flex-col sm:flex-row justify-between items-center mb-4 gap-3">
                    {/* Ô TÌM KIẾM */}
                    <div className="relative flex-grow w-full sm:w-auto">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Tìm kiếm theo mã, tên, giá, tồn kho..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500 transition duration-150"
                        />
                    </div>
                    {canEdit && (
                        <button onClick={() => alert(`[API CALL] Mở form thêm SP mới`)} className="flex items-center bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition duration-200 w-full sm:w-auto">
                            <Plus className="w-5 h-5 mr-1" /> Thêm sản phẩm
                        </button>
                    )}
                </div>

                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mã</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tên sản phẩm</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Giá bán</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Giá vốn</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tồn kho</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trạng thái</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Hành động</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {filteredProducts.map((p) => (
                                <tr key={p.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-blue-600">{p.id}</td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{p.name}</td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-semibold">{formatCurrency(p.price)}</td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{formatCurrency(p.costPrice)}</td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${p.stockQuantity > 100 ? 'bg-green-100 text-green-800' : p.stockQuantity > 10 ? 'bg-yellow-100 text-yellow-800' : 'bg-red-100 text-red-800'}`}>
                                            {p.stockQuantity}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                        {p.isActive ? 'Đang bán' : 'Ngừng bán'}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        {canEdit && (
                                            <button title="Sửa" onClick={() => alert(`[API CALL] Mở form sửa SP #${p.id}`)} className="text-indigo-600 hover:text-indigo-900 mr-3 p-1 rounded-full hover:bg-indigo-100 transition"><Edit className="w-5 h-5" /></button>
                                        )}
                                        {canDelete && (
                                            <button title="Xóa" onClick={() => alert(`[API CALL] Xác nhận xóa/ẩn SP #${p.id}`)} className="text-red-600 hover:text-red-900 p-1 rounded-full hover:bg-red-100 transition"><Trash2 className="w-5 h-5" /></button>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                    {filteredProducts.length === 0 && <p className="text-center py-8 text-gray-500">Không tìm thấy sản phẩm nào.</p>}
                </div>
            </div>
        </div>
    );
};