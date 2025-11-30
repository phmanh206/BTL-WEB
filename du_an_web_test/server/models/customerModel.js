// /server/models/customerModel.js
const db = require('../config/db.config');

const customerModel = {
    // Lấy danh sách tất cả khách hàng
    getAllCustomers: async () => {
        const query = `
            SELECT 
                customer_id AS id,
                full_name AS fullName,
                phone,
                email,
                address,
                DATE_FORMAT(date_of_birth, '%Y-%m-%d') AS dob
            FROM customers
            ORDER BY customer_id;
        `;
        const [rows] = await db.query(query);
        return rows;
    },
    // Lấy 1 khách hàng theo id
    getCustomerById: async (id) => {
        const query = `
            SELECT 
                customer_id AS id,
                full_name AS fullName,
                phone,
                email,
                address,
                DATE_FORMAT(date_of_birth, '%Y-%m-%d') AS dob
            FROM customers
            WHERE customer_id = ?;
        `;
        const [rows] = await db.query(query, [id]);
        return rows[0] || null;
    },
        // Lấy lịch sử đơn hàng của 1 khách hàng
    getCustomerOrders: async (customerId) => {
        const query = `
            SELECT 
                o.order_id AS id,
                DATE_FORMAT(o.order_date, '%Y-%m-%d %H:%i:%s') AS orderDate,
                o.final_total AS totalAmount,
                o.status AS status,
                o.order_channel AS orderType,
                o.payment_status AS paymentStatus
            FROM orders o
            WHERE o.customer_id = ?
            ORDER BY o.order_date DESC;
        `;
        const [rows] = await db.query(query, [customerId]);
        return rows;
    },
        // Cập nhật thông tin khách hàng, không chạm vào lịch sử đơn hàng
    updateCustomer: async (id, data) => {
        const { fullName, email, phone, address, dob } = data;
        const query = `
            UPDATE customers
            SET 
                full_name = ?, 
                email = ?, 
                phone = ?, 
                address = ?, 
                date_of_birth = ?
            WHERE customer_id = ?;
        `;
        const [result] = await db.query(query, [fullName, email, phone, address, dob, id]);
        return result.affectedRows > 0;
    }
};

module.exports = customerModel;



