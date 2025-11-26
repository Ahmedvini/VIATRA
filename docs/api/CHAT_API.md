# Chat API Documentation

## Overview

This document describes the complete Chat API for the VIATRA Health Platform, including REST endpoints, Socket.io events, request/response formats, and real-time communication patterns.

**Last Updated:** January 2025  
**API Version:** v1  
**Base URL:** `/api/v1/chat`

---

## Table of Contents

1. [Authentication](#authentication)
2. [REST API Endpoints](#rest-api-endpoints)
3. [Socket.io Events](#socketio-events)
4. [Data Models](#data-models)
5. [Error Handling](#error-handling)
6. [Best Practices](#best-practices)

---

## Authentication

All API endpoints and Socket.io connections require authentication using JWT tokens.

### REST API
Include the JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

### Socket.io
The JWT token is automatically included from the authentication context. Ensure the user is authenticated before initializing the socket connection.

---

## REST API Endpoints

### 1. Get Conversations

**Endpoint:** `GET /api/v1/chat/conversations`

**Description:** Retrieve all conversations for the authenticated user.

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)

**Response:**
```json
{
  "status": "success",
  "data": {
    "conversations": [
      {
        "id": "uuid",
        "participantIds": ["userId1", "userId2"],
        "lastMessage": {
          "id": "uuid",
          "content": "Hello",
          "senderId": "userId1",
          "messageType": "text",
          "createdAt": "2025-01-15T10:00:00Z"
        },
        "unreadCount": 5,
        "participants": [
          {
            "id": "userId1",
            "name": "John Doe",
            "profilePicture": "url"
          }
        ],
        "createdAt": "2025-01-15T09:00:00Z",
        "updatedAt": "2025-01-15T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "pages": 3
    }
  }
}
```

---

### 2. Create Conversation

**Endpoint:** `POST /api/v1/chat/conversations`

**Description:** Create a new conversation with specified participants.

**Request Body:**
```json
{
  "participantIds": ["userId1", "userId2"],
  "initialMessage": "Hello, let's chat!"
}
```

**Field Requirements:**
- `participantIds` (required): Array of user IDs (must include at least 2 participants including sender)
- `initialMessage` (optional): First message to send

**Response:**
```json
{
  "status": "success",
  "data": {
    "conversation": {
      "id": "uuid",
      "participantIds": ["userId1", "userId2"],
      "createdAt": "2025-01-15T10:00:00Z",
      "updatedAt": "2025-01-15T10:00:00Z"
    }
  }
}
```

---

### 3. Get Messages

**Endpoint:** `GET /api/v1/chat/conversations/:conversationId/messages`

**Description:** Retrieve messages from a specific conversation.

**Path Parameters:**
- `conversationId` (required): UUID of the conversation

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 50, max: 100)
- `before` (optional): Get messages before this message ID
- `after` (optional): Get messages after this message ID

**Response:**
```json
{
  "status": "success",
  "data": {
    "messages": [
      {
        "id": "uuid",
        "conversationId": "uuid",
        "senderId": "userId",
        "content": "Hello!",
        "messageType": "text",
        "status": "read",
        "readBy": {
          "userId1": "2025-01-15T10:05:00Z"
        },
        "deliveredTo": {
          "userId1": "2025-01-15T10:01:00Z"
        },
        "createdAt": "2025-01-15T10:00:00Z",
        "updatedAt": "2025-01-15T10:05:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 50,
      "total": 150,
      "pages": 3
    }
  }
}
```

---

### 4. Send Message

**Endpoint:** `POST /api/v1/chat/conversations/:conversationId/messages`

**Description:** Send a new message in a conversation.

**Path Parameters:**
- `conversationId` (required): UUID of the conversation

**Request Body:**
```json
{
  "content": "Hello, how are you?",
  "messageType": "text"
}
```

**Field Requirements:**
- `content` (required): Message content (1-5000 characters)
- `messageType` (required): Type of message
  - `text`: Plain text message
  - `image`: Image message (content should be image URL)
  - `file`: File attachment (content should be file URL)
  - `system`: System message (admin only)

**Response:**
```json
{
  "status": "success",
  "data": {
    "message": {
      "id": "uuid",
      "conversationId": "uuid",
      "senderId": "userId",
      "content": "Hello, how are you?",
      "messageType": "text",
      "status": "sent",
      "createdAt": "2025-01-15T10:00:00Z",
      "updatedAt": "2025-01-15T10:00:00Z"
    }
  }
}
```

**Real-time Behavior:**
- Server emits `new_message` event to all conversation participants via Socket.io
- Message is automatically cached in Redis
- Push notification sent to offline participants

---

### 5. Mark Messages as Read

**Endpoint:** `POST /api/v1/chat/conversations/:conversationId/read`

**Description:** Mark one or more messages as read by the authenticated user.

**Path Parameters:**
- `conversationId` (required): UUID of the conversation

**Request Body:**
```json
{
  "messageIds": ["messageId1", "messageId2"]
}
```

**Field Requirements:**
- `messageIds` (required): Array of message UUIDs to mark as read

**Response:**
```json
{
  "status": "success",
  "data": {
    "updatedCount": 2,
    "messages": [
      {
        "id": "messageId1",
        "status": "read",
        "readBy": {
          "userId": "2025-01-15T10:05:00Z"
        }
      }
    ]
  }
}
```

**Real-time Behavior:**
- Server emits `messages_read` event (batch) to conversation participants
- Server emits individual `message_read` events for each message
- Cache automatically updated for affected users

---

### 6. Delete Message

**Endpoint:** `DELETE /api/v1/chat/messages/:messageId`

**Description:** Delete a message (soft delete - marks as deleted but retains in database).

**Path Parameters:**
- `messageId` (required): UUID of the message

**Authorization:**
- Only the message sender can delete their own messages

**Response:**
```json
{
  "status": "success",
  "data": {
    "message": "Message deleted successfully"
  }
}
```

---

### 7. Register FCM Token

**Endpoint:** `POST /api/v1/auth/fcm-token`

**Description:** Register or update Firebase Cloud Messaging token for push notifications.

**Request Body:**
```json
{
  "fcmToken": "firebase-cloud-messaging-token",
  "deviceId": "unique-device-identifier",
  "platform": "android"
}
```

**Field Requirements:**
- `fcmToken` (required): FCM registration token
- `deviceId` (optional): Unique device identifier
- `platform` (optional): `android` or `ios`

**Response:**
```json
{
  "status": "success",
  "data": {
    "message": "FCM token registered successfully"
  }
}
```

---

## Socket.io Events

### Connection

**Namespace:** Default (`/`)

**Authentication:** Automatic via JWT in authentication context

**Connection Example (Mobile - Dart):**
```dart
_socket = io(
  apiUrl,
  OptionBuilder()
    .setTransports(['websocket'])
    .enableAutoConnect()
    .setAuth({'token': jwtToken})
    .build(),
);
```

---

### Client → Server Events

#### 1. join_conversation

**Description:** Join a conversation room to receive real-time updates.

**Payload:**
```json
{
  "conversationId": "uuid"
}
```

**Usage:**
- Emit when opening a conversation screen
- Required to receive real-time messages and status updates

---

#### 2. leave_conversation

**Description:** Leave a conversation room when no longer viewing it.

**Payload:**
```json
{
  "conversationId": "uuid"
}
```

**Usage:**
- Emit when leaving a conversation screen
- Stops receiving real-time updates for that conversation

---

#### 3. typing_start

**Description:** Notify other participants that the user is typing.

**Payload:**
```json
{
  "conversationId": "uuid"
}
```

**Usage:**
- Emit when user starts typing in a conversation
- Server broadcasts to other participants

---

#### 4. typing_stop

**Description:** Notify other participants that the user stopped typing.

**Payload:**
```json
{
  "conversationId": "uuid"
}
```

**Usage:**
- Emit when user stops typing or sends message
- Server broadcasts to other participants

---

#### 5. mark_delivered

**Description:** Mark messages as delivered to the client.

**Payload:**
```json
{
  "messageIds": ["messageId1", "messageId2"],
  "conversationId": "uuid"
}
```

**Usage:**
- Emit when messages are received and displayed on the client
- Server updates delivery status and notifies sender

---

### Server → Client Events

#### 1. new_message

**Description:** A new message was sent in a conversation.

**Payload:**
```json
{
  "message": {
    "id": "uuid",
    "conversationId": "uuid",
    "senderId": "userId",
    "content": "Hello!",
    "messageType": "text",
    "status": "sent",
    "createdAt": "2025-01-15T10:00:00Z",
    "updatedAt": "2025-01-15T10:00:00Z"
  }
}
```

**Trigger:**
- Emitted when any participant sends a message via REST API
- Broadcast to all conversation participants who are online

**Client Action:**
- Add message to local state
- Display in conversation UI
- Mark as delivered via `mark_delivered` event

---

#### 2. messages_read (Batch)

**Description:** Multiple messages were marked as read by a user.

**Payload:**
```json
{
  "conversationId": "uuid",
  "userId": "userId",
  "messageIds": ["messageId1", "messageId2"],
  "readAt": "2025-01-15T10:05:00Z"
}
```

**Trigger:**
- Emitted when a user marks messages as read via REST API
- Broadcast to all conversation participants

**Client Action:**
- Update message read status in local state
- Display read receipts in UI

---

#### 3. message_read (Individual)

**Description:** A single message was marked as read by a user.

**Payload:**
```json
{
  "messageId": "uuid",
  "conversationId": "uuid",
  "userId": "userId",
  "readAt": "2025-01-15T10:05:00Z"
}
```

**Trigger:**
- Emitted for each message when marked as read via REST API
- Broadcast to all conversation participants

**Client Action:**
- Update individual message read status
- Display read receipt for specific message

---

#### 4. message_delivered

**Description:** A message was delivered to a user's device.

**Payload:**
```json
{
  "messageId": "uuid",
  "conversationId": "uuid",
  "userId": "userId",
  "deliveredAt": "2025-01-15T10:01:00Z"
}
```

**Trigger:**
- Emitted when recipient marks message as delivered
- Broadcast to message sender

**Client Action:**
- Update message delivery status
- Display delivery indicator (single checkmark)

---

#### 5. user_typing

**Description:** A user in the conversation is typing.

**Payload:**
```json
{
  "conversationId": "uuid",
  "userId": "userId",
  "userName": "John Doe"
}
```

**Trigger:**
- Emitted when participant sends `typing_start` event
- Broadcast to other participants in conversation

**Client Action:**
- Display typing indicator in conversation UI
- Auto-hide after 3-5 seconds if no `typing_stop` received

---

#### 6. user_online

**Description:** A user came online (connected to socket).

**Payload:**
```json
{
  "userId": "userId"
}
```

**Trigger:**
- Emitted when user establishes socket connection
- Broadcast to all users who have conversations with this user

**Client Action:**
- Update user's online status in UI
- Show green indicator or "online" label

---

#### 7. user_offline

**Description:** A user went offline (disconnected from socket).

**Payload:**
```json
{
  "userId": "userId",
  "lastSeen": "2025-01-15T10:30:00Z"
}
```

**Trigger:**
- Emitted when user disconnects from socket
- Broadcast to all users who have conversations with this user

**Client Action:**
- Update user's online status in UI
- Show "last seen" timestamp

---

#### 8. error

**Description:** An error occurred during socket communication.

**Payload:**
```json
{
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

**Trigger:**
- Emitted when socket operation fails
- Sent only to the client that caused the error

**Client Action:**
- Display error message to user
- Log error for debugging
- Retry operation if appropriate

---

## Data Models

### Conversation

```typescript
{
  id: string (UUID)
  participantIds: string[] (array of user UUIDs)
  lastMessage?: {
    id: string
    content: string
    senderId: string
    messageType: 'text' | 'image' | 'file' | 'system'
    createdAt: string (ISO 8601)
  }
  unreadCount: number
  participants: User[]
  createdAt: string (ISO 8601)
  updatedAt: string (ISO 8601)
}
```

### Message

```typescript
{
  id: string (UUID)
  conversationId: string (UUID)
  senderId: string (UUID)
  content: string (1-5000 characters)
  messageType: 'text' | 'image' | 'file' | 'system'
  status: 'sent' | 'delivered' | 'read'
  readBy: { [userId: string]: string } // userId -> ISO timestamp
  deliveredTo: { [userId: string]: string } // userId -> ISO timestamp
  createdAt: string (ISO 8601)
  updatedAt: string (ISO 8601)
  deletedAt?: string (ISO 8601)
}
```

### User (Participant)

```typescript
{
  id: string (UUID)
  name: string
  email: string
  profilePicture?: string (URL)
  role: 'patient' | 'doctor' | 'nurse' | 'admin'
  isOnline: boolean
  lastSeen?: string (ISO 8601)
}
```

---

## Error Handling

### HTTP Error Responses

All error responses follow this format:

```json
{
  "status": "error",
  "message": "Human-readable error message",
  "code": "ERROR_CODE",
  "errors": [] // Validation errors (optional)
}
```

### Common HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (invalid/missing token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 429 | Too Many Requests (rate limit) |
| 500 | Internal Server Error |

### Socket.io Error Events

Errors during socket communication are emitted via the `error` event:

```json
{
  "message": "Error description",
  "code": "SOCKET_ERROR_CODE"
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Request validation failed |
| `UNAUTHORIZED` | Authentication required |
| `FORBIDDEN` | Insufficient permissions |
| `NOT_FOUND` | Resource not found |
| `CONVERSATION_NOT_FOUND` | Conversation doesn't exist |
| `MESSAGE_NOT_FOUND` | Message doesn't exist |
| `INVALID_PARTICIPANT` | Invalid participant ID |
| `RATE_LIMIT_EXCEEDED` | Too many requests |

---

## Best Practices

### 1. Message Sending Flow

**✅ Recommended:**
```
1. Send message via REST API POST /conversations/:id/messages
2. Server saves to database
3. Server emits new_message via Socket.io to all participants
4. Client receives new_message event and updates UI
5. Client emits mark_delivered for received messages
```

**❌ Not Recommended:**
- Don't send messages directly via socket events
- Don't rely solely on socket for message delivery (use REST API for guaranteed delivery)

---

### 2. Read Receipt Flow

**✅ Recommended:**
```
1. User views messages in conversation
2. Client calls REST API POST /conversations/:id/read
3. Server updates database
4. Server emits messages_read (batch) and individual message_read events
5. Other clients receive events and update UI
```

**❌ Not Recommended:**
- Don't use socket-only approach for read receipts
- REST API ensures persistence even if socket disconnects

---

### 3. Connection Management

**✅ Recommended:**
```
1. Connect socket after successful authentication
2. Join conversation rooms when opening chat screens
3. Leave conversation rooms when closing chat screens
4. Disconnect socket on logout
5. Implement automatic reconnection with exponential backoff
```

---

### 4. Performance Optimization

- **Pagination:** Always use pagination for conversations and messages
- **Caching:** Messages are cached in Redis for 1 hour
- **Rate Limiting:** Respect rate limits (100 messages per minute per user)
- **Batch Operations:** Use batch read receipts instead of individual updates

---

### 5. Security Considerations

- **Authentication:** Always include valid JWT token
- **Authorization:** Users can only access conversations they participate in
- **Content Validation:** Messages are sanitized and validated
- **Rate Limiting:** Enforced at both REST and socket levels
- **Input Sanitization:** All user input is sanitized to prevent XSS

---

## Field Name Conventions

### API Contracts (REST & Socket)

All API contracts use **camelCase** for field names:

✅ **Correct:**
- `participantIds`
- `messageType`
- `messageIds`
- `conversationId`
- `senderId`

❌ **Incorrect (Legacy - Do Not Use):**
- `participant_ids`
- `message_type`
- `message_ids`
- `type`
- `metadata`

### Database Schema

The database uses **snake_case** for column names (PostgreSQL convention):
- `participant_ids`
- `message_type`
- `conversation_id`

The API layer automatically handles conversion between camelCase (API) and snake_case (database).

---

## Migration Notes

### Recent Changes (January 2025)

1. **API Contract Alignment:**
   - Mobile clients updated to use camelCase payloads
   - Removed unsupported fields: `type`, `metadata`, `parent_message_id`

2. **Socket Event Standardization:**
   - Mobile uses REST API for message send and read operations
   - Socket.io used only for real-time broadcasts from server
   - Removed client-side `send_message` and `mark_read` socket events

3. **Read Receipt Events:**
   - Server now emits both `messages_read` (batch) and `message_read` (individual) events
   - Ensures compatibility with different client implementations

---

## Support

For issues, questions, or feature requests:
- Backend: See `backend/README.md`
- Mobile: See `mobile/README.md`
- General: See project documentation in `docs/`

---

**Document Version:** 1.0  
**Last Updated:** January 2025  
**Status:** ✅ Production Ready
