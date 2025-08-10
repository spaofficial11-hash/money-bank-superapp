/**
 * backend/routes/users.js
 * Handles user registration, login & admin controls
 */

const express = require('express');
const router = express.Router();
const { db } = require('../utils/firebase');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { logActivity } = require('../utils/logger');

// JWT secret (change in production)
const JWT_SECRET = "super_secret_key";

// 📌 Register
router.post('/register', async (req, res) => {
  try {
    const { name, mobile, email, password, deviceId } = req.body;

    if (!mobile || !email || !password) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Check if mobile/email already exists
    const existingUser = await db.collection('users')
      .where('mobile', '==', mobile)
      .get();

    if (!existingUser.empty) {
      return res.status(400).json({ error: "Mobile already registered" });
    }

    const emailCheck = await db.collection('users')
      .where('email', '==', email)
      .get();

    if (!emailCheck.empty) {
      return res.status(400).json({ error: "Email already registered" });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Save user
    const userRef = await db.collection('users').add({
      name,
      mobile,
      email,
      password: hashedPassword,
      deviceId,
      balance: 0,
      createdAt: new Date().toISOString(),
      isAdmin: false
    });

    await logActivity("user_register", `New user registered ${name}`, userRef.id);

    res.json({ message: "User registered successfully", userId: userRef.id });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// 📌 Login
router.post('/login', async (req, res) => {
  try {
    const { mobile, password, deviceId } = req.body;

    const userSnapshot = await db.collection('users')
      .where('mobile', '==', mobile)
      .get();

    if (userSnapshot.empty) {
      return res.status(400).json({ error: "User not found" });
    }

    const userDoc = userSnapshot.docs[0];
    const user = userDoc.data();

    // Verify password
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    // Device verification
    if (user.deviceId && user.deviceId !== deviceId) {
      return res.status(403).json({ error: "Device not recognized" });
    }

    // Create token
    const token = jwt.sign({ uid: userDoc.id, isAdmin: user.isAdmin }, JWT_SECRET, { expiresIn: '7d' });

    res.json({
      message: "Login successful",
      token,
      uid: userDoc.id,
      name: user.name,
      balance: user.balance,
      isAdmin: user.isAdmin
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// 📌 Admin: Get all users
router.get('/all', async (req, res) => {
  try {
    const users = [];
    const snapshot = await db.collection('users').get();

    snapshot.forEach(doc => {
      users.push({ id: doc.id, ...doc.data() });
    });

    res.json(users);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
