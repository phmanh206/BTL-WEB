const express = require('express');
const router = express.Router();
const customerController = require('../controllers/customerController');

// 🔍 Tìm khách hàng theo số điện thoại (THÊM MỚI)
router.get('/phone/:phone', customerController.getCustomerByPhone);

// Danh sách khách hàng
router.get('/', customerController.listCustomers);

// Xem chi tiết 1 khách hàng + lịch sử mua hàng
router.get('/:id', customerController.getCustomerDetail);

// Cập nhật thông tin khách hàng
router.put('/:id', customerController.updateCustomer);

module.exports = router;
