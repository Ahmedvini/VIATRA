import express from 'express';
import multer from 'multer';
import {
  createFoodLog,
  analyzeFoodImage,
  getFoodLogs,
  getFoodLogById,
  updateFoodLog,
  deleteFoodLog,
  getNutritionSummary
} from '../controllers/foodTrackingController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// Configure multer for image upload (memory storage for direct processing)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// All routes require authentication
router.use(authenticate);

// POST /api/health/food - Create food log (manual entry)
router.post('/', createFoodLog);

// POST /api/health/food/analyze - Analyze food image and create log
router.post('/analyze', upload.single('image'), analyzeFoodImage);

// GET /api/health/food - Get all food logs for user
router.get('/', getFoodLogs);

// GET /api/health/food/summary - Get nutrition summary
router.get('/summary', getNutritionSummary);

// GET /api/health/food/:id - Get single food log
router.get('/:id', getFoodLogById);

// PUT /api/health/food/:id - Update food log
router.put('/:id', updateFoodLog);

// DELETE /api/health/food/:id - Delete food log
router.delete('/:id', deleteFoodLog);

export default router;
