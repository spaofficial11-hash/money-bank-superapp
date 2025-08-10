/**
 * backend/utils/telegram.js
 * Telegram Bot integration for Money Bank live chat & admin notifications
 */

const axios = require('axios');

const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN; // BotFather se lo
const ADMIN_CHAT_ID = process.env.TELEGRAM_ADMIN_CHAT_ID; // Telegram @user_id

if (!TELEGRAM_BOT_TOKEN || !ADMIN_CHAT_ID) {
  console.warn("⚠️ Telegram bot env vars missing. Set TELEGRAM_BOT_TOKEN & TELEGRAM_ADMIN_CHAT_ID.");
}

/**
 * Send message to a specific Telegram chat
 * @param {string} chatId 
 * @param {string} message 
 */
async function sendMessage(chatId, message) {
  try {
    await axios.post(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
      chat_id: chatId,
      text: message,
      parse_mode: "HTML"
    });
  } catch (err) {
    console.error("❌ Telegram sendMessage error:", err.response?.data || err.message);
  }
}

/**
 * Send admin notification
 * @param {string} message 
 */
async function notifyAdmin(message) {
  return sendMessage(ADMIN_CHAT_ID, `📢 <b>Money Bank Alert</b>\n${message}`);
}

/**
 * Handle user message (can be expanded for chatbot logic)
 */
async function handleUserMessage(chatId, text) {
  if (text.toLowerCase() === "hi" || text.toLowerCase() === "hello") {
    return sendMessage(chatId, "👋 Welcome to Money Bank! How can I help you?");
  }

  if (text.toLowerCase().includes("balance")) {
    return sendMessage(chatId, "💰 Please login to the app to check your wallet balance.");
  }

  // Default reply
  return sendMessage(chatId, "🤖 I am your Money Bank assistant. Type 'help' for options.");
}

module.exports = { sendMessage, notifyAdmin, handleUserMessage };
