import multer from 'multer';
import { Storage } from '@google-cloud/storage';
import { v4 as uuidv4 } from 'uuid';
import path from 'path';
import config from '../config/index.js';
import logger from '../config/logger.js';

// Initialize Google Cloud Storage
const storage = new Storage({
  projectId: config.gcp.projectId
});

const bucket = storage.bucket(config.gcp.bucketName);

/**
 * Configure multer for memory storage
 */
const multerStorage = multer.memoryStorage();

/**
 * File filter for allowed MIME types
 */
const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'application/pdf'
  ];
  
  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPEG, PNG, and PDF files are allowed.'), false);
  }
};

/**
 * Generate unique filename
 * @param {string} originalName - Original filename
 * @param {string} type - Document type
 * @returns {string} - Unique filename
 */
const generateUniqueFilename = (originalName, type = 'document') => {
  const timestamp = Date.now();
  const uuid = uuidv4();
  const extension = path.extname(originalName).toLowerCase();
  return `verification-documents/${type}/${timestamp}-${uuid}${extension}`;
};

/**
 * Upload file to Google Cloud Storage
 * @param {Buffer} fileBuffer - File buffer
 * @param {string} filename - Destination filename
 * @param {string} mimetype - File MIME type
 * @returns {Promise<string>} - Public URL of uploaded file
 */
const uploadToGCS = async (fileBuffer, filename, mimetype) => {
  try {
    const file = bucket.file(filename);
    
    const stream = file.createWriteStream({
      metadata: {
        contentType: mimetype,
        cacheControl: 'public, max-age=31536000', // 1 year cache
      },
      resumable: false
    });
    
    return new Promise((resolve, reject) => {
      stream.on('error', (error) => {
        logger.error('GCS upload error:', error);
        reject(new Error('File upload failed'));
      });
      
      stream.on('finish', async () => {
        try {
          // Make the file public
          await file.makePublic();
          
          // Return public URL
          const publicUrl = `https://storage.googleapis.com/${config.gcp.bucketName}/${filename}`;
          
          logger.info('File uploaded successfully to GCS', {
            filename: filename,
            size: fileBuffer.length,
            mimetype: mimetype
          });
          
          resolve(publicUrl);
        } catch (error) {
          logger.error('Error making file public:', error);
          reject(new Error('File upload completed but failed to make public'));
        }
      });
      
      stream.end(fileBuffer);
    });
  } catch (error) {
    logger.error('GCS upload setup error:', error);
    throw new Error('File upload initialization failed');
  }
};

/**
 * Multer configuration for single file upload
 */
export const uploadSingle = (fieldName = 'document') => {
  const upload = multer({
    storage: multerStorage,
    fileFilter: fileFilter,
    limits: {
      fileSize: config.upload.maxSize, // From config
      files: 1
    }
  }).single(fieldName);
  
  return (req, res, next) => {
    upload(req, res, (error) => {
      if (error instanceof multer.MulterError) {
        if (error.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({
            error: 'File too large',
            message: `File size cannot exceed ${config.upload.maxSize / 1024 / 1024}MB`
          });
        }
        return res.status(400).json({
          error: 'Upload error',
          message: error.message
        });
      } else if (error) {
        return res.status(400).json({
          error: 'Invalid file',
          message: error.message
        });
      }
      
      if (!req.file) {
        return res.status(400).json({
          error: 'No file uploaded',
          message: 'Please select a file to upload'
        });
      }
      
      next();
    });
  };
};

/**
 * Multer configuration for multiple file upload
 */
export const uploadMultiple = (fieldName = 'documents', maxCount = 5) => {
  const upload = multer({
    storage: multerStorage,
    fileFilter: fileFilter,
    limits: {
      fileSize: config.upload.maxSize,
      files: maxCount
    }
  }).array(fieldName, maxCount);
  
  return (req, res, next) => {
    upload(req, res, (error) => {
      if (error instanceof multer.MulterError) {
        if (error.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({
            error: 'File too large',
            message: `File size cannot exceed ${config.upload.maxSize / 1024 / 1024}MB`
          });
        } else if (error.code === 'LIMIT_FILE_COUNT') {
          return res.status(400).json({
            error: 'Too many files',
            message: `Cannot upload more than ${maxCount} files`
          });
        }
        return res.status(400).json({
          error: 'Upload error',
          message: error.message
        });
      } else if (error) {
        return res.status(400).json({
          error: 'Invalid file',
          message: error.message
        });
      }
      
      if (!req.files || req.files.length === 0) {
        return res.status(400).json({
          error: 'No files uploaded',
          message: 'Please select at least one file to upload'
        });
      }
      
      next();
    });
  };
};

/**
 * Upload single file to GCS
 * @param {Object} file - Multer file object
 * @param {string} documentType - Type of document
 * @returns {Promise<string>} - Public URL of uploaded file
 */
export const uploadFileToGCS = async (file, documentType = 'verification') => {
  try {
    const filename = generateUniqueFilename(file.originalname, documentType);
    const publicUrl = await uploadToGCS(file.buffer, filename, file.mimetype);
    
    return {
      url: publicUrl,
      filename: filename,
      originalName: file.originalname,
      size: file.size,
      mimetype: file.mimetype
    };
  } catch (error) {
    logger.error('File upload error:', error);
    throw error;
  }
};

/**
 * Upload multiple files to GCS
 * @param {Array} files - Array of Multer file objects
 * @param {string} documentType - Type of documents
 * @returns {Promise<Array>} - Array of upload results
 */
export const uploadFilesToGCS = async (files, documentType = 'verification') => {
  try {
    const uploadPromises = files.map(file => uploadFileToGCS(file, documentType));
    return await Promise.all(uploadPromises);
  } catch (error) {
    logger.error('Multiple files upload error:', error);
    throw error;
  }
};

/**
 * Delete file from GCS
 * @param {string} filename - Filename in GCS
 * @returns {Promise<boolean>} - Success status
 */
export const deleteFileFromGCS = async (filename) => {
  try {
    const file = bucket.file(filename);
    await file.delete();
    
    logger.info('File deleted successfully from GCS', {
      filename: filename
    });
    
    return true;
  } catch (error) {
    logger.error('File deletion error:', error);
    return false;
  }
};

/**
 * Check if file exists in GCS
 * @param {string} filename - Filename in GCS
 * @returns {Promise<boolean>} - Existence status
 */
export const checkFileExists = async (filename) => {
  try {
    const file = bucket.file(filename);
    const [exists] = await file.exists();
    return exists;
  } catch (error) {
    logger.error('File existence check error:', error);
    return false;
  }
};

/**
 * Get file metadata from GCS
 * @param {string} filename - Filename in GCS
 * @returns {Promise<Object>} - File metadata
 */
export const getFileMetadata = async (filename) => {
  try {
    const file = bucket.file(filename);
    const [metadata] = await file.getMetadata();
    
    return {
      name: metadata.name,
      size: metadata.size,
      contentType: metadata.contentType,
      created: metadata.timeCreated,
      updated: metadata.updated,
      md5Hash: metadata.md5Hash
    };
  } catch (error) {
    logger.error('File metadata error:', error);
    throw new Error('Failed to get file metadata');
  }
};
