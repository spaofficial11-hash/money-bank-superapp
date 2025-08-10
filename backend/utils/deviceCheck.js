/**
 * backend/utils/deviceCheck.js
 * Device verification utility
 */

const { db } = require('./firebase');

/**
 * Verify if user is logging in from the same device
 */
async function verifyDevice(uid, currentDeviceId) {
  const userRef = db.collection('users').doc(uid);
  const doc = await userRef.get();

  if (!doc.exists) return false;

  const data = doc.data();
  if (!data.deviceId) {
    // First time login, save deviceId
    await userRef.update({ deviceId: currentDeviceId });
    return true;
  }

  return data.deviceId === currentDeviceId;
}

module.exports = { verifyDevice };
