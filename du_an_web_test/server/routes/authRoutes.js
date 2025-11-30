// C:\Users\Admin\Downloads\DUANWEB(1)\server\routes\authRoutes.js

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Định nghĩa các routes
router.post('/login', authController.login);
router.post('/register', authController.register); // <-- Dòng này gây lỗi nếu controller thiếu hàm register
router.post('/change-password', authController.changePassword);
router.post('/reset-password', authController.resetPassword);

module.exports = router;