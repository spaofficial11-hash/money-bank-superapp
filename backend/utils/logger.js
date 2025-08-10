/**
 * backend/utils/logger.js
 * Logs user activities, admin actions, and payments
 */

const { db } = require('./firebase');

/**
 * Save a log entry in Firestore
 * @param {string} type - log type ("login", "payment", "withdraw", "admin_action")
 * @param {string} message - log description
 * @param {string} uid - user ID (optional for admin logs)
 */
async function logActivity(type, message, uid = null) {
  try {
    await db.collection('logs').add({
      type,
      message,
      uid,
      createdAt: new Date().toISOString()
    });
  } catch (err) {
    console.error("Failed to log activity:", err);
  }
}

module.exports = { logActivity };
