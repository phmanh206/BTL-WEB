// /client/src/pages/DashboardScreen.js

import React, { useState, useEffect, useMemo } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
         PieChart, Pie, Cell 
} from 'recharts';
import { ShoppingCart, Store, Globe, Users, TrendingUp } from 'lucide-react';
import { StatCard } from '../components/StatCard';
import { formatCurrency } from '../utils/helpers';
// Import API thực tế 
import { getMonthlySummaryData, getDashboardCurrentStats } from '../services/api'; 

// Hàm tiện ích tạo danh sách năm (từ 2020 đến năm hiện tại)
const generateYearOptions = () => {
    const currentYear = new Date().getFullYear();
    const years = [];
    for (let y = currentYear; y >= 2020; y--) {
        years.push(y);
    }
    return years;
};

const PIE_COLORS = ['#3b82f6', '#10b981']; // Xanh Dương (Direct), Xanh Lá (Online)

export const DashboardScreen = () => {
    const [monthlySummary, setMonthlySummary] = useState([]); // Dữ liệu 12 tháng/năm
    const [stats, setStats] = useState(null); // Chỉ số của THÁNG GẦN NHẤT (Stat Cards)
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);
    
    // State chọn năm và loại biểu đồ
    const [selectedYear, setSelectedYear] = useState(new Date().getFullYear()); 
    const [chartType, setChartType] = useState('bar'); 
    
    const yearOptions = useMemo(() => generateYearOptions(), []); 

    // --- EFFECT 1: Tải Dữ liệu THÁNG HIỆN TẠI (Stat Cards) ---
    const [currentMonthLabel, setCurrentMonthLabel] = useState(''); // State cho tiêu đề động
    
    useEffect(() => {
        const fetchCurrentStats = async () => {
            try {
                const currentStats = await getDashboardCurrentStats(); 
                setStats(currentStats);
                
                // Cập nhật nhãn tháng hiện tại (Chỉ dựa vào ngày hệ thống)
                const today = new Date();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const year = today.getFullYear();
                setCurrentMonthLabel(`${month}/${year}`);
                
            } catch (err) {
                console.error("Error fetching current stats:", err);
            }
        };
        fetchCurrentStats();
    }, []); 

    // --- EFFECT 2: Tải Dữ liệu CẢ NĂM (Biểu đồ & Bảng) ---
    useEffect(() => {
        const fetchMonthlySummary = async () => {
            setIsLoading(true);
            setError(null);
            setMonthlySummary([]); 
            
            try {
                const summaryData = await getMonthlySummaryData(selectedYear); 
                
                if (!Array.isArray(summaryData)) { 
                    setError('Phản hồi dữ liệu không hợp lệ từ Server.');
                    return;
                }
                
                if (summaryData.length === 0) {
                    setError(`Không có giao dịch hoàn thành nào trong năm ${selectedYear}.`);
                    return;
                }
                
                // Xóa lỗi nếu có dữ liệu
                setError(null);
                setMonthlySummary(summaryData); 
                
            } catch (err) {
                setError(err.message || 'Không thể tải dữ liệu chi tiết theo năm.');
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        };
        fetchMonthlySummary();
    }, [selectedYear]); 

    // Dữ liệu cho Biểu đồ Bar Chart (12 tháng)
    const salesChartData = useMemo(() => {
        return monthlySummary
            .map(m => ({
                name: `T.${m.month.substring(5)}`, 
                DoanhThu: m.salesRevenue,
                Direct: m.directRevenue,
                Online: m.onlineRevenue,
            }));
    }, [monthlySummary]);

    // Dữ liệu cho 4 Biểu đồ Tròn (theo Quý)
    const quarterlyPieData = useMemo(() => {
        const quarterlyTotals = { 1: { Direct: 0, Online: 0 }, 2: { Direct: 0, Online: 0 }, 3: { Direct: 0, Online: 0 }, 4: { Direct: 0, Online: 0 } };

        monthlySummary.forEach(m => {
            const month = parseInt(m.month.substring(5)); 
            let quarter;
            
            if (month >= 1 && month <= 3) quarter = 1;
            else if (month >= 4 && month <= 6) quarter = 2;
            else if (month >= 7 && month <= 9) quarter = 3;
            else quarter = 4;

            // Đảm bảo dùng giá trị số
            quarterlyTotals[quarter].Direct += parseFloat(m.directRevenue) || 0;
            quarterlyTotals[quarter].Online += parseFloat(m.onlineRevenue) || 0;
        });

        return Object.keys(quarterlyTotals).map(q => {
            const total = quarterlyTotals[q].Direct + quarterlyTotals[q].Online;
            const hasData = total > 0;
            
            return {
                quarter: `Quý ${q}`,
                hasData: hasData,
                data: [
                    { name: 'Trực tiếp', value: quarterlyTotals[q].Direct, color: PIE_COLORS[0] },
                    { name: 'Online', value: quarterlyTotals[q].Online, color: PIE_COLORS[1] },
                ]
            };
        });
    }, [monthlySummary]);


    if (isLoading && monthlySummary.length === 0) {
        return <p className="p-6 text-center text-xl text-blue-600 font-semibold">Đang tải dữ liệu Dashboard...</p>;
    }

    if (error) {
        return <p className="p-6 text-center text-xl text-red-600 font-semibold">Lỗi: {error}</p>;
    }
    
    // Rất quan trọng: Kiểm tra stats trước khi render StatCard
    if (!stats) return null;

    const netProfit = stats.netProfit;

    return (
        <div className="space-y-6 p-4 md:p-6">
            {/* TIÊU ĐỀ ĐỘNG */}
            <h1 className="text-3xl font-bold text-gray-900">
                Dashboard Tổng quan  - Tháng {currentMonthLabel}
            </h1>
            
            

            {/* Ô tổng hợp (STAT CARDS) */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-6">
                <StatCard title={`Tổng Đơn hàng `} value={stats.totalOrders} icon={ShoppingCart} color="border-yellow-500" />
                <StatCard title={`Doanh thu Trực tiếp `} value={formatCurrency(stats.directRevenue)} icon={Store} color="border-indigo-500" />
                <StatCard title={`Doanh thu Online `} value={formatCurrency(stats.onlineRevenue)} icon={Globe} color="border-green-500" />
                <StatCard title={`Tổng Khách hàng `} value={stats.totalCustomers} icon={Users} color="border-purple-500" />
                <StatCard 
                    title={`Lợi nhuận Ròng `} 
                    value={formatCurrency(netProfit)} 
                    icon={TrendingUp} 
                    color="border-cyan-500" 
                    isNetProfit={true} 
                    netProfitValue={netProfit} 
                /> 
            </div>
            
            {/* Chi tiết chi phí */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 bg-white p-4 rounded-xl shadow-lg text-sm">
                <p className="text-gray-700"><strong>Tổng Doanh thu:</strong> <span className="text-blue-600 font-bold">{formatCurrency(stats.totalRevenue)}</span></p>
                <p className="text-gray-700"><strong>Giá vốn (COGS):</strong> <span className="text-red-500">{formatCurrency(stats.totalCOGS)}</span></p>
                <p className="text-gray-700"><strong>Tổng Lương:</strong> <span className="text-red-500">{formatCurrency(stats.totalSalariesPaid)}</span></p>
            </div>
            {/* KHỐI BIỂU ĐỒ CHÍNH VÀ LỊCH SỬ HOẠT ĐỘNG */}
            {/* VỊ TRÍ CHỌN NĂM MỚI: Đặt ở đây (trước phần nội dung biểu đồ) */}
            <div className="flex items-center space-x-3 mt-4">
                <label className="text-gray-700 font-medium text-lg">Năm Thống kê chi tiết:</label>
                <select
                    value={selectedYear}
                    onChange={(e) => setSelectedYear(parseInt(e.target.value))} 
                    className="px-4 py-2 border border-blue-500 rounded-lg shadow-sm font-semibold"
                >
                    {yearOptions.map(year => (
                        <option key={year} value={year}>{year}</option>
                    ))}
                </select>
            </div>
            
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                
                {/* -------------------- BIỂU ĐỒ (lg:col-span-2) -------------------- */}
                <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow-lg">
                    {/* NÚT CHỌN LOẠI BIỂU ĐỒ (Đặt bên trong khung Biểu đồ) */}
                    <div className="flex justify-between items-center mb-4 border-b pb-3">
                        <h2 className="text-xl font-bold text-gray-800">
                            {chartType === 'bar' ? `Biểu đồ Doanh thu Năm ${selectedYear}` : `Tỷ trọng Kênh Bán hàng theo Quý ${selectedYear}`}
                        </h2>
                        <div className="flex items-center space-x-2">
                            <button
                                onClick={() => setChartType('bar')}
                                className={`py-1 px-3 rounded-md text-sm transition ${chartType === 'bar' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'}`}
                            >
                                Biểu đồ Cột (12 Tháng)
                            </button>
                            <button
                                onClick={() => setChartType('pie')}
                                className={`py-1 px-3 rounded-md text-sm transition ${chartType === 'pie' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'}`}
                            >
                                Biểu đồ Tròn (4 Quý)
                            </button>
                        </div>
                    </div>
                
                    {error && monthlySummary.length === 0 ? (
                        <p className="text-center text-red-600 py-20">{error}</p>
                    ) : (
                        <>
                            {/* Hiển thị Biểu đồ Cột */}
                            {chartType === 'bar' && (
                                <div style={{ width: '100%', height: 350 }}>
                                    <ResponsiveContainer width="100%" height="100%">
                                        <BarChart data={salesChartData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                                            <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
                                            <XAxis dataKey="name" stroke="#374151" /> 
                                            <YAxis tickFormatter={(value) => (value / 1000000).toFixed(0) + 'M'} stroke="#374151" /> 
                                            <Tooltip formatter={(value, name) => [formatCurrency(value), name]} />
                                            <Legend />
                                            <Bar dataKey="Direct" name="Trực tiếp" stackId="a" fill={PIE_COLORS[0]}  />
                                            <Bar dataKey="Online" name="Online" stackId="a" fill={PIE_COLORS[1]}  />
                                        </BarChart>
                                    </ResponsiveContainer>
                                </div>
                            )}

                            {/* Hiển thị Biểu đồ Tròn */}
                            {chartType === 'pie' && (
                                <div className="grid grid-cols-2 gap-4">
                                    {quarterlyPieData.map(qData => (
                                        <div key={qData.quarter} className="text-center p-3 border rounded-lg">
                                            <h3 className="font-semibold text-blue-800 mb-2">{qData.quarter}</h3>
                                            {qData.hasData ? (
                                                <ResponsiveContainer width="100%" height={180}>
                                                    <PieChart>
                                                        <Pie
                                                            data={qData.data}
                                                            dataKey="value"
                                                            nameKey="name"
                                                            cx="50%" cy="50%" outerRadius={60}
                                                            label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(1)}%`} 
                                                            labelLine={false} 
                                                        >
                                                            {qData.data.map((entry, index) => (
                                                                <Cell key={`cell-${index}`} fill={entry.color} />
                                                            ))}
                                                        </Pie>
                                                        <Tooltip formatter={(value, name) => [formatCurrency(value), name]} />
                                                    </PieChart>
                                                </ResponsiveContainer>
                                            ) : (
                                                <div className="text-gray-500 h-[180px] flex items-center justify-center text-sm">
                                                    Không có giao dịch
                                                </div>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            )}
                        </>
                    )}
                </div>

                {/* LỊCH SỬ HOẠT ĐỘNG THEO THÁNG (Cột 3) */}
                <div className="lg:col-span-1 bg-white p-6 rounded-xl shadow-lg">
                    <h2 className="text-xl font-semibold text-gray-800 mb-4">Lịch sử Hoạt động Kinh doanh Năm {selectedYear}</h2>
                    <div className="overflow-x-auto">
                        {monthlySummary.filter(m => m.salesRevenue > 0).length > 0 ? (
                            <table className="min-w-full divide-y divide-gray-200">
                                <thead className="bg-gray-50">
                                    <tr>
                                        <th className="py-2 text-left text-xs font-medium text-gray-500 uppercase">Tháng</th>
                                        <th className="py-2 text-right text-xs font-medium text-gray-500 uppercase">Doanh thu</th>
                                        <th className="py-2 text-right text-xs font-medium text-gray-500 uppercase">Lợi nhuận Ròng</th>
                                    </tr>
                                </thead>
                                <tbody className="bg-white divide-y divide-gray-200">
                                    {monthlySummary
                                        .filter(m => m.salesRevenue > 0) 
                                        .map(m => (
                                        <tr key={m.month} className="hover:bg-gray-50">
                                            <td className="py-2 whitespace-nowrap text-sm font-semibold text-blue-600">{`T.${m.month.substring(5)}`}</td>
                                            <td className="py-2 whitespace-nowrap text-sm text-right text-gray-900">{formatCurrency(m.salesRevenue)}</td>
                                            <td className={`py-2 whitespace-nowrap text-sm font-bold text-right ${m.netProfit > 0 ? 'text-green-600' : (m.netProfit < 0 ? 'text-red-600' : 'text-gray-500')}`}>
                                                {formatCurrency(m.netProfit)}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        ) : (
                            <p className="text-center py-8 text-gray-500">Không có giao dịch hoàn thành nào trong năm {selectedYear}.</p>
                        )}
                    </div>
                    <p className="text-xs text-gray-500 mt-4">
                        Lợi nhuận ròng = Doanh thu - COGS - Tổng lương đã trả.
                    </p>
                </div>
            </div>
        </div>
    );
};