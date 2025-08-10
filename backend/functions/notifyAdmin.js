const { sendTelegramMessage } = require('../utils/telegram');

/**
 * Notify admin(s) about an event.
 * @param {string} message - Message to send to admin.
 */
async function notifyAdmin(message) {
    try {
        const adminChatId = process.env.TELEGRAM_ADMIN_CHAT_ID;
        if (!adminChatId) {
            console.warn('TELEGRAM_ADMIN_CHAT_ID not set in environment');
            return;
        }
        await sendTelegramMessage(message, adminChatId);
    } catch (err) {
        console.error('Error notifying admin:', err.message);
    }
}

module.exports = { notifyAdmin };
