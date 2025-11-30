// /server/routes/orderRoutes.js
const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

// Lấy danh sách đơn hàng
router.get('/', orderController.listOrders);

// Tạo đơn hàng mới
router.post('/', orderController.createOrder);

module.exports = router;
