// /server/controllers/productController.js
const productModel = require('../models/productModel');
const db = require('../config/db.config');

const productController = {

    // =============================
    // GET /api/products
    // =============================
    listProducts: async (req, res) => {
        try {
            const products = await productModel.getAllProducts();
            res.status(200).json(products);
        } catch (error) {
            console.error("Error listProducts:", error);
            res.status(500).json({ message: 'Lỗi khi lấy danh sách sản phẩm.' });
        }
    },

    // =============================
    // GET /api/products/:id
    // =============================
    getProductById: async (req, res) => {
        try {
            const { id } = req.params;

            const [rows] = await db.query(
                "SELECT * FROM products WHERE product_id = ? LIMIT 1",
                [id]
            );

            if (rows.length === 0) {
                return res.status(404).json({ message: "Không tìm thấy sản phẩm." });
            }

            return res.status(200).json({ product: rows[0] });

        } catch (error) {
            console.error("Error getProductById:", error);
            res.status(500).json({ message: "Lỗi khi tìm sản phẩm." });
        }
    }
};

module.exports = productController;
