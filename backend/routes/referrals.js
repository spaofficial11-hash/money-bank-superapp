/**
 * backend/routes/referrals.js
 * Handles referral and bonus system
 */

const express = require('express');
const router = express.Router();
const { db } = require('../utils/firebase');
const { logActivity } = require('../utils/logger');

// Referral bonus amounts (₹1 = 1 coin)
const BONUS_FOR_REFERRER = 20; // For inviting
const BONUS_FOR_NEW_USER = 10; // For joining via code

/**
 * 📌 Apply referral code for new user
 */
router.post('/apply', async (req, res) => {
  try {
    const { uid, referralCode, deviceId } = req.body;

    if (!referralCode) {
      return res.status(400).json({ error: "Referral code is required" });
    }

    // Check if user already applied a code
    const userRef = db.collection('users').doc(uid);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" });
    }
    if (userDoc.data().referralApplied) {
      return res.status(400).json({ error: "Referral already applied" });
    }

    // Prevent fraud: check if same deviceId already used
    const fraudCheck = await db.collection('users').where('deviceId', '==', deviceId).get();
    if (fraudCheck.size > 1) {
      return res.status(403).json({ error: "Multiple accounts from same device detected" });
    }

    // Find referrer by referralCode
    const referrerSnapshot = await db.collection('users')
      .where('myReferralCode', '==', referralCode)
      .limit(1)
      .get();

    if (referrerSnapshot.empty) {
      return res.status(404).json({ error: "Invalid referral code" });
    }

    const referrerDoc = referrerSnapshot.docs[0];
    const referrerId = referrerDoc.id;

    // Update new user's balance
    const newUserBalance = (userDoc.data().balance || 0) + BONUS_FOR_NEW_USER;
    await userRef.update({
      balance: newUserBalance,
      referralApplied: true,
      referredBy: referrerId
    });

    // Update referrer's balance
    const referrerBalance = (referrerDoc.data().balance || 0) + BONUS_FOR_REFERRER;
    await db.collection('users').doc(referrerId).update({
      balance: referrerBalance
    });

    // Save referral history
    await db.collection('referrals').add({
      referrer: referrerId,
      newUser: uid,
      bonusToReferrer: BONUS_FOR_REFERRER,
      bonusToNewUser: BONUS_FOR_NEW_USER,
      createdAt: new Date().toISOString()
    });

    await logActivity("referral_applied", `User ${uid} applied code from ${referrerId}`);

    res.json({
      message: "Referral applied successfully",
      newUserBonus: BONUS_FOR_NEW_USER,
      referrerBonus: BONUS_FOR_REFERRER,
      balance: newUserBalance
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * 📌 Get referral history for a user
 */
router.get('/history/:uid', async (req, res) => {
  try {
    const { uid } = req.params;
    const history = [];

    const snapshot = await db.collection('referrals')
      .where('referrer', '==', uid)
      .orderBy('createdAt', 'desc')
      .get();

    snapshot.forEach(doc => {
      history.push({ id: doc.id, ...doc.data() });
    });

    res.json(history);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
