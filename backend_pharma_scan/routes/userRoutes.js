const express = require('express');
const router = express.Router();
const { 
  registerUser, 
  loginUser, 
  getUserProfile 
} = require('../controllers/userController');
const { protect } = require('../middleware/auth');

// Register user
router.post('/signup', registerUser);

// Login user
router.post('/login', loginUser);

// Get user profile
router.get('/me', protect, getUserProfile);

// Health check endpoint
router.get('/health', (req, res) => {
  const mongoose = require('mongoose');
  const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
  
  res.json({
    success: true,
    status: 'API is running',
    database: dbStatus
  });
});

module.exports = router;