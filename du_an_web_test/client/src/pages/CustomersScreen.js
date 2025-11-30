// src/pages/CustomersScreen.js
import React, { useState, useMemo, useEffect } from 'react';
import { Search, Plus, Edit, Eye } from 'lucide-react';
import { getCustomers } from '../services/api';
import { ROLES } from '../utils/constants';
import { normalizeSearchableValue } from '../utils/helpers';

export const CustomersScreen = ({ userRoleName }) => {
    const [customers, setCustomers] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');

    // Modal xem lịch sử
    const [selectedCustomer, setSelectedCustomer] = useState(null);
    const [orderHistory, setOrderHistory] = useState([]);
    const [showModal, setShowModal] = useState(false);
    const [loadingDetail, setLoadingDetail] = useState(false);

    // Modal sửa thông tin
    const [editCustomer, setEditCustomer] = useState(null);
    const [showEditModal, setShowEditModal] = useState(false);
    const [isUpdating, setIsUpdating] = useState(false);

    const canEdit = [
        ROLES.OWNER.name,
        ROLES.SALES.name,
        ROLES.ONLINE_SALES.name
    ].includes(userRoleName);

    // ---- LẤY DANH SÁCH KHÁCH HÀNG ----
    useEffect(() => {
        const fetchCustomers = async () => {
            setIsLoading(true);
            setError(null);
            try {
                const data = await getCustomers();
                setCustomers(data);
            } catch (err) {
                setError(err.message || 'Không thể tải dữ liệu khách hàng từ máy chủ.');
            } finally {
                setIsLoading(false);
            }
        };
        fetchCustomers();
    }, []);

    // ---- API: Xem lịch sử mua hàng ----
    const viewCustomerDetail = async (customerId) => {
        setLoadingDetail(true);
        try {
            const res = await fetch(`http://localhost:5001/api/customers/${customerId}`);
            const data = await res.json();

            setSelectedCustomer(data.customer);
            setOrderHistory(data.orders || []);
            setShowModal(true);
        } catch (error) {
            alert("Không thể tải thông tin khách hàng.");
        } finally {
            setLoadingDetail(false);
        }
    };

    // ---- MỞ MODAL SỬA ----
    const openEditModal = (customer) => {
        setEditCustomer({ ...customer });
        setShowEditModal(true);
    };

    // ---- API: Sửa thông tin khách hàng ----
    const updateCustomerInfo = async () => {
        if (!editCustomer) return;

        setIsUpdating(true);

        try {
            const res = await fetch(`http://localhost:5001/api/customers/${editCustomer.id}`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    fullName: editCustomer.fullName,
                    email: editCustomer.email,
                    phone: editCustomer.phone,
                    address: editCustomer.address,
                    dob: editCustomer.dob
                })
            });

            const data = await res.json();
            if (!res.ok) {
                alert(data.message || "Lỗi cập nhật khách hàng");
                return;
            }

            // Cập nhật danh sách ngay lập tức
            setCustomers(prev =>
                prev.map(c => (c.id === editCustomer.id ? editCustomer : c))
            );

            alert("Cập nhật thành công!");
            setShowEditModal(false);

        } catch (error) {
            alert("Không thể cập nhật khách hàng.");
            console.error(error);
        } finally {
            setIsUpdating(false);
        }
    };

    // ---- TÌM KIẾM ----
    const filteredCustomers = useMemo(() => {
        if (!searchTerm) return customers;
        const lowerCaseSearch = normalizeSearchableValue(searchTerm);

        return customers.filter(c => {
            return Object.values(c).some(value =>
                normalizeSearchableValue(value).includes(lowerCaseSearch)
            );
        });
    }, [customers, searchTerm]);

    // ---- UI LOADING + ERROR ----
    if (isLoading) {
        return (
            <p className="p-6 text-center text-xl text-blue-600 font-semibold">
                Đang tải danh sách khách hàng...
            </p>
        );
    }

    if (error) {
        return (
            <p className="p-6 text-center text-xl text-red-600 font-semibold">
                Lỗi: {error}
            </p>
        );
    }

    return (
        <div className="space-y-6 p-4 md:p-6">
            <h1 className="text-3xl font-bold text-gray-900">Quản lý Khách hàng (Customers)</h1>
            <p className="text-gray-500 text-sm">
                Quyền: Owner, Sales, Online Sales (chỉnh sửa); Warehouse, Shipper (chỉ xem)
            </p>

            <div className="bg-white p-4 md:p-6 rounded-xl shadow-md">
                <div className="flex flex-col sm:flex-row justify-between items-center mb-4 gap-3">

                    {/* Ô TÌM KIẾM */}
                    <div className="relative flex-grow w-full sm:w-64">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Tìm tên, SĐT, email, địa chỉ..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                        />
                    </div>

                    {canEdit && (
                        <button
                            onClick={() => alert("[API CALL] Thêm khách hàng")}
                            className="flex items-center bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-lg shadow-md"
                        >
                            <Plus className="w-5 h-5 mr-2" /> Thêm khách hàng
                        </button>
                    )}
                </div>

                {/* BẢNG KHÁCH HÀNG */}
                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Mã KH</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Họ tên</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Năm sinh</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Địa chỉ</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">SĐT</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Hành động</th>
                            </tr>
                        </thead>

                        <tbody className="bg-white divide-y divide-gray-200">
                            {filteredCustomers.map((c) => (
                                <tr key={c.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4 text-sm font-medium text-blue-600">{c.id}</td>
                                    <td className="px-6 py-4 text-sm">{c.fullName}</td>
                                    <td className="px-6 py-4 text-sm">{c.dob}</td>
                                    <td className="px-6 py-4 text-sm max-w-xs truncate">{c.address}</td>
                                    <td className="px-6 py-4 text-sm">{c.phone}</td>
                                    <td className="px-6 py-4 text-right text-sm flex justify-end gap-2">

                                        {/* NÚT XEM LỊCH SỬ */}
                                        <button
                                            title="Xem lịch sử"
                                            onClick={() => viewCustomerDetail(c.id)}
                                            className="text-blue-600 hover:text-blue-900 p-2 rounded-full hover:bg-blue-100"
                                        >
                                            <Eye className="w-5 h-5" />
                                        </button>

                                        {/* NÚT SỬA */}
                                        {canEdit && (
                                            <button
                                                title="Cập nhật"
                                                onClick={() => openEditModal(c)}
                                                className="text-indigo-600 hover:text-indigo-900 p-2 rounded-full hover:bg-indigo-100"
                                            >
                                                <Edit className="w-5 h-5" />
                                            </button>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>

                    {filteredCustomers.length === 0 && (
                        <p className="text-center py-8 text-gray-500">Không tìm thấy khách hàng nào.</p>
                    )}
                </div>
            </div>

            {/* -------------------------------------- */}
            {/*  MODAL: XEM LỊCH SỬ MUA HÀNG */}
            {/* -------------------------------------- */}
            {showModal && (
                <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
                    <div className="bg-white w-full max-w-2xl p-6 rounded-xl shadow-lg relative">

                        <button
                            onClick={() => setShowModal(false)}
                            className="absolute right-4 top-4 text-gray-400 hover:text-red-600 text-xl"
                        >×</button>

                        <h2 className="text-2xl font-bold mb-4">Chi tiết khách hàng</h2>

                        {loadingDetail ? (
                            <p>Đang tải...</p>
                        ) : (
                            <>
                                <div className="mb-4">
                                    <p><b>Mã KH:</b> {selectedCustomer?.id}</p>
                                    <p><b>Họ tên:</b> {selectedCustomer?.fullName}</p>
                                    <p><b>Email:</b> {selectedCustomer?.email}</p>
                                    <p><b>SĐT:</b> {selectedCustomer?.phone}</p>
                                    <p><b>Địa chỉ:</b> {selectedCustomer?.address}</p>
                                    <p><b>Năm sinh:</b> {selectedCustomer?.dob}</p>
                                </div>

                                <h3 className="text-xl font-semibold mb-2">Lịch sử mua hàng</h3>

                                {orderHistory.length === 0 ? (
                                    <p className="text-gray-500">Khách hàng chưa có đơn hàng nào.</p>
                                ) : (
                                    <table className="w-full border">
                                        <thead className="bg-gray-100">
                                            <tr>
                                                <th className="border p-2">Mã đơn</th>
                                                <th className="border p-2">Ngày mua</th>
                                                <th className="border p-2">Tổng tiền</th>
                                                <th className="border p-2">Trạng thái</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {orderHistory.map(order => (
                                                <tr key={order.id}>
                                                    <td className="border p-2">{order.id}</td>
                                                    <td className="border p-2">{order.orderDate}</td>
                                                    <td className="border p-2">{order.totalAmount}</td>
                                                    <td className="border p-2">{order.status}</td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                )}
                            </>
                        )}
                    </div>
                </div>
            )}

            {/* -------------------------------------- */}
            {/*  MODAL: SỬA KHÁCH HÀNG */}
            {/* -------------------------------------- */}
            {showEditModal && (
                <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
                    <div className="bg-white w-full max-w-lg p-6 rounded-xl shadow-lg relative">

                        <button
                            onClick={() => setShowEditModal(false)}
                            className="absolute right-4 top-4 text-gray-400 hover:text-red-600 text-xl"
                        >×</button>

                        <h2 className="text-2xl font-bold mb-4">Cập nhật khách hàng</h2>

                        <div className="space-y-4">

                            <div>
                                <label className="font-medium">Họ tên</label>
                                <input
                                    type="text"
                                    value={editCustomer.fullName}
                                    onChange={(e) => setEditCustomer({ ...editCustomer, fullName: e.target.value })}
                                    className="w-full border rounded-lg px-3 py-2 mt-1"
                                />
                            </div>

                            <div>
                                <label className="font-medium">Email</label>
                                <input
                                    type="email"
                                    value={editCustomer.email}
                                    onChange={(e) => setEditCustomer({ ...editCustomer, email: e.target.value })}
                                    className="w-full border rounded-lg px-3 py-2 mt-1"
                                />
                            </div>

                            <div>
                                <label className="font-medium">SĐT</label>
                                <input
                                    type="text"
                                    value={editCustomer.phone}
                                    onChange={(e) => setEditCustomer({ ...editCustomer, phone: e.target.value })}
                                    className="w-full border rounded-lg px-3 py-2 mt-1"
                                />
                            </div>

                            <div>
                                <label className="font-medium">Địa chỉ</label>
                                <input
                                    type="text"
                                    value={editCustomer.address}
                                    onChange={(e) => setEditCustomer({ ...editCustomer, address: e.target.value })}
                                    className="w-full border rounded-lg px-3 py-2 mt-1"
                                />
                            </div>

                            <div>
                                <label className="font-medium">Năm sinh</label>
                                <input
                                    type="date"
                                    value={editCustomer.dob}
                                    onChange={(e) => setEditCustomer({ ...editCustomer, dob: e.target.value })}
                                    className="w-full border rounded-lg px-3 py-2 mt-1"
                                />
                            </div>

                            <button
                                onClick={updateCustomerInfo}
                                disabled={isUpdating}
                                className={`w-full py-2 rounded-lg text-white font-semibold mt-4 ${
                                    isUpdating ? "bg-blue-400" : "bg-blue-600 hover:bg-blue-700"
                                }`}
                            >
                                {isUpdating ? "Đang cập nhật..." : "Cập nhật"}
                            </button>
                        </div>
                    </div>
                </div>
            )}

        </div>
    );
};
