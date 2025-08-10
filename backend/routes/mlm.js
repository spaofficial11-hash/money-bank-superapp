const express = require('express');
const router = express.Router();
const admin = require('../firebase');
const { verifyToken } = require('../utils/deviceVerify');

// 📌 Middleware for authentication
router.use((req, res, next) => {
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

// 📌 Link referral code when new user registers
router.post('/link-referral', async (req, res) => {
    try {
        const { referralCode } = req.body;
        if (!referralCode) return res.status(400).json({ error: 'Referral code is required' });

        const usersRef = admin.firestore().collection('users');
        const refSnapshot = await usersRef.where('refCode', '==', referralCode).limit(1).get();

        if (refSnapshot.empty) {
            return res.status(404).json({ error: 'Referral code not found' });
        }

        const referrerDoc = refSnapshot.docs[0];
        const referrerId = referrerDoc.id;

        // Update current user's record
        await usersRef.doc(req.user.uid).update({
            referredBy: referrerId
        });

        // Add to referrer’s downline
        await usersRef.doc(referrerId).collection('downline').doc(req.user.uid).set({
            uid: req.user.uid,
            joinedAt: new Date()
        });

        res.json({ message: 'Referral linked successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Get MLM network (direct referrals)
router.get('/network', async (req, res) => {
    try {
        const downlineSnapshot = await admin.firestore()
            .collection('users')
            .doc(req.user.uid)
            .collection('downline')
            .get();

        const downline = downlineSnapshot.docs.map(doc => doc.data());
        res.json({ downline });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Commission payout after deposit
router.post('/distribute-commission', async (req, res) => {
    try {
        const { depositAmount } = req.body;
        if (!depositAmount || depositAmount <= 0) {
            return res.status(400).json({ error: 'Invalid deposit amount' });
        }

        const userDoc = await admin.firestore().collection('users').doc(req.user.uid).get();
        if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });

        const referrerId = userDoc.data().referredBy;
        if (!referrerId) {
            return res.json({ message: 'No referrer linked' });
        }

        // Example: 10% commission to referrer
        const commission = depositAmount * 0.1;

        await admin.firestore().collection('users').doc(referrerId).update({
            walletBalance: admin.firestore.FieldValue.increment(commission)
        });

        // Record commission transaction
        await admin.firestore().collection('commissions').add({
            from: req.user.uid,
            to: referrerId,
            amount: commission,
            createdAt: new Date()
        });

        res.json({ message: `Commission of ₹${commission} credited to referrer` });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
