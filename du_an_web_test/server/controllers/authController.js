const userModel = require('../models/userModel');
const jwt = require('jsonwebtoken');
const db = require('../config/db.config'); // Cần import DB để xử lý Transaction

const JWT_SECRET = process.env.JWT_SECRET || 'default_secret';

const authController = {
    // ============================================================
    // 1. ĐĂNG NHẬP (LOGIN)
    // ============================================================
    login: async (req, res) => {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ message: 'Vui lòng nhập tài khoản và mật khẩu.' });
        }

        try {
            // Tìm user trong DB
            const user = await userModel.findByUsername(username);

            if (!user) {
                return res.status(401).json({ message: 'Tài khoản không tồn tại.' });
            }
            
            // So sánh mật khẩu (Đang dùng plaintext cho demo, thực tế nên dùng bcrypt)
            if (user.password_hash !== password) {
                return res.status(401).json({ message: 'Mật khẩu không chính xác.' });
            }

            // Tạo Token
            const token = jwt.sign(
                { userId: user.user_id, roleId: user.role_id }, 
                JWT_SECRET, 
                { expiresIn: '1d' }
            );
            
            // Trả về dữ liệu
            res.status(200).json({
                message: 'Đăng nhập thành công',
                token,
                user: {
                    userId: user.user_id,
                    fullName: user.full_name || user.username,
                    roleId: user.role_id,
                    roleName: user.roleName,
                    mustChangePassword: user.must_change_password
                }
            });

        } catch (error) {
            console.error("Login error:", error);
            res.status(500).json({ message: 'Lỗi server khi đăng nhập.' });
        }
    },

    // ============================================================
    // 2. ĐĂNG KÝ (REGISTER) - LOGIC GHI DB THẬT
    // ============================================================
    register: async (req, res) => {
        const { fullName, phone, password } = req.body;

        if (!fullName || !phone || !password) {
            return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin.' });
        }

        // --- BẮT ĐẦU TRANSACTION ---
        // Dùng transaction để đảm bảo lưu cả vào bảng USERS và CUSTOMERS cùng lúc
        let connection;
        try {
            connection = await db.getConnection();
            await connection.beginTransaction();

            // 1. Kiểm tra số điện thoại đã tồn tại chưa
            const [existing] = await connection.query("SELECT user_id FROM users WHERE username = ?", [phone]);
            if (existing.length > 0) {
                await connection.release();
                return res.status(409).json({ message: 'Số điện thoại này đã được đăng ký.' });
            }

            // 2. Insert vào bảng USERS
            // Role ID 2 = Customer (Mặc định)
            // User ID = Số điện thoại
            // Username = Số điện thoại
            const insertUserQuery = `
                INSERT INTO users 
                (user_id, username, password_hash, role_id, status, must_change_password)
                VALUES (?, ?, ?, 2, 'Active', FALSE)
            `;
            await connection.query(insertUserQuery, [phone, phone, password]);

            // 3. Insert vào bảng CUSTOMERS
            // Tạo mã KH: CUS_ + SĐT
            const newCustomerId = `CUS_${phone}`; 
            const insertCustomerQuery = `
                INSERT INTO customers 
                (customer_id, user_id, full_name, phone)
                VALUES (?, ?, ?, ?)
            `;
            await connection.query(insertCustomerQuery, [newCustomerId, phone, fullName, phone]);

            // 4. Hoàn tất Transaction
            await connection.commit();
            connection.release();

            res.status(201).json({ message: 'Đăng ký thành công! Vui lòng đăng nhập.' });

        } catch (error) {
            // Nếu có lỗi, hoàn tác mọi thay đổi
            if (connection) {
                await connection.rollback();
                connection.release();
            }
            console.error("Register error:", error);
            res.status(500).json({ message: 'Lỗi hệ thống khi đăng ký.', details: error.message });
        }
    },

    // ============================================================
    // 3. ĐỔI MẬT KHẨU (CHỦ ĐỘNG)
    // ============================================================
    changePassword: async (req, res) => {
        const { userId, oldPassword, newPassword } = req.body;
        
        if (!userId || !oldPassword || !newPassword) {
            return res.status(400).json({ message: 'Thiếu thông tin.' });
        }

        try {
            const user = await userModel.findById(userId);
            if (!user) {
                return res.status(404).json({ message: 'Người dùng không tồn tại.' });
            }

            if (user.password_hash !== oldPassword) {
                return res.status(400).json({ message: 'Mật khẩu cũ không chính xác.' });
            }

            await userModel.updatePassword(userId, newPassword, 0); // 0 = False
            res.status(200).json({ message: 'Đổi mật khẩu thành công.' });

        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Lỗi server.' });
        }
    },

    // ============================================================
    // 4. RESET MẬT KHẨU (LẦN ĐẦU)
    // ============================================================
    resetPassword: async (req, res) => {
        const { userId, newPassword } = req.body;

        if (!userId || !newPassword) {
            return res.status(400).json({ message: 'Thiếu thông tin.' });
        }

        try {
            await userModel.updatePassword(userId, newPassword, 0);
            res.status(200).json({ message: 'Đặt lại mật khẩu thành công' });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Lỗi khi đặt lại mật khẩu' });
        }
    }
};

module.exports = authController;