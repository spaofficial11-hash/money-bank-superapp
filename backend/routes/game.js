/**
 * backend/routes/game.js
 * Handles the 30-second round system & game logic
 */

const express = require('express');
const router = express.Router();
const { db } = require('../utils/firebase');
const { logActivity } = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

const ROUND_DURATION = 30000; // 30 seconds

/**
 * 📌 Auto-create a new round
 * (You will also set this with setInterval in server.js)
 */
async function createNewRound() {
  const roundId = uuidv4();
  const roundRef = db.collection('rounds').doc(roundId);

  await roundRef.set({
    roundId,
    status: 'running',
    bets: [],
    result: null,
    createdAt: new Date().toISOString(),
    endAt: new Date(Date.now() + ROUND_DURATION).toISOString()
  });

  console.log(`✅ New round started: ${roundId}`);
  await logActivity("round_created", `Round ${roundId} started`);

  // Auto end after 30s
  setTimeout(() => endRound(roundId), ROUND_DURATION);
}

/**
 * 📌 End a round and calculate winners
 */
async function endRound(roundId) {
  const roundRef = db.collection('rounds').doc(roundId);
  const roundDoc = await roundRef.get();
  if (!roundDoc.exists) return;

  const roundData = roundDoc.data();

  // If result not set by admin, auto pick random
  let finalResult = roundData.result;
  if (!finalResult) {
    const colors = ["RED", "GREEN", "BLUE", "YELLOW"];
    finalResult = colors[Math.floor(Math.random() * colors.length)];
  }

  // Update round with result
  await roundRef.update({
    result: finalResult,
    status: 'ended'
  });

  // Calculate winnings
  for (const bet of roundData.bets) {
    const userRef = db.collection('users').doc(bet.userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) continue;

    let newBalance = userDoc.data().balance || 0;
    if (bet.color === finalResult) {
      // Win = 2x coins
      newBalance += bet.amount * 2;
    }

    await userRef.update({ balance: newBalance });
  }

  await logActivity("round_ended", `Round ${roundId} ended with result ${finalResult}`);
  console.log(`🏁 Round ${roundId} ended with result ${finalResult}`);

  // Start new round immediately
  createNewRound();
}

/**
 * 📌 User places a bet
 */
router.post('/bet', async (req, res) => {
  try {
    const { userId, roundId, color, amount } = req.body;

    if (!["RED", "GREEN", "BLUE", "YELLOW"].includes(color)) {
      return res.status(400).json({ error: "Invalid color" });
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" });
    }

    const userBalance = userDoc.data().balance || 0;
    if (userBalance < amount) {
      return res.status(400).json({ error: "Insufficient balance" });
    }

    // Deduct bet amount
    await userRef.update({ balance: userBalance - amount });

    // Save bet in round
    const roundRef = db.collection('rounds').doc(roundId);
    await roundRef.update({
      bets: admin.firestore.FieldValue.arrayUnion({
        userId,
        color,
        amount
      })
    });

    await logActivity("bet_placed", `User ${userId} bet ${amount} on ${color} in ${roundId}`);
    res.json({ message: "Bet placed successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * 📌 Admin sets result manually
 */
router.post('/set-result', async (req, res) => {
  try {
    const { roundId, result } = req.body;

    if (!["RED", "GREEN", "BLUE", "YELLOW"].includes(result)) {
      return res.status(400).json({ error: "Invalid result" });
    }

    const roundRef = db.collection('rounds').doc(roundId);
    await roundRef.update({ result });

    res.json({ message: "Result updated successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = { router, createNewRound };
