const customerModel = require('../models/customerModel');
const db = require('../config/db.config');

const customerController = {

    // =============================
    // GET /api/customers
    // =============================
    listCustomers: async (req, res) => {
        try {
            const customers = await customerModel.getAllCustomers();
            res.status(200).json(customers);
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Lỗi khi lấy danh sách khách hàng.' });
        }
    },

    // =============================
    // 🔍 GET /api/customers/phone/:phone
    // =============================
    getCustomerByPhone: async (req, res) => {
        try {
            const phone = req.params.phone;

            const [rows] = await db.query(
                "SELECT * FROM customers WHERE phone = ? LIMIT 1",
                [phone]
            );

            if (rows.length === 0) {
                return res.status(404).json({ message: "Không tìm thấy khách hàng." });
            }

            return res.status(200).json({ customer: rows[0] });

        } catch (error) {
            console.error("Error getCustomerByPhone:", error);
            res.status(500).json({ message: "Lỗi server khi tìm khách hàng." });
        }
    },

    // =============================
    // GET /api/customers/:id
    // =============================
    getCustomerDetail: async (req, res) => {
        try {
            const { id } = req.params;

            const customer = await customerModel.getCustomerById(id);
            if (!customer) {
                return res.status(404).json({ message: 'Không tìm thấy khách hàng.' });
            }

            const orders = await customerModel.getCustomerOrders(id);

            return res.status(200).json({
                customer,
                orders: orders || []
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Lỗi khi lấy thông tin khách hàng.' });
        }
    },

    // =============================
    // PUT /api/customers/:id
    // =============================
    updateCustomer: async (req, res) => {
        try {
            const { id } = req.params;
            const { fullName, email, phone, address, dob } = req.body;

            const updated = await customerModel.updateCustomer(id, {
                fullName,
                email,
                phone,
                address,
                dob
            });

            if (!updated) {
                return res.status(404).json({ message: 'Không tìm thấy khách hàng để cập nhật.' });
            }

            res.status(200).json({ message: 'Cập nhật khách hàng thành công.' });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Lỗi khi cập nhật khách hàng.' });
        }
    }
};

module.exports = customerController;
