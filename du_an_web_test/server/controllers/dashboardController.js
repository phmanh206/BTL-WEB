// /server/controllers/dashboardController.js (FIXED LOGIC)

const dashboardModel = require('../models/dashboardModel');

// Hàm Helper để tạo khung 12 tháng (01 -> 12) cho năm đã chọn
const generate12MonthsForYear = (targetYear) => {
    const months = [];
    for (let i = 1; i <= 12; i++) {
        const month = String(i).padStart(2, '0');
        months.push(`${targetYear}-${month}`); 
    }
    return months; 
};

// Hàm Helper để tìm tháng hiện tại hoặc tháng gần nhất có dữ liệu (cho Stat Cards)
const getCurrentMonthStats = (processedData) => {
    const today = new Date();
    const currentYearMonth = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}`;

    const currentMonthData = processedData.find(item => item.month === currentYearMonth);
    const latestData = processedData.filter(d => d.salesRevenue > 0).sort((a, b) => a.month.localeCompare(b.month));

    if (currentMonthData && currentMonthData.salesRevenue > 0) {
        return currentMonthData;
    } 
    else if (latestData.length > 0) {
        return latestData[latestData.length - 1]; 
    } 
    else {
        return { 
            salesRevenue: 0, totalCOGS: 0, totalSalariesPaid: 0, netProfit: 0, 
            directRevenue: 0, onlineRevenue: 0, totalOrders: 0 
        };
    }
};

const dashboardController = {
    // API GET /api/dashboard/summary?year=... (Cho Biểu đồ và Bảng)
    getDashboardData: async (req, res) => {
        try {
            const targetYear = parseInt(req.query.year) || new Date().getFullYear(); 
            
            const [monthlyData, salaryData] = await Promise.all([
                dashboardModel.getMonthlySummary(targetYear), 
                dashboardModel.getMonthlySalaries(targetYear)
            ]);
            
            // ... (Logic hợp nhất dữ liệu thành Summary 12 tháng giữ nguyên) ...

            const full12Months = generate12MonthsForYear(targetYear);
            const dataMap = monthlyData.reduce((map, item) => { map[item.month] = item; return map; }, {});
            const salaryMap = salaryData.reduce((map, item) => { map[item.month] = item.totalSalaries; return map; }, {});

            const summary = full12Months.map(monthKey => {
                const item = dataMap[monthKey] || {}; 
                
                const totalSalariesPaid = parseFloat(salaryMap[monthKey] || 0);
                const salesRevenue = parseFloat(item.salesRevenue) || 0;
                const totalCOGS = parseFloat(item.totalCOGS) || 0;
                const totalOrders = parseFloat(item.totalOrders) || 0;
                
                const netProfit = salesRevenue - totalCOGS - totalSalariesPaid;
                const directRevenue = Math.round(salesRevenue * 0.6); 
                const onlineRevenue = Math.round(salesRevenue * 0.4);
                
                return {
                    month: monthKey,
                    salesRevenue: salesRevenue,
                    totalCOGS: totalCOGS,
                    totalSalariesPaid: totalSalariesPaid,
                    netProfit: netProfit,
                    directRevenue: directRevenue,
                    onlineRevenue: onlineRevenue,
                    totalOrders: totalOrders
                };
            });

            res.status(200).json(summary); 

        } catch (error) {
            console.error("Dashboard controller error:", error);
            res.status(500).json({ message: 'Lỗi khi tải dữ liệu Dashboard.', details: error.message });
        }
    },

    // API GET /api/dashboard/current-stats (Cho Stat Cards)
    getCurrentStats: async (req, res) => {
        try {
            const currentYear = new Date().getFullYear();
            
            const [monthlyData, salaryData] = await Promise.all([
                dashboardModel.getMonthlySummary(currentYear), 
                dashboardModel.getMonthlySalaries(currentYear)
            ]);
            
            const full12Months = generate12MonthsForYear(currentYear);
            const dataMap = monthlyData.reduce((map, item) => { map[item.month] = item; return map; }, {});
            const salaryMap = salaryData.reduce((map, item) => { map[item.month] = item.totalSalaries; return map; }, {});

            const summary = full12Months.map(monthKey => {
                const item = dataMap[monthKey] || {}; 
                const totalSalariesPaid = parseFloat(salaryMap[monthKey] || 0); 
                const salesRevenue = parseFloat(item.salesRevenue) || 0;
                const totalCOGS = parseFloat(item.totalCOGS) || 0;             
                const netProfit = salesRevenue - totalCOGS - totalSalariesPaid;
                const directRevenue = Math.round(salesRevenue * 0.6); 
                const onlineRevenue = Math.round(salesRevenue * 0.4);
                const totalOrders = parseFloat(item.totalOrders) || 0;

                return { month: monthKey, salesRevenue, totalCOGS, totalSalariesPaid, netProfit, directRevenue, onlineRevenue, totalOrders };
            });


            // Lấy chỉ số tổng hợp
            const statsMonthData = getCurrentMonthStats(summary); 
            // const totalOrdersYear = summary.reduce((sum, item) => sum + item.totalOrders, 0); // Logic cũ: Tổng đơn hàng cả năm

            const statsResponse = {
                // FIX: Lấy Tổng Đơn hàng của tháng hiện tại
                totalOrders: statsMonthData.totalOrders, 
                totalCustomers: 20, 
                directRevenue: statsMonthData.directRevenue,
                onlineRevenue: statsMonthData.onlineRevenue,
                totalRevenue: statsMonthData.salesRevenue,
                totalCOGS: statsMonthData.totalCOGS,
                totalSalariesPaid: statsMonthData.totalSalariesPaid,
                netProfit: statsMonthData.netProfit,
            };

            res.status(200).json(statsResponse);
        } catch (error) {
            console.error("Error fetching current stats:", error);
            res.status(500).json({ message: 'Lỗi khi tải chỉ số thống kê tổng hợp.' });
        }
    }
};

module.exports = dashboardController;