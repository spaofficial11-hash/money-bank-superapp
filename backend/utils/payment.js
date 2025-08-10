/**
 * backend/utils/payment.js
 * Payment utilities for Money Bank (Paytm, PhonePe, GPay, etc.)
 */

const Razorpay = require('razorpay');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET
});

/**
 * Create a Razorpay order
 */
async function createOrder(amount, receipt) {
  return await razorpay.orders.create({
    amount: amount * 100, // INR to paise
    currency: 'INR',
    receipt,
  });
}

/**
 * Verify Razorpay signature
 */
function verifySignature(orderId, paymentId, signature) {
  const crypto = require('crypto');
  const expectedSignature = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(orderId + "|" + paymentId)
    .digest('hex');

  return expectedSignature === signature;
}

module.exports = { createOrder, verifySignature };
