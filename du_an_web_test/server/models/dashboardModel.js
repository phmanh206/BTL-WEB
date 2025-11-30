const db = require('../config/db.config');

const dashboardModel = {
    getMonthlySummary: async (year) => { 
        const startDate = `${year}-01-01`; 
        const endDate = `${year}-12-31`;   

        const query = `
            SELECT
                DATE_FORMAT(o.order_date, '%Y-%m') AS month,
                IFNULL(SUM(o.final_total), 0) AS salesRevenue, 
                IFNULL(SUM(od.quantity * IFNULL(p.cost_price, 0)), 0) AS totalCOGS, 
                COUNT(DISTINCT o.order_id) AS totalOrders
            FROM orders o
            LEFT JOIN order_details od ON o.order_id = od.order_id
            LEFT JOIN products p ON od.product_id = p.product_id
            WHERE o.status = 'Hoàn Thành'
              AND DATE(o.order_date) BETWEEN ? AND ?
            GROUP BY month
            ORDER BY month ASC;
        `;

        try {
            const [rows] = await db.query(query, [startDate, endDate]);
            return rows.map(row => ({
                month: row.month,
                salesRevenue: Number(row.salesRevenue),
                totalCOGS: Number(row.totalCOGS),
                totalOrders: Number(row.totalOrders)
            }));
        } catch (error) {
            console.error("❌ SQL ERROR in getMonthlySummary:", error);
            throw new Error(`SQL Error on Dashboard Summary: ${error.message}`);
        }
    },

    getMonthlySalaries: async (year) => {
        const startDate = `${year}-01-01`;
        const endDate = `${year}-12-31`;

        const query = `
            SELECT 
                DATE_FORMAT(month_year, '%Y-%m') AS month,
                IFNULL(SUM(net_salary), 0) AS totalSalaries
            FROM salaries
            WHERE month_year BETWEEN ? AND ?
            GROUP BY month
            ORDER BY month ASC;
        `;

        try {
            const [rows] = await db.query(query, [startDate, endDate]);
            return rows.map(row => ({
                month: row.month,
                totalSalaries: Number(row.totalSalaries)
            }));
        } catch (error) {
            console.error("❌ SQL ERROR in getMonthlySalaries:", error);
            throw new Error(`SQL Error on Monthly Salaries: ${error.message}`);
        }
    }
};

module.exports = dashboardModel;
