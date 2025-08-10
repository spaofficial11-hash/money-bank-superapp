const express = require('express');
const router = express.Router();
const admin = require('../firebase');
const { verifyToken } = require('../utils/deviceVerify');
const { notifyAdmin } = require('../functions/notifyAdmin');

// 📌 Middleware to check if user is admin
router.use((req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'No token provided' });

    try {
        const decoded = verifyToken(token);
        req.user = decoded;

        // Check if admin
        const adminEmails = (process.env.ADMIN_EMAILS || '').split(',');
        if (!adminEmails.includes(req.user.email)) {
            return res.status(403).json({ error: 'Access denied' });
        }

        next();
    } catch (err) {
        res.status(401).json({ error: 'Invalid token' });
    }
});

// 📌 Get all deposit requests
router.get('/deposits', async (req, res) => {
    try {
        const snapshot = await admin.firestore()
            .collection('deposits')
            .orderBy('createdAt', 'desc')
            .get();

        const deposits = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json({ deposits });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Approve deposit
router.post('/deposits/:id/approve', async (req, res) => {
    try {
        const depositId = req.params.id;
        const depositRef = admin.firestore().collection('deposits').doc(depositId);
        const depositDoc = await depositRef.get();

        if (!depositDoc.exists) return res.status(404).json({ error: 'Deposit not found' });

        const { uid, amount } = depositDoc.data();

        // Update user wallet
        await admin.firestore().collection('users').doc(uid).update({
            walletBalance: admin.firestore.FieldValue.increment(amount)
        });

        // Mark deposit as approved
        await depositRef.update({ status: 'approved', approvedAt: new Date() });

        res.json({ message: 'Deposit approved and wallet updated' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Reject deposit
router.post('/deposits/:id/reject', async (req, res) => {
    try {
        const depositId = req.params.id;
        const depositRef = admin.firestore().collection('deposits').doc(depositId);
        const depositDoc = await depositRef.get();

        if (!depositDoc.exists) return res.status(404).json({ error: 'Deposit not found' });

        await depositRef.update({ status: 'rejected', rejectedAt: new Date() });
        res.json({ message: 'Deposit rejected' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Get all withdrawal requests
router.get('/withdrawals', async (req, res) => {
    try {
        const snapshot = await admin.firestore()
            .collection('withdrawals')
            .orderBy('createdAt', 'desc')
            .get();

        const withdrawals = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json({ withdrawals });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Approve withdrawal
router.post('/withdrawals/:id/approve', async (req, res) => {
    try {
        const withdrawalId = req.params.id;
        const withdrawalRef = admin.firestore().collection('withdrawals').doc(withdrawalId);
        const withdrawalDoc = await withdrawalRef.get();

        if (!withdrawalDoc.exists) return res.status(404).json({ error: 'Withdrawal not found' });

        await withdrawalRef.update({ status: 'approved', approvedAt: new Date() });
        res.json({ message: 'Withdrawal approved' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Reject withdrawal
router.post('/withdrawals/:id/reject', async (req, res) => {
    try {
        const withdrawalId = req.params.id;
        const withdrawalRef = admin.firestore().collection('withdrawals').doc(withdrawalId);
        const withdrawalDoc = await withdrawalRef.get();

        if (!withdrawalDoc.exists) return res.status(404).json({ error: 'Withdrawal not found' });

        // Refund amount back to user
        const { uid, amount } = withdrawalDoc.data();
        await admin.firestore().collection('users').doc(uid).update({
            walletBalance: admin.firestore.FieldValue.increment(amount)
        });

        await withdrawalRef.update({ status: 'rejected', rejectedAt: new Date() });
        res.json({ message: 'Withdrawal rejected and amount refunded' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
