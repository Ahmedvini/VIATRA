import { Storage } from '@google-cloud/storage';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import logger from '../config/logger.js';

// Only initialize Storage if credentials are configured
let storage = null;
const bucketName = process.env.GCS_BUCKET_NAME || 'viatra-storage';

try {
  if (process.env.GCS_BUCKET_NAME && process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    storage = new Storage();
    logger.info('Google Cloud Storage initialized');
  } else {
    logger.warn('GCS credentials not configured, using placeholder URLs for file uploads');
  }
} catch (error) {
  logger.warn('Failed to initialize GCS, using placeholder URLs:', error.message);
  storage = null;
}

/**
 * Upload file to Google Cloud Storage
 * @param {Object} file - Multer file object
 * @param {string} folder - Folder name in bucket
 * @returns {Promise<string>} - Public URL of uploaded file
 */
export const uploadToStorage = async (file, folder = 'uploads') => {
  try {
    // For development/testing without GCS, return a placeholder URL
    if (!storage || !process.env.GCS_BUCKET_NAME) {
      const placeholderUrl = `https://via.placeholder.com/400x300.png?text=${encodeURIComponent(file.originalname)}`;
      logger.warn(`GCS not configured, using placeholder URL: ${placeholderUrl}`);
      return placeholderUrl;
    }

    const bucket = storage.bucket(bucketName);
    const filename = `${folder}/${uuidv4()}${path.extname(file.originalname)}`;
    const blob = bucket.file(filename);

    const blobStream = blob.createWriteStream({
      resumable: false,
      metadata: {
        contentType: file.mimetype
      }
    });

    return new Promise((resolve, reject) => {
      blobStream.on('error', (error) => {
        logger.error('Storage upload error:', error);
        reject(error);
      });

      blobStream.on('finish', () => {
        const publicUrl = `https://storage.googleapis.com/${bucketName}/${filename}`;
        logger.info(`File uploaded: ${publicUrl}`);
        resolve(publicUrl);
      });

      blobStream.end(file.buffer);
    });
  } catch (error) {
    logger.error('Failed to upload to storage:', error);
    throw error;
  }
};

/**
 * Delete file from Google Cloud Storage
 * @param {string} fileUrl - Public URL of file to delete
 */
export const deleteFromStorage = async (fileUrl) => {
  try {
    if (!storage || !process.env.GCS_BUCKET_NAME) {
      logger.warn('GCS not configured, skipping delete');
      return;
    }

    const bucket = storage.bucket(bucketName);
    const filename = fileUrl.split(`/${bucketName}/`)[1];
    
    if (filename) {
      await bucket.file(filename).delete();
      logger.info(`File deleted: ${filename}`);
    }
  } catch (error) {
    logger.error('Failed to delete from storage:', error);
    // Don't throw - deletion failure shouldn't break the app
  }
};
