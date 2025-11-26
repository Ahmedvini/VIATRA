import express from 'express';
import authRoutes from './auth.js';
import verificationRoutes from './verification.js';
import healthProfileRoutes from './healthProfile.js';

const router = express.Router();

// API version and health check
router.get('/', (req, res) => {
  res.status(200).json({
    message: 'Viatra Health Platform API v1',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    endpoints: {
      authentication: '/auth',
      verification: '/verification',
      healthProfiles: '/health-profiles'
    },
    documentation: {
      auth: {
        register: 'POST /auth/register',
        login: 'POST /auth/login',
        logout: 'POST /auth/logout',
        refreshToken: 'POST /auth/refresh-token',
        verifyEmail: 'POST /auth/verify-email',
        requestPasswordReset: 'POST /auth/request-password-reset',
        resetPassword: 'POST /auth/reset-password',
        getCurrentUser: 'GET /auth/me',
        validateToken: 'GET /auth/validate-token'
      },
      verification: {
        submitDocument: 'POST /verification/submit',
        getDocumentStatus: 'GET /verification/document/:documentId',
        getUserStatus: 'GET /verification/status',
        updateDocumentStatus: 'PATCH /verification/document/:documentId/status (Admin)',
        resendEmail: 'POST /verification/resend-email',
        getPending: 'GET /verification/pending (Admin)',
        bulkUpdate: 'POST /verification/bulk-update (Admin)',
        getStats: 'GET /verification/stats (Admin)'
      },
      healthProfiles: {
        getMyProfile: 'GET /health-profiles/me',
        createProfile: 'POST /health-profiles',
        updateProfile: 'PATCH /health-profiles/me',
        addChronicCondition: 'POST /health-profiles/me/chronic-conditions',
        removeChronicCondition: 'DELETE /health-profiles/me/chronic-conditions/:conditionId',
        addAllergy: 'POST /health-profiles/me/allergies',
        removeAllergy: 'DELETE /health-profiles/me/allergies/:allergen',
        updateVitals: 'PATCH /health-profiles/me/vitals'
      }
    },
    rateLimits: {
      global: 'Varies by endpoint',
      auth: {
        register: '3 per hour',
        login: '5 per 15 minutes',
        passwordReset: '3 per hour',
        emailVerification: '3 per 5 minutes',
        tokenRefresh: '10 per 5 minutes'
      },
      verification: {
        documentUpload: '10 per hour',
        resendEmail: '2 per 15 minutes',
        adminActions: '50 per 5 minutes'
      },
      healthProfile: {
        allEndpoints: '10 per minute'
      }
    }
  });
});

// Mount route modules
router.use('/auth', authRoutes);
router.use('/verification', verificationRoutes);
router.use('/health-profiles', healthProfileRoutes);

// API status endpoint
router.get('/status', (req, res) => {
  res.status(200).json({
    status: 'operational',
    services: {
      authentication: 'available',
      verification: 'available',
      database: 'connected',
      redis: 'connected',
      storage: 'available'
    },
    timestamp: new Date().toISOString()
  });
});

// Feature availability endpoint
router.get('/features', (req, res) => {
  res.status(200).json({
    features: {
      multiRoleRegistration: true,
      jwtAuthentication: true,
      emailVerification: true,
      passwordReset: true,
      documentVerification: true,
      fileUpload: true,
      adminPanel: true,
      rateLimiting: true,
      sessionManagement: true,
      rbac: true, // Role-based access control
      healthProfileManagement: true
    },
    supportedRoles: ['patient', 'doctor', 'admin'],
    supportedDocumentTypes: [
      'medical_license',
      'board_certification',
      'education_certificate',
      'identification',
      'malpractice_insurance'
    ],
    supportedFileTypes: [
      'image/jpeg',
      'image/png',
      'application/pdf'
    ],
    maxFileSize: '10MB'
  });
});

// API limits endpoint
router.get('/limits', (req, res) => {
  res.status(200).json({
    rateLimits: {
      description: 'Rate limits are applied per IP address',
      limits: {
        'POST /auth/register': {
          requests: 3,
          window: '1 hour',
          resetTime: '60 minutes'
        },
        'POST /auth/login': {
          requests: 5,
          window: '15 minutes',
          resetTime: '15 minutes',
          note: 'Only failed attempts count'
        },
        'POST /auth/request-password-reset': {
          requests: 3,
          window: '1 hour',
          resetTime: '60 minutes'
        },
        'POST /auth/verify-email': {
          requests: 3,
          window: '5 minutes',
          resetTime: '5 minutes'
        },
        'POST /auth/refresh-token': {
          requests: 10,
          window: '5 minutes',
          resetTime: '5 minutes'
        },
        'POST /verification/submit': {
          requests: 10,
          window: '1 hour',
          resetTime: '60 minutes'
        },
        'POST /verification/resend-email': {
          requests: 2,
          window: '15 minutes',
          resetTime: '15 minutes'
        },
        'Admin endpoints': {
          requests: 50,
          window: '5 minutes',
          resetTime: '5 minutes'
        }
      }
    },
    fileLimits: {
      maxFileSize: '10MB',
      allowedTypes: ['image/jpeg', 'image/png', 'application/pdf'],
      maxFilesPerUpload: 1,
      storageBackend: 'Google Cloud Storage'
    },
    dataLimits: {
      maxRequestBodySize: '10MB',
      maxUrlLength: '2048 characters',
      maxHeaderSize: '8KB'
    }
  });
});

export default router;
