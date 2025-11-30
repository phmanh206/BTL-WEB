// /src/pages/OrdersScreen.js
import React, { useEffect, useState } from "react";
import { Plus, Eye } from "lucide-react";

export const OrdersScreen = ({ setPath, currentUserId, userRoleName }) => {
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);

    const fetchOrders = async () => {
        try {
            const res = await fetch("http://localhost:5001/api/orders");
            const data = await res.json();
            setOrders(data);
        } catch (err) {
            console.error("Error loading orders:", err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchOrders();
    }, []);

    if (loading)
        return (
            <p className="p-6 text-center text-xl">Đang tải đơn hàng...</p>
        );

    return (
        <div className="space-y-6 p-4 md:p-6">

            {/* HEADER */}
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Quản lý Đơn hàng</h1>

                <button
                    onClick={() => setPath("/orders/create")}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg shadow hover:bg-blue-700 flex items-center gap-2"
                >
                    <Plus size={18} />
                    Tạo đơn hàng
                </button>
            </div>

            {/* TABLE */}
            <div className="bg-white p-4 rounded-xl shadow-md">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left font-medium">Mã đơn</th>
                            <th className="px-6 py-3 text-left font-medium">Khách hàng</th>
                            <th className="px-6 py-3 text-left font-medium">Ngày đặt</th>
                            <th className="px-6 py-3 text-left font-medium">Tổng tiền</th>
                            <th className="px-6 py-3 text-left font-medium">Phí ship</th>
                            <th className="px-6 py-3 text-left font-medium">Trạng thái</th>
                            <th className="px-6 py-3 text-right font-medium">Hành động</th>
                        </tr>
                    </thead>

                    <tbody className="divide-y divide-gray-100">
                        {orders.map((o) => (
                            <tr key={o.order_id} className="hover:bg-gray-50">

                                {/* Mã đơn */}
                                <td className="px-6 py-4 text-blue-600 font-semibold">
                                    {o.order_id}
                                </td>

                                {/* Tên khách hàng */}
                                <td className="px-6 py-4">
                                    {o.customer_name}
                                </td>

                                {/* Ngày đặt */}
                                <td className="px-6 py-4">
                                    {o.order_date}
                                </td>

                                {/* Tổng tiền */}
                                <td className="px-6 py-4">
                                    {Number(o.final_total).toLocaleString()} đ
                                </td>

                                {/* Phí giao hàng */}
                                <td className="px-6 py-4">
                                    {Number(o.shipping_fee).toLocaleString()} đ
                                </td>

                                {/* Trạng thái */}
                                <td className="px-6 py-4">
                                    {o.status}
                                </td>

                                {/* Nút xem chi tiết */}
                                <td className="px-6 py-4 text-right">
                                    <button
                                        onClick={() => alert(`Xem chi tiết đơn: ${o.order_id}`)}
                                        className="text-blue-600 hover:text-blue-800 p-2 rounded-lg hover:bg-blue-50"
                                    >
                                        <Eye size={20} />
                                    </button>
                                </td>

                            </tr>
                        ))}
                    </tbody>
                </table>

                {orders.length === 0 && (
                    <p className="text-center py-4 text-gray-500">
                        Không có đơn hàng nào.
                    </p>
                )}
            </div>
        </div>
    );
};
