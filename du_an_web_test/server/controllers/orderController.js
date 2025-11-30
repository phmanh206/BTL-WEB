const db = require('../config/db.config');
const orderModel = require('../models/orderModel');

// ===========================
// TẠO MÃ ĐƠN TỰ ĐỘNG
// ===========================
async function generateOrderId() {
    const [rows] = await db.query(`
        SELECT order_id FROM orders ORDER BY order_id DESC LIMIT 1
    `);

    if (rows.length === 0) return "ORD001";

    const last = rows[0].order_id.replace("ORD", "");
    const next = String(parseInt(last) + 1).padStart(3, "0");

    return "ORD" + next;
}

const orderController = {

    // ===========================
    // LẤY DANH SÁCH ĐƠN HÀNG
    // ===========================
    listOrders: async (req, res) => {
        try {
            const orders = await orderModel.getAllOrders();
            res.status(200).json(orders || []);
        } catch (error) {
            console.error("Error listing orders:", error);
            res.status(500).json({
                message: "Lỗi SQL khi truy vấn đơn hàng.",
                details: error.message
            });
        }
    },

    // ===========================
    // TẠO ĐƠN HÀNG
    // ===========================
    createOrder: async (req, res) => {
        try {
            const {
                customerPhone,
                employeeId,
                employeeRole,
                items,
                shippingOption,
                manualShippingFee
            } = req.body;

            if (!customerPhone || !employeeId || !items || items.length === 0) {
                return res.status(400).json({ message: "Thiếu dữ liệu tạo đơn hàng." });
            }

            // 1. Tìm customer_id từ phone
            const [cust] = await db.query(
                "SELECT customer_id FROM customers WHERE phone = ?",
                [customerPhone]
            );

            if (cust.length === 0) {
                return res.status(404).json({ message: "Không tìm thấy khách hàng." });
            }

            const customerId = cust[0].customer_id;

            // 2. Tính tiền
            let subtotal = 0;
            let orderItems = [];

            for (const it of items) {
                const [prod] = await db.query(
                    "SELECT price FROM products WHERE product_id = ?",
                    [it.productId]
                );

                if (prod.length === 0)
                    return res.status(404).json({ message: `Không tìm thấy sản phẩm ${it.productId}` });

                const price = prod[0].price;
                const itemTotal = price * it.quantity;

                subtotal += itemTotal;

                orderItems.push({
                    ...it,
                    price,
                    itemTotal
                });
            }

            // 3. Tính phí ship
            let shippingFee = 0;
            if (shippingOption === "auto") {
                shippingFee = subtotal < 100000 ? 10000 : 0;
            } else {
                shippingFee = Number(manualShippingFee || 0);
            }

            const finalTotal = subtotal + shippingFee;

            // 4. Tạo order_id mới
            const orderId = await generateOrderId();

            // 5. Xác định trạng thái theo role
            let status = "Hoàn Thành";
            if (employeeRole === "Online Sales") {
                status = "Đang Giao";
            }

            // 6. Lưu vào bảng orders
            await db.query(
                `
                INSERT INTO orders
                (order_id, customer_id, staff_id, order_date, subtotal, shipping_cost, final_total, status)
                VALUES (?, ?, ?, NOW(), ?, ?, ?, ?)
                `,
                [orderId, customerId, employeeId, subtotal, shippingFee, finalTotal, status]
            );

            // 7. Lưu vào bảng order_details
            for (const it of orderItems) {
                await db.query(
                    `
                    INSERT INTO order_details
                    (order_id, product_id, quantity, unit_price)
                    VALUES (?, ?, ?, ?)
                    `,
                    [orderId, it.productId, it.quantity, it.price]
                );
            }

            res.status(201).json({
                message: "Tạo đơn hàng thành công!",
                orderId,
                customerId,
                subtotal,
                shippingFee,
                finalTotal,
                status,
                items: orderItems
            });

        } catch (error) {
            console.error("Error creating order:", error);
            res.status(500).json({
                message: "Lỗi khi tạo đơn hàng.",
                details: error.message
            });
        }
    }

};

module.exports = orderController;
