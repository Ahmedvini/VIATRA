# Development Guide

This document provides comprehensive guidelines for developing the Viatra Health Platform, including setup, coding standards, workflows, and best practices.

## Getting Started

### Prerequisites

Ensure you have the following installed:
- **Node.js** 20+ and npm 9+
- **Flutter SDK** 3.x+
- **Git** with SSH keys configured
- **Docker** and Docker Compose
- **Google Cloud CLI** (for cloud development)
- **Code Editor**: VS Code (recommended) with extensions

### Recommended VS Code Extensions

```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "dart-code.flutter",
    "dart-code.dart-code",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "hashicorp.terraform",
    "ms-vscode-remote.remote-containers",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint"
  ]
}
```

### Development Environment Setup

#### 1. Initial Setup
```bash
# Clone the repository
git clone <repository-url>
cd viatra-platform

# Run setup script
chmod +x scripts/setup.sh
./scripts/setup.sh

# Start development environment
npm run docker:up
```

#### 2. Local Development with Docker Compose

The project includes a Docker Compose setup for local development:

```yaml
# Services included:
- PostgreSQL database
- Redis cache
- Backend API (with hot reload)
- pgAdmin (database management)
- Redis Commander (cache management)
```

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Reset volumes (fresh start)
docker-compose down -v
```

#### 3. Native Development (without Docker)

If you prefer running services natively:

```bash
# Install backend dependencies
cd backend
npm install

# Install mobile dependencies  
cd ../mobile
flutter pub get

# Start backend in development mode
cd ../backend
npm run dev

# Start mobile app
cd ../mobile
flutter run
```

## Project Structure

### Repository Organization
```
viatra-platform/
├── backend/                 # Node.js API server
│   ├── src/                # Source code
│   ├── tests/              # Test files
│   ├── package.json        # Dependencies
│   └── Dockerfile          # Container config
├── mobile/                 # Flutter mobile app
│   ├── lib/                # Dart source code
│   ├── test/               # Test files
│   ├── android/            # Android config
│   ├── ios/                # iOS config
│   └── pubspec.yaml        # Flutter config
├── terraform/              # Infrastructure code
├── scripts/               # Utility scripts
├── docs/                  # Documentation
├── .github/               # GitHub workflows
└── docker-compose.yml     # Local development
```

### Backend Structure
```
backend/src/
├── config/                # Configuration files
│   ├── index.js           # Main config
│   ├── database.js        # DB connection
│   ├── redis.js           # Redis connection
│   └── logger.js          # Logging setup
├── middleware/            # Express middleware
├── routes/               # API routes
├── controllers/          # Business logic
├── models/              # Data models
├── services/            # External integrations
├── utils/               # Helper functions
└── index.js             # Application entry
```

### Mobile Structure
```
mobile/lib/
├── config/              # App configuration
├── models/             # Data models
├── services/           # API clients
├── providers/          # State management
├── screens/            # UI screens
├── widgets/            # Reusable widgets
├── utils/              # Helper functions
├── l10n/               # Localization
└── main.dart           # App entry point
```

## Development Workflow

### Git Workflow

#### Branch Strategy
```
main            # Production-ready code
├── develop     # Development integration
├── staging     # Staging/pre-production
├── feature/*   # Feature branches
├── bugfix/*    # Bug fix branches
└── hotfix/*    # Production hotfixes
```

#### Branch Naming
- **Features**: `feature/user-authentication`
- **Bug fixes**: `bugfix/login-error-handling`
- **Hotfixes**: `hotfix/security-patch-2024-01`

#### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add JWT token refresh mechanism

- Implement automatic token refresh
- Add refresh token storage
- Handle expired token scenarios

Closes #123
```

### Development Process

#### 1. Starting a New Feature
```bash
# Create and switch to feature branch
git checkout -b feature/appointment-booking

# Make your changes
# ... development work ...

# Commit changes
git add .
git commit -m "feat(appointments): add booking functionality"

# Push branch
git push origin feature/appointment-booking

# Create pull request
```

#### 2. Code Review Process
1. **Self-review**: Check your own code before submitting
2. **Automated checks**: Ensure CI passes (tests, linting, security)
3. **Peer review**: At least one team member reviews
4. **Testing**: Manual testing of new features
5. **Documentation**: Update docs if needed

#### 3. Merging Strategy
- **Feature branches**: Squash and merge to develop
- **Develop to staging**: Regular merge
- **Staging to main**: Merge after testing
- **Hotfixes**: Cherry-pick to main and develop

## Coding Standards

### Backend (Node.js/JavaScript)

#### Style Guide
- **ESLint**: Follow the configured ESLint rules
- **Prettier**: Auto-format code on save
- **Naming**: camelCase for variables, PascalCase for classes
- **File naming**: kebab-case for files

#### Code Organization
```javascript
// File structure template
import dependencies from 'external-packages';
import localModules from './local-modules';

// Constants
const CONSTANTS = 'VALUES';

// Main functionality
class ServiceClass {
  constructor() {
    // Constructor logic
  }
  
  async publicMethod() {
    // Public method logic
  }
  
  _privateMethod() {
    // Private method logic (prefix with _)
  }
}

// Export
export default ServiceClass;
```

#### Error Handling
```javascript
// Use async/await with try-catch
async function serviceFunction() {
  try {
    const result = await externalService.call();
    return result;
  } catch (error) {
    logger.error('Service function failed:', error);
    throw new ServiceError('Operation failed', error);
  }
}

// Custom error classes
class ServiceError extends Error {
  constructor(message, originalError) {
    super(message);
    this.name = 'ServiceError';
    this.originalError = originalError;
  }
}
```

#### Database Queries
```javascript
// Use parameterized queries to prevent SQL injection
const getUserById = async (userId) => {
  const query = 'SELECT * FROM users WHERE id = $1';
  const result = await db.query(query, [userId]);
  return result.rows[0];
};

// Use transactions for multiple operations
const createUserWithProfile = async (userData, profileData) => {
  return await db.transaction(async (client) => {
    const user = await client.query(
      'INSERT INTO users (email, password) VALUES ($1, $2) RETURNING id',
      [userData.email, userData.password]
    );
    
    await client.query(
      'INSERT INTO profiles (user_id, name) VALUES ($1, $2)',
      [user.rows[0].id, profileData.name]
    );
    
    return user.rows[0];
  });
};
```

### Mobile (Flutter/Dart)

#### Style Guide
- **Dart Style**: Follow official Dart style guide
- **Flutter Lints**: Use flutter_lints package
- **Naming**: camelCase for variables, PascalCase for classes
- **File naming**: snake_case for files

#### Widget Organization
```dart
// Widget structure template
class MyCustomWidget extends StatelessWidget {
  const MyCustomWidget({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8.0),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
```

#### State Management
```dart
// Provider pattern example
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    
    try {
      final user = await _authService.login(email, password);
      _user = user;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

#### Error Handling
```dart
// Centralized error handling
class ErrorHandler {
  static void handleError(Object error, [StackTrace? stackTrace]) {
    Logger.error('Application error: $error', stackTrace);
    
    if (error is NetworkException) {
      _showNetworkError();
    } else if (error is ValidationException) {
      _showValidationError(error.message);
    } else {
      _showGenericError();
    }
  }
  
  static void _showNetworkError() {
    // Show network error to user
  }
  
  static void _showValidationError(String message) {
    // Show validation error to user
  }
  
  static void _showGenericError() {
    // Show generic error to user
  }
}
```

## Testing Strategy

### Backend Testing

#### Unit Tests
```javascript
// Example unit test
import { describe, it, expect, beforeEach, afterEach } from '@jest/globals';
import UserService from '../src/services/UserService.js';
import { mockDatabase } from './mocks/database.js';

describe('UserService', () => {
  let userService;

  beforeEach(() => {
    userService = new UserService(mockDatabase);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('createUser', () => {
    it('should create a user successfully', async () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        password: 'password123'
      };
      
      mockDatabase.query.mockResolvedValue({
        rows: [{ id: 1, ...userData }]
      });

      // Act
      const result = await userService.createUser(userData);

      // Assert
      expect(result).toEqual(expect.objectContaining({
        id: 1,
        email: userData.email
      }));
      expect(mockDatabase.query).toHaveBeenCalledTimes(1);
    });

    it('should throw error for duplicate email', async () => {
      // Arrange
      const userData = {
        email: 'duplicate@example.com',
        password: 'password123'
      };
      
      mockDatabase.query.mockRejectedValue(
        new Error('duplicate key value violates unique constraint')
      );

      // Act & Assert
      await expect(userService.createUser(userData))
        .rejects
        .toThrow('Email already exists');
    });
  });
});
```

#### Integration Tests
```javascript
// Example integration test
import request from 'supertest';
import app from '../src/index.js';
import { setupTestDB, cleanupTestDB } from './helpers/database.js';

describe('Auth API', () => {
  beforeAll(async () => {
    await setupTestDB();
  });

  afterAll(async () => {
    await cleanupTestDB();
  });

  describe('POST /api/v1/auth/register', () => {
    it('should register a new user', async () => {
      const userData = {
        email: 'newuser@example.com',
        password: 'password123',
        name: 'New User'
      };

      const response = await request(app)
        .post('/api/v1/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body).toEqual(
        expect.objectContaining({
          user: expect.objectContaining({
            email: userData.email,
            name: userData.name
          }),
          token: expect.any(String)
        })
      );
    });
  });
});
```

### Mobile Testing

#### Widget Tests
```dart
// Example widget test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viatra_mobile/widgets/login_form.dart';

void main() {
  group('LoginForm Widget Tests', () {
    testWidgets('should display login form elements', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onLogin: (email, password) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should validate empty fields', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onLogin: (email, password) {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
```

#### Unit Tests for Business Logic
```dart
// Example unit test for provider
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viatra_mobile/providers/auth_provider.dart';
import 'package:viatra_mobile/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      authProvider = AuthProvider(apiService: mockApiService);
    });

    test('login should update user state on success', () async {
      // Arrange
      final user = User(id: '1', email: 'test@example.com');
      when(mockApiService.login(any, any))
          .thenAnswer((_) async => user);

      // Act
      await authProvider.login('test@example.com', 'password');

      // Assert
      expect(authProvider.user, equals(user));
      expect(authProvider.isLoggedIn, isTrue);
    });

    test('login should handle errors gracefully', () async {
      // Arrange
      when(mockApiService.login(any, any))
          .thenThrow(ApiException('Invalid credentials'));

      // Act & Assert
      expect(
        () => authProvider.login('test@example.com', 'wrong'),
        throwsA(isA<ApiException>()),
      );
      expect(authProvider.user, isNull);
      expect(authProvider.isLoggedIn, isFalse);
    });
  });
}
```

### Running Tests

```bash
# Backend tests
cd backend
npm test                    # Run all tests
npm run test:watch         # Run tests in watch mode
npm run test:coverage      # Generate coverage report

# Mobile tests
cd mobile
flutter test               # Run all tests
flutter test --coverage   # Generate coverage report
flutter test test/unit/    # Run specific directory
```

## Performance Guidelines

### Backend Performance

#### Database Optimization
```javascript
// Use database indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);

// Optimize queries
// ❌ Bad: N+1 query problem
const users = await User.findAll();
for (const user of users) {
  const profile = await Profile.findByUserId(user.id);
}

// ✅ Good: Use joins or eager loading
const usersWithProfiles = await db.query(`
  SELECT u.*, p.name, p.avatar
  FROM users u
  LEFT JOIN profiles p ON u.id = p.user_id
`);
```

#### Caching Strategy
```javascript
// Cache frequently accessed data
const getCachedUser = async (userId) => {
  const cacheKey = `user:${userId}`;
  let user = await redis.get(cacheKey);
  
  if (!user) {
    user = await db.getUserById(userId);
    await redis.setex(cacheKey, 300, JSON.stringify(user)); // 5 min cache
  } else {
    user = JSON.parse(user);
  }
  
  return user;
};
```

#### API Response Optimization
```javascript
// Implement pagination
const getUsers = async (page = 1, limit = 20) => {
  const offset = (page - 1) * limit;
  const users = await db.query(
    'SELECT * FROM users LIMIT $1 OFFSET $2',
    [limit, offset]
  );
  
  const total = await db.query('SELECT COUNT(*) FROM users');
  
  return {
    users: users.rows,
    pagination: {
      page,
      limit,
      total: parseInt(total.rows[0].count),
      totalPages: Math.ceil(total.rows[0].count / limit)
    }
  };
};
```

### Mobile Performance

#### Widget Performance
```dart
// Use const constructors
const MyWidget({super.key});

// Optimize ListView for large datasets
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
    );
  },
);

// Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ComplexCustomPainter(),
);
```

#### Image Optimization
```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  width: 200,
  height: 200,
  fit: BoxFit.cover,
);

// Optimize image sizes
Image.network(
  'https://example.com/image.jpg',
  width: 100,
  height: 100,
  cacheWidth: 100, // Resize during caching
  cacheHeight: 100,
);
```

## Security Guidelines

### Backend Security

#### Input Validation
```javascript
import Joi from 'joi';

// Validate all inputs
const userSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required(),
  name: Joi.string().min(2).max(50).required()
});

const validateUser = (userData) => {
  const { error, value } = userSchema.validate(userData);
  if (error) {
    throw new ValidationError(error.details[0].message);
  }
  return value;
};
```

#### Authentication & Authorization
```javascript
// JWT middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

// Role-based authorization
const requireRole = (role) => {
  return (req, res, next) => {
    if (!req.user || req.user.role !== role) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
};
```

### Mobile Security

#### Secure Storage
```dart
// Use flutter_secure_storage for sensitive data
class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

#### Certificate Pinning
```dart
// Implement certificate pinning for API calls
class ApiService {
  static Dio createDio() {
    final dio = Dio();
    
    if (!kDebugMode) {
      dio.interceptors.add(
        CertificatePinningInterceptor(
          allowedSHAFingerprints: ['SHA256:your-cert-fingerprint'],
        ),
      );
    }
    
    return dio;
  }
}
```

## Debugging Guidelines

### Backend Debugging

#### Logging Best Practices
```javascript
import logger from './config/logger.js';

// Structured logging
logger.info('User login attempt', {
  userId: user.id,
  email: user.email,
  userAgent: req.get('User-Agent'),
  ip: req.ip
});

// Error logging with context
try {
  await processPayment(paymentData);
} catch (error) {
  logger.error('Payment processing failed', {
    error: error.message,
    stack: error.stack,
    paymentId: paymentData.id,
    userId: user.id
  });
  throw error;
}
```

#### Performance Monitoring
```javascript
// Monitor slow operations
const performanceMonitor = (operation) => {
  return async (req, res, next) => {
    const start = Date.now();
    
    await next();
    
    const duration = Date.now() - start;
    if (duration > 1000) { // Log slow requests
      logger.warn('Slow operation detected', {
        operation,
        duration: `${duration}ms`,
        path: req.path,
        method: req.method
      });
    }
  };
};
```

### Mobile Debugging

#### Debug Tools
```dart
// Performance overlay in debug mode
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: kDebugMode && false, // Enable when needed
      home: HomeScreen(),
    );
  }
}

// Logging service
class Logger {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        message,
        error: error,
        stackTrace: stackTrace,
        level: Level.FINE.value,
      );
    }
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      error: error,
      stackTrace: stackTrace,
      level: Level.SEVERE.value,
    );
    
    // Send to crash reporting service in production
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }
}
```

## Deployment and CI/CD

### Pre-deployment Checklist
- [ ] All tests pass
- [ ] Code review completed
- [ ] Security scan passed  
- [ ] Performance impact assessed
- [ ] Documentation updated
- [ ] Database migrations ready
- [ ] Environment variables configured
- [ ] Monitoring alerts configured

### Deployment Process
1. **Merge to develop**: Triggers staging deployment
2. **Testing on staging**: Manual and automated testing
3. **Merge to main**: Triggers production deployment
4. **Post-deployment verification**: Health checks and monitoring

This development guide provides the foundation for consistent, high-quality development of the Viatra Health Platform. Regular updates ensure it remains current with best practices and team needs.
