// /src/pages/OrderCreateScreen.js

import React, { useState } from "react";
import { Plus, Trash, ArrowLeft } from "lucide-react";

export const OrderCreateScreen = ({ currentUser, setPath }) => {
    const [customerPhone, setCustomerPhone] = useState("");
    const [customerInfo, setCustomerInfo] = useState(null);

    const [productCode, setProductCode] = useState("");
    const [productInfo, setProductInfo] = useState(null);
    const [quantity, setQuantity] = useState(1);

    const [items, setItems] = useState([]);

    const [shippingOption, setShippingOption] = useState("auto");
    const [manualShippingFee, setManualShippingFee] = useState(0);

    const [loading, setLoading] = useState(false);

    // =============================
    // TÌM KHÁCH THEO SĐT
    // =============================
    const findCustomer = async () => {
        try {
            const res = await fetch(
                `http://localhost:5001/api/customers/phone/${customerPhone}`
            );
            const data = await res.json();

            if (!res.ok) {
                alert("Không tìm thấy khách hàng.");
                setCustomerInfo(null);
                return;
            }

            setCustomerInfo(data.customer);
        } catch (err) {
            alert("Lỗi khi tìm khách hàng.");
            console.error(err);
        }
    };

    // =============================
    // TÌM SẢN PHẨM THEO MÃ
    // =============================
    const findProduct = async () => {
        try {
            const res = await fetch(
                `http://localhost:5001/api/products/${productCode}`
            );
            const data = await res.json();

            if (!res.ok) {
                alert("Không tìm thấy sản phẩm.");
                setProductInfo(null);
                return;
            }

            setProductInfo(data.product);
        } catch (err) {
            alert("Lỗi khi tìm sản phẩm.");
            console.error(err);
        }
    };

    // =============================
    // THÊM SẢN PHẨM VÀO ĐƠN
    // =============================
    const addItem = () => {
        if (!productInfo || quantity <= 0) return;

        const newItem = {
            productId: productInfo.product_id,
            name: productInfo.name || productInfo.product_name,
            price: productInfo.price,
            quantity,
            itemTotal: productInfo.price * quantity,
        };

        setItems([...items, newItem]);

        // Reset input
        setProductCode("");
        setProductInfo(null);
        setQuantity(1);
    };

    // =============================
    // XOÁ ITEM
    // =============================
    const removeItem = (index) => {
        setItems(items.filter((_, i) => i !== index));
    };

    // =============================
    // TÍNH TIỀN
    // =============================
    const totalItems = items.reduce((sum, it) => sum + it.itemTotal, 0);

    let shippingFee = 0;
    if (shippingOption === "auto") {
        shippingFee = totalItems < 100000 ? 10000 : 0;
    } else {
        shippingFee = Number(manualShippingFee || 0);
    }

    const finalTotal = totalItems + shippingFee;

    // =============================
    // TẠO ĐƠN
    // =============================
    const createOrder = async () => {
        if (!customerInfo) return alert("Chưa chọn khách hàng.");
        if (items.length === 0) return alert("Chưa thêm sản phẩm.");

        setLoading(true);

        try {
            const res = await fetch("http://localhost:5001/api/orders", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    customerPhone,
                    employeeId: currentUser.id,
                    employeeRole: currentUser.roleName,
                    items: items.map((p) => ({
                        productId: p.productId,
                        quantity: p.quantity,
                    })),
                    shippingOption,
                    manualShippingFee,
                }),
            });

            const data = await res.json();

            if (!res.ok) {
                alert(data.message || "Lỗi khi tạo đơn!");
                setLoading(false);
                return;
            }

            alert("Tạo đơn hàng thành công!");
            setPath("/orders");

        } catch (err) {
            alert("Lỗi kết nối server.");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    // =============================
    // UI CHÍNH
    // =============================
    return (
        <div className="space-y-6 p-4 md:p-6">

            <button
                onClick={() => setPath("/orders")}
                className="flex items-center gap-2 text-gray-700 hover:text-black"
            >
                <ArrowLeft size={20} />
                Quay lại
            </button>

            <h1 className="text-3xl font-bold">Tạo Đơn Hàng Mới</h1>

            {/* KHÁCH HÀNG */}
            <div className="bg-white p-4 rounded-xl shadow-md">
                <h2 className="font-semibold text-xl mb-3">Thông tin khách hàng</h2>

                <div className="flex gap-3">
                    <input
                        type="text"
                        placeholder="Nhập số điện thoại..."
                        value={customerPhone}
                        onChange={(e) => setCustomerPhone(e.target.value)}
                        className="border p-2 rounded-lg flex-grow"
                    />
                    <button
                        onClick={findCustomer}
                        className="bg-blue-600 text-white px-4 rounded-lg"
                    >
                        Tìm
                    </button>
                </div>

                {customerInfo && (
                    <div className="mt-4 p-3 border rounded-lg bg-gray-50">
                        <p><b>Tên:</b> {customerInfo.fullName}</p>
                        <p><b>SĐT:</b> {customerInfo.phone}</p>
                        <p><b>Địa chỉ:</b> {customerInfo.address}</p>
                    </div>
                )}
            </div>

            {/* SẢN PHẨM */}
            <div className="bg-white p-4 rounded-xl shadow-md">
                <h2 className="font-semibold text-xl mb-3">Thêm sản phẩm</h2>

                <div className="flex gap-3 mb-3">
                    <input
                        type="text"
                        placeholder="Mã sản phẩm..."
                        value={productCode}
                        onChange={(e) => setProductCode(e.target.value)}
                        className="border p-2 rounded-lg flex-grow"
                    />
                    <button
                        onClick={findProduct}
                        className="bg-green-600 text-white px-4 rounded-lg"
                    >
                        Tìm
                    </button>
                </div>

                {productInfo && (
                    <div className="p-3 border rounded-lg bg-gray-50">
                        <p><b>Tên SP:</b> {productInfo.name || productInfo.product_name}</p>
                        <p><b>Giá:</b> {productInfo.price.toLocaleString()} đ</p>

                        <div className="mt-3 flex items-center gap-3">
                            <input
                                type="number"
                                min="1"
                                value={quantity}
                                onChange={(e) => setQuantity(Number(e.target.value))}
                                className="border p-2 rounded w-20"
                            />

                            <button
                                onClick={addItem}
                                className="bg-blue-600 text-white px-4 rounded-lg flex items-center gap-2"
                            >
                                <Plus size={18} />
                                Thêm
                            </button>
                        </div>
                    </div>
                )}
            </div>

            {/* DANH SÁCH SẢN PHẨM */}
            <div className="bg-white p-4 rounded-xl shadow-md">
                <h2 className="font-semibold text-xl mb-3">Danh sách sản phẩm</h2>

                {items.length === 0 && <p>Chưa có sản phẩm nào.</p>}

                {items.map((it, index) => (
                    <div
                        key={index}
                        className="flex justify-between items-center p-2 border-b"
                    >
                        <div>
                            <p><b>{it.name}</b></p>
                            <p>
                                {it.quantity} × {it.price.toLocaleString()} đ
                            </p>
                        </div>

                        <button
                            onClick={() => removeItem(index)}
                            className="text-red-600 hover:text-red-800"
                        >
                            <Trash />
                        </button>
                    </div>
                ))}
            </div>

            {/* TÍNH TIỀN */}
            <div className="bg-white p-4 rounded-xl shadow-md">
                <h2 className="font-semibold text-xl mb-3">Tính tiền</h2>

                <p><b>Tổng tiền hàng:</b> {totalItems.toLocaleString()} đ</p>

                <div className="mt-2">
                    <label className="mr-3">
                        <input
                            type="radio"
                            value="auto"
                            checked={shippingOption === "auto"}
                            onChange={() => setShippingOption("auto")}
                        />{" "}
                        Tự tính phí ship
                    </label>

                    <label className="ml-4">
                        <input
                            type="radio"
                            value="manual"
                            checked={shippingOption === "manual"}
                            onChange={() => setShippingOption("manual")}
                        />{" "}
                        Nhập phí ship
                    </label>
                </div>

                {shippingOption === "manual" && (
                    <input
                        type="number"
                        value={manualShippingFee}
                        onChange={(e) => setManualShippingFee(e.target.value)}
                        className="border p-2 mt-2 w-32 rounded-lg"
                        placeholder="Phí ship"
                    />
                )}

                <p className="mt-4"><b>Phí giao hàng:</b> {shippingFee.toLocaleString()} đ</p>

                <h2 className="text-2xl font-bold mt-3">
                    Tổng thanh toán: {finalTotal.toLocaleString()} đ
                </h2>
            </div>

            {/* NÚT TẠO ĐƠN */}
            <button
                onClick={createOrder}
                disabled={loading}
                className="w-full bg-blue-600 text-white py-3 rounded-xl text-lg font-bold"
            >
                {loading ? "Đang tạo..." : "Tạo đơn hàng"}
            </button>

        </div>
    );
};
