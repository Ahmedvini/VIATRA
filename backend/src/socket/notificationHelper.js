import admin from 'firebase-admin';
import * as presenceService from '../services/presenceService.js';
import { User } from '../models/index.js';
import logger from '../config/logger.js';

// Initialize Firebase Admin SDK
let firebaseInitialized = false;

const initializeFirebase = () => {
  if (firebaseInitialized) return;
  
  try {
    const serviceAccount = {
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL
    };
    
    if (!serviceAccount.projectId || !serviceAccount.privateKey || !serviceAccount.clientEmail) {
      logger.warn('Firebase credentials not configured. Push notifications disabled.');
      return;
    }
    
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    
    firebaseInitialized = true;
    logger.info('Firebase Admin SDK initialized successfully');
  } catch (error) {
    logger.error('Error initializing Firebase Admin SDK:', error);
  }
};

/**
 * Send push notification for a new message
 * @param {string} recipientUserId - UUID of recipient user
 * @param {string} senderName - Display name of message sender
 * @param {string} messagePreview - Preview text of the message
 * @param {string} conversationId - UUID of the conversation
 * @param {string} messageId - UUID of the message
 * @returns {Promise<boolean>} Success status
 */
export const sendMessageNotification = async (
  recipientUserId,
  senderName,
  messagePreview,
  conversationId,
  messageId
) => {
  try {
    // Initialize Firebase if not already done
    if (!firebaseInitialized) {
      initializeFirebase();
    }
    
    if (!firebaseInitialized) {
      logger.debug('Firebase not initialized, skipping notification');
      return false;
    }
    
    // Check if recipient is online
    const isOnline = await presenceService.getUserPresence(recipientUserId);
    if (isOnline) {
      logger.debug(`User ${recipientUserId} is online, skipping push notification`);
      return false;
    }
    
    // Get recipient's FCM token
    const recipient = await User.findByPk(recipientUserId, {
      attributes: ['id', 'fcm_token']
    });
    
    if (!recipient || !recipient.fcm_token) {
      logger.debug(`No FCM token for user ${recipientUserId}`);
      return false;
    }
    
    // Construct FCM notification payload
    const message = {
      token: recipient.fcm_token,
      notification: {
        title: senderName,
        body: messagePreview.length > 100 
          ? `${messagePreview.substring(0, 97)}...` 
          : messagePreview
      },
      data: {
        type: 'chat_message',
        conversationId: conversationId,
        messageId: messageId,
        senderId: senderName
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'chat_messages',
          sound: 'default',
          priority: 'high'
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1
          }
        }
      }
    };
    
    // Send notification
    const response = await admin.messaging().send(message);
    
    logger.info(`Push notification sent to user ${recipientUserId}`, {
      response,
      conversationId,
      messageId
    });
    
    return true;
  } catch (error) {
    // Handle specific FCM errors
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      logger.warn(`Invalid FCM token for user ${recipientUserId}, clearing token`);
      
      // Clear invalid token from database
      try {
        await User.update(
          { fcm_token: null },
          { where: { id: recipientUserId } }
        );
      } catch (updateError) {
        logger.error('Error clearing invalid FCM token:', updateError);
      }
    } else {
      logger.error('Error sending push notification:', error);
    }
    
    return false;
  }
};

/**
 * Send notification when appointment is updated
 * This can be expanded for other notification types
 * @param {string} userId - UUID of user to notify
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @param {Object} data - Additional data payload
 * @returns {Promise<boolean>} Success status
 */
export const sendNotification = async (userId, title, body, data = {}) => {
  try {
    if (!firebaseInitialized) {
      initializeFirebase();
    }
    
    if (!firebaseInitialized) {
      return false;
    }
    
    const user = await User.findByPk(userId, {
      attributes: ['id', 'fcm_token']
    });
    
    if (!user || !user.fcm_token) {
      return false;
    }
    
    const message = {
      token: user.fcm_token,
      notification: { title, body },
      data: {
        ...data,
        timestamp: new Date().toISOString()
      }
    };
    
    await admin.messaging().send(message);
    logger.info(`Notification sent to user ${userId}`);
    
    return true;
  } catch (error) {
    logger.error('Error sending notification:', error);
    return false;
  }
};
