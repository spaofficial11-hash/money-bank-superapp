/**
 * backend/routes/auth.js
 * User registration & login routes for Money Bank
 */

const express = require('express');
const router = express.Router();
const { auth, db } = require('../utils/firebase');
const { verifyDevice } = require('../utils/deviceCheck');
const { logActivity } = require('../utils/logger');

// 📌 Register user
router.post('/register', async (req, res) => {
  try {
    const { name, email, phone, password, deviceId } = req.body;

    if (!name || !phone || !password) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Create Firebase Auth user (email optional)
    const userRecord = await auth.createUser({
      email: email || undefined,
      phoneNumber: `+91${phone}`,
      password: password,
      displayName: name
    });

    // Save in Firestore
    await db.collection('users').doc(userRecord.uid).set({
      name,
      email: email || null,
      phone,
      deviceId,
      balance: 0,
      createdAt: new Date().toISOString()
    });

    await logActivity("register", `${name} registered`, userRecord.uid);

    res.json({ message: "User registered successfully", uid: userRecord.uid });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// 📌 Login user
router.post('/login', async (req, res) => {
  try {
    const { phone, password, deviceId } = req.body;

    // Find user by phone
    const userSnapshot = await db.collection('users').where('phone', '==', phone).get();
    if (userSnapshot.empty) {
      return res.status(404).json({ error: "User not found" });
    }

    const userData = userSnapshot.docs[0].data();
    const uid = userSnapshot.docs[0].id;

    // Device check
    const deviceOk = await verifyDevice(uid, deviceId);
    if (!deviceOk) {
      return res.status(403).json({ error: "Device not authorized" });
    }

    await logActivity("login", `User ${phone} logged in`, uid);
    res.json({ message: "Login successful", uid });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
