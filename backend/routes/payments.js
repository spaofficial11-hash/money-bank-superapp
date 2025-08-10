/**
 * backend/routes/payments.js
 * Handles deposits via multiple payment options
 */

const express = require('express');
const router = express.Router();
const { db } = require('../utils/firebase');
const { createOrder } = require('../utils/payment');
const { logActivity } = require('../utils/logger');

// 📌 Allowed deposit amounts
const ALLOWED_AMOUNTS = [100, 300, 500, 1000, 2000, 5000, 10000, 30000, 50000];

// 📌 Create Deposit Request
router.post('/deposit', async (req, res) => {
  try {
    const { uid, amount, method } = req.body;

    if (!ALLOWED_AMOUNTS.includes(amount)) {
      return res.status(400).json({ error: "Invalid deposit amount" });
    }

    if (!["paytm", "phonepe", "gpay", "navi", "others"].includes(method)) {
      return res.status(400).json({ error: "Invalid payment method" });
    }

    // Admin commission fetch
    const adminConfig = await db.collection('admin').doc('settings').get();
    const commission = adminConfig.exists ? adminConfig.data().depositCommission || 0 : 0;

    const netAmount = amount - (amount * commission / 100);

    // Create Razorpay order (if online payment)
    const order = await createOrder(amount, `${method.toUpperCase()} Deposit`);

    // Save deposit request
    const depositRef = await db.collection('deposits').add({
      uid,
      amount,
      method,
      commission,
      netAmount,
      orderId: order ? order.id : null,
      status: "pending",
      createdAt: new Date().toISOString()
    });

    await logActivity("deposit_request", `Deposit ${amount} via ${method}`, uid);

    res.json({
      message: "Deposit request created",
      depositId: depositRef.id,
      order
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// 📌 Approve Deposit (Admin)
router.post('/approve', async (req, res) => {
  try {
    const { depositId } = req.body;

    const depositDoc = await db.collection('deposits').doc(depositId).get();
    if (!depositDoc.exists) {
      return res.status(404).json({ error: "Deposit not found" });
    }

    const deposit = depositDoc.data();
    if (deposit.status !== "pending") {
      return res.status(400).json({ error: "Already processed" });
    }

    // Update user balance
    const userRef = db.collection('users').doc(deposit.uid);
    await userRef.update({
      balance: db.FieldValue.increment(deposit.netAmount)
    });

    // Mark deposit as completed
    await db.collection('deposits').doc(depositId).update({
      status: "completed",
      completedAt: new Date().toISOString()
    });

    await logActivity("deposit_approved", `Deposit approved: ₹${deposit.amount}`, deposit.uid);

    res.json({ message: "Deposit approved successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
