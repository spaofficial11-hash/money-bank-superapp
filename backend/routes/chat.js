const express = require('express');
const router = express.Router();
const admin = require('../firebase');
const { verifyToken } = require('../utils/deviceVerify');
const { sendTelegramMessage } = require('../utils/telegram');

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

// 📌 Get chat history (last 50 messages)
router.get('/', async (req, res) => {
    try {
        const snapshot = await admin.firestore()
            .collection('chats')
            .doc(req.user.uid)
            .collection('messages')
            .orderBy('createdAt', 'desc')
            .limit(50)
            .get();

        const messages = snapshot.docs.map(doc => doc.data());
        res.json({ messages: messages.reverse() }); // oldest first
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Send new message
router.post('/', async (req, res) => {
    try {
        const { text } = req.body;
        if (!text) return res.status(400).json({ error: 'Message text is required' });

        const msgData = {
            sender: req.user.uid,
            text,
            createdAt: new Date(),
            fromAdmin: false
        };

        // Store in Firestore
        await admin.firestore()
            .collection('chats')
            .doc(req.user.uid)
            .collection('messages')
            .add(msgData);

        // Notify admin via Telegram
        await sendTelegramMessage(`💬 New message from ${req.user.uid}: ${text}`);

        res.json({ message: 'Message sent' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 📌 Admin sends message to user (optional webhook)
router.post('/admin-reply', async (req, res) => {
    try {
        const { uid, text } = req.body;
        if (!uid || !text) return res.status(400).json({ error: 'uid and text required' });

        const msgData = {
            sender: 'admin',
            text,
            createdAt: new Date(),
            fromAdmin: true
        };

        await admin.firestore()
            .collection('chats')
            .doc(uid)
            .collection('messages')
            .add(msgData);

        res.json({ message: 'Reply sent to user' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
