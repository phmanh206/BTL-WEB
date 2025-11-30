// /server/controllers/userController.js
const userModel = require('../models/userModel');
const userController = {
    listUsers: async (req, res) => {
        // TODO: Cần middleware kiểm tra quyền Owner
        try {
            const users = await userModel.getAllUsers();
            res.status(200).json(users);
        } catch (error) {
            res.status(500).json({ message: 'Lỗi khi lấy danh sách nhân viên.' });
        }
    },
};
module.exports = userController;