const admin = require('../firebase');

/**
 * Auto wallet credit after payment confirmation.
 * @param {string} uid - User ID to credit wallet.
 * @param {number} amount - Amount to credit.
 */
async function updateWallet(uid, amount) {
    try {
        if (!uid || !amount || amount <= 0) {
            throw new Error('Invalid wallet update parameters');
        }

        await admin.firestore().collection('users').doc(uid).update({
            walletBalance: admin.firestore.FieldValue.increment(amount)
        });

        await admin.firestore().collection('transactions').add({
            uid,
            amount,
            type: 'credit',
            createdAt: new Date()
        });

        console.log(`Wallet credited: ₹${amount} to ${uid}`);
    } catch (err) {
        console.error('Error updating wallet:', err.message);
    }
}

module.exports = { updateWallet };
