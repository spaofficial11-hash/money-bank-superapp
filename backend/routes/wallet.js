const express = require('express');
const router = express.Router();
const admin = require('../firebase');
const { verifyToken } = require('../utils/deviceVerify');
const { sendPaymentRequest } = require('../utils/payment');
const { notifyAdmin } = require('../functions/notifyAdmin');

// 📌 Middleware to check auth token
router.use(async (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'No token provided' });

    try {
        const decoded = verifyToken(token);
        req.user = decoded;
        next();
    } catch (err) {
        res.status(401).json({ error: 'Invalid token' });
    }
});

// 📌 Get wallet balance
router.get('/balance', async (req, res) => {
    try {
        const doc = await admin.firestore().collection('users').doc(req.user.uid).get();
        if (!doc.exists) return res.status(404).json({ error: 'User not found' });

        res.json({ walletBalance: doc.data().walletBalance || 0 });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Deposit request
router.post('/deposit', async (req, res) => {
    try {
        const { amount, method } = req.body;
        if (!amount || amount <= 0) {
            return res.status(400).json({ error: 'Invalid amount' });
        }

        // Create deposit request in Firestore
        const depositRef = await admin.firestore().collection('deposits').add({
            uid: req.user.uid,
            amount,
            method,
            status: 'pending',
            createdAt: new Date()
        });

        // Send payment link or request via UPI/Paytm
        await sendPaymentRequest(method, amount, depositRef.id);

        // Notify admin
        await notifyAdmin(`Deposit request from user ${req.user.uid} - ₹${amount} via ${method}`);

        res.json({ message: 'Deposit request submitted', depositId: depositRef.id });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Withdraw request
router.post('/withdraw', async (req, res) => {
    try {
        const { amount, upiId } = req.body;
        if (!amount || amount <= 0 || !upiId) {
            return res.status(400).json({ error: 'Invalid request' });
        }

        const userRef = admin.firestore().collection('users').doc(req.user.uid);
        const userDoc = await userRef.get();
        if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });

        const balance = userDoc.data().walletBalance || 0;
        if (balance < amount) {
            return res.status(400).json({ error: 'Insufficient balance' });
        }

        // Deduct amount
        await userRef.update({
            walletBalance: balance - amount
        });

        // Record withdrawal
        await admin.firestore().collection('withdrawals').add({
            uid: req.user.uid,
            amount,
            upiId,
            status: 'pending',
            createdAt: new Date()
        });

        // Notify admin
        await notifyAdmin(`Withdrawal request from user ${req.user.uid} - ₹${amount} to ${upiId}`);

        res.json({ message: 'Withdrawal request submitted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
