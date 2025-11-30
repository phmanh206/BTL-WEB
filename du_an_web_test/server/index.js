// /server/index.js
require('dotenv').config(); 
const express = require('express');
const cors = require('cors');

require('./config/db.config'); 
const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const customerRoutes = require('./routes/customerRoutes');
const userRoutes = require('./routes/userRoutes');
const stockInRoutes = require('./routes/stockInRoutes');
const orderRoutes = require('./routes/orderRoutes');   // <-- THÊM DÒNG NÀY
const salaryRoutes = require('./routes/salaryRoutes'); // <--
const dashboardRoutes = require('./routes/dashboardRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
// ...

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors()); 
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/users', userRoutes);
app.use('/api/stockin', stockInRoutes);
app.use('/api/orders', orderRoutes);   // <-- THÊM ROUTE
app.use('/api/salaries', salaryRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/categories', categoryRoutes);

app.get('/', (req, res) => res.send(`Store Management API is running on port ${PORT}`));

app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));