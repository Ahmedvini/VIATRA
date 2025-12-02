# Password Hashing Verification for VIATRA

## Summary
✅ **CONFIRMED**: VIATRA backend uses **bcrypt with 12 rounds** for password hashing.

## Evidence from Code

### Backend User Model (`/backend/src/models/User.js`)

```javascript
import bcrypt from 'bcrypt';

// Line 11-13: Password verification
async checkPassword(password) {
  return bcrypt.compare(password, this.password_hash);
}

// Line 93: Password hashing with 12 rounds
user.password_hash = await bcrypt.hash(user.password_hash, 12);
```

### Key Points:

1. **Library**: `bcrypt` npm package
2. **Salt Rounds**: 12 (higher than the default 10 for better security)
3. **Automatic**: Happens in `beforeCreate` and `beforeUpdate` hooks
4. **Storage**: Stored in `users.password_hash` column

## SQL Implementation

### PostgreSQL/Supabase Equivalent

To create a password hash that matches the backend:

```sql
-- Enable pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Hash password with bcrypt (12 rounds)
crypt('your_password_here', gen_salt('bf', 12))
```

Where:
- `'bf'` = Blowfish cipher (bcrypt algorithm)
- `12` = salt rounds (must match backend)

### Example:

```sql
INSERT INTO users (email, password_hash, ...)
VALUES (
    'test@example.com',
    crypt('TestPassword123!', gen_salt('bf', 12)),
    ...
);
```

## Verification

### How to Test if Password is Correct:

```sql
-- This will return true if password matches
SELECT crypt('TestPassword123!', password_hash) = password_hash
FROM users
WHERE email = 'testpatient@viatra.com';
```

### Backend Login Flow:

1. User submits email + password
2. Backend finds user by email
3. Calls `user.checkPassword(password)`
4. bcrypt.compare() checks if password matches hash
5. Returns true/false

## Test Patient Credentials

### For Testing:
- **Email**: `testpatient@viatra.com`
- **Password**: `TestPatient123!`
- **Hashing**: bcrypt with 12 rounds

### SQL to Create:
```sql
INSERT INTO users (id, email, password_hash, first_name, last_name, role)
VALUES (
    gen_random_uuid(),
    'testpatient@viatra.com',
    crypt('TestPatient123!', gen_salt('bf', 12)),
    'Test',
    'Patient',
    'patient'
);
```

## Why bcrypt with 12 rounds?

1. **Security**: Higher rounds = more CPU time = harder to crack
2. **Balance**: 12 rounds is a good balance between security and performance
3. **Industry Standard**: Commonly used in production applications
4. **Future-proof**: Can be increased as hardware gets faster

## Common Issues

### Issue 1: Password not working after SQL insert
**Cause**: Used wrong hashing algorithm or rounds
**Solution**: Use `crypt('password', gen_salt('bf', 12))`

### Issue 2: pgcrypto extension not found
**Cause**: Extension not enabled in PostgreSQL
**Solution**: Run `CREATE EXTENSION IF NOT EXISTS pgcrypto;`

### Issue 3: Password works in SQL but not in app
**Cause**: Mismatch between SQL rounds and backend rounds
**Solution**: Ensure both use 12 rounds

## Testing Checklist

- [ ] pgcrypto extension enabled
- [ ] Password hashed with bcrypt (bf) algorithm
- [ ] Using 12 salt rounds
- [ ] Can verify password with SQL query
- [ ] Can login with mobile app
- [ ] Backend authentication works

## References

- Backend: `/backend/src/models/User.js`
- SQL Script: `/CREATE_TEST_PATIENT_VERIFIED.sql`
- bcrypt npm: https://www.npmjs.com/package/bcrypt
- PostgreSQL pgcrypto: https://www.postgresql.org/docs/current/pgcrypto.html
