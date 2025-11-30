// /server/routes/productRoutes.js
const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');

// Lấy tất cả sản phẩm
router.get('/', productController.listProducts);

// 🔍 Tìm sản phẩm theo mã (THÊM MỚI)
router.get('/:id', productController.getProductById);

module.exports = router;
