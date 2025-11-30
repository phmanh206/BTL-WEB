// /server/models/productModel.js
const db = require('../config/db.config');
const productModel = {
    getAllProducts: async () => {
        const query = `
            SELECT 
                product_id as id, name, price, cost_price as costPrice, 
                stock_quantity as stockQuantity, is_active as isActive
            FROM products 
            ORDER BY product_id
        `;
        const [rows] = await db.query(query);
        return rows;
    }
};
module.exports = productModel;