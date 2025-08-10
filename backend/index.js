/**
 * backend/index.js
 * Main Express server for Money Bank backend (Telegram + Firebase ready)
 *
 * NOTE: Set environment variables from `.env` / deployment platform before running.
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const firebase = require('./firebase'); // exports { admin, db, auth } — next file will define it
const telegramUtil = require('./utils/telegram'); // helper to process incoming telegram updates

// Route modules (will be provided one-by-one)
const authRoutes = require('./routes/auth');
const walletRoutes = require('./routes/wallet');
const adminRoutes = require('./routes/admin');
const chatRoutes = require('./routes/chat');
const mlmRoutes = require('./routes/referral');

const app = express();

// middlewares
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// simple health check
app.get('/health', (req, res) => {
  res.json({ ok: true, env: process.env.NODE_ENV || 'development', time: new Date().toISOString() });
});

/**
 * Mount API routes
 * (These route files will be sent next in serial order)
 */
app.use('/api/auth', authRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/referral', mlmRoutes);

/**
 * Telegram webhook endpoint
 * When you set webhook with Telegram, set the secret token (optional) so we can verify.
 * Telegram uses header: 'X-Telegram-Bot-Api-Secret-Token' when secret_token is set.
 */
app.post('/telegram/webhook', async (req, res) => {
  try {
    const secret = process.env.TELEGRAM_WEBHOOK_SECRET;
    if (secret) {
      const incomingSecret = req.headers['x-telegram-bot-api-secret-token'];
      if (!incomingSecret || incomingSecret !== secret) {
        console.warn('Telegram webhook secret mismatch');
        return res.status(403).send('forbidden');
      }
    }

    const update = req.body;
    // delegate processing to utils/telegram
    await telegramUtil.handleIncomingUpdate(update);
    return res.status(200).send('ok');
  } catch (err) {
    console.error('Error processing telegram webhook:', err);
    return res.status(500).send('error');
  }
});

// fallback 404
app.use((req, res) => res.status(404).json({ error: 'Not found' }));

// global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Server error' });
});

// start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Money Bank backend listening on port ${PORT}`);
});
