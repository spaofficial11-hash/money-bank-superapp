/**
 * backend/routes/withdrawals.js
 * Handles withdrawals via UPI & Bank
 */

const express = require('express');
const router = express.Router();
const { db } = require('../utils/firebase');
const { logActivity } = require('../utils/logger');

const MIN_WITHDRAW = 110;
const MAX_WITHDRAW = 50000;

// 📌 Create Withdrawal Request
router.post('/create', async (req, res) => {
  try {
    const { uid, amount, method, account } = req.body;

    if (amount < MIN_WITHDRAW || amount > MAX_WITHDRAW) {
      return res.status(400).json({ error: `Amount must be between ₹${MIN_WITHDRAW} and ₹${MAX_WITHDRAW}` });
    }

    if (!["upi", "bank"].includes(method)) {
      return res.status(400).json({ error: "Invalid withdrawal method" });
    }

    const userDoc = await db.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = userDoc.data();
    if (user.balance < amount) {
      return res.status(400).json({ error: "Insufficient balance" });
    }

    // Deduct balance
    await db.collection('users').doc(uid).update({
      balance: user.balance - amount
    });

    // Save withdrawal request
    const withdrawalRef = await db.collection('withdrawals').add({
      uid,
      amount,
      method,
      account,
      status: "pending",
      createdAt: new Date().toISOString()
    });

    await logActivity("withdrawal_request", `Withdrawal request ₹${amount}`, uid);

    res.json({
      message: "Withdrawal request created",
      withdrawalId: withdrawalRef.id
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// 📌 Approve Withdrawal (Admin)
router.post('/approve', async (req, res) => {
  try {
    const { withdrawalId } = req.body;

    const withdrawalDoc = await db.collection('withdrawals').doc(withdrawalId).get();
    if (!withdrawalDoc.exists) {
      return res.status(404).json({ error: "Withdrawal not found" });
    }

    const withdrawal = withdrawalDoc.data();
    if (withdrawal.status !== "pending") {
      return res.status(400).json({ error: "Already processed" });
    }

    // Mark withdrawal as completed
    await db.collection('withdrawals').doc(withdrawalId).update({
      status: "completed",
      completedAt: new Date().toISOString()
    });

    await logActivity("withdrawal_approved", `Withdrawal approved ₹${withdrawal.amount}`, withdrawal.uid);

    res.json({ message: "Withdrawal approved successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
