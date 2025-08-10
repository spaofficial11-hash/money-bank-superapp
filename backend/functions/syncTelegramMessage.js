const admin = require('../firebase');

/**
 * Sync Telegram messages to Firestore chat collection.
 * This can be called when Telegram webhook receives a message.
 * @param {string} uid - User ID in our system.
 * @param {string} text - Message text from Telegram.
 * @param {boolean} fromAdmin - Whether the message is from admin.
 */
async function syncTelegramMessage(uid, text, fromAdmin = true) {
    try {
        if (!uid || !text) {
            throw new Error('Invalid Telegram sync parameters');
        }

        await admin.firestore()
            .collection('chats')
            .doc(uid)
            .collection('messages')
            .add({
                sender: fromAdmin ? 'admin' : uid,
                text,
                createdAt: new Date(),
                fromAdmin
            });

        console.log(`Synced Telegram message for ${uid}: ${text}`);
    } catch (err) {
        console.error('Error syncing Telegram message:', err.message);
    }
}

module.exports = { syncTelegramMessage };
