# Chat System Implementation

## Overview

Complete real-time chat implementation for the VIATRA Health Platform, enabling secure messaging between patients and doctors with support for text, images, and files.

## Features Implemented

### Backend Implementation

#### 1. Database Models

**Conversation Model** (`backend/src/models/Conversation.js`)
- Participants management
- Last message tracking
- Read status for each participant
- Timestamps for creation and updates

**Message Model** (`backend/src/models/Message.js`)
- Sender and conversation relationship
- Message types: text, image, file, system
- Read status and timestamps
- Metadata support for rich content
- Soft delete capability

#### 2. Controllers (`backend/src/controllers/chatController.js`)

**Conversation Management**:
- `getConversations`: List user's conversations with pagination
- `getConversation`: Get single conversation with messages
- `createConversation`: Start new conversation
- `markConversationAsRead`: Mark all messages as read

**Message Management**:
- `getMessages`: Retrieve paginated messages
- `sendMessage`: Send new message
- `markMessagesAsRead`: Mark specific messages as read
- `deleteMessage`: Soft delete message

#### 3. Services (`backend/src/services/chatService.js`)
- Business logic for chat operations
- Participant validation
- Read receipt management
- Message history with pagination
- Real-time notification triggers

#### 4. Socket.io Integration (`backend/src/socket/chatHandler.js`)

**Real-time Events**:
- `join:conversation`: Join conversation room
- `leave:conversation`: Leave conversation room
- `send:message`: Send real-time message
- `typing:start`: Typing indicator start
- `typing:stop`: Typing indicator stop
- `read:messages`: Real-time read receipts

**Server Events**:
- `message:received`: New message notification
- `message:read`: Read receipt notification
- `typing:indicator`: Typing status update
- `conversation:updated`: Conversation metadata update

#### 5. Routes (`backend/src/routes/chat.js`)
```
GET    /api/v1/chat/conversations           - List conversations
POST   /api/v1/chat/conversations           - Create conversation
GET    /api/v1/chat/conversations/:id       - Get conversation
PUT    /api/v1/chat/conversations/:id/read  - Mark conversation as read
GET    /api/v1/chat/messages/:conversationId - Get messages
POST   /api/v1/chat/messages/:conversationId - Send message
PUT    /api/v1/chat/messages/read           - Mark messages as read
DELETE /api/v1/chat/messages/:id            - Delete message
```

### Mobile Implementation

#### 1. Screens (`mobile/lib/screens/chat/`)
- **Conversation List Screen**: All conversations with unread badges
- **Chat Screen**: Message interface with real-time updates
- **New Chat Screen**: Start new conversation

#### 2. Provider (`mobile/lib/providers/chat_provider.dart`)
- State management for conversations and messages
- Socket.io client integration
- Real-time message updates
- Typing indicator management
- Read receipt tracking
- Offline message queuing

#### 3. Models (`mobile/lib/models/`)
- **Conversation**: Conversation data model
- **Message**: Message data model with type enums
- Serialization/deserialization helpers

#### 4. Widgets (`mobile/lib/widgets/chat/`)
- **Conversation Card**: List item with preview
- **Message Bubble**: Text/image/file message display
- **Message Input**: Text input with file attachment
- **Typing Indicator**: Animated typing dots
- **Unread Badge**: Unread count indicator
- **Date Separator**: Date dividers in chat

#### 5. Services (`mobile/lib/services/`)
- **Chat Service**: API integration
- **Socket Service**: WebSocket management
- **File Upload Service**: Image/file uploads

## API Endpoints

### Get Conversations
```http
GET /api/v1/chat/conversations?page=1&limit=20
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "conversations": [...],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalItems": 42
    }
  }
}
```

### Create Conversation
```http
POST /api/v1/chat/conversations
Authorization: Bearer <token>

{
  "participantIds": ["uuid1", "uuid2"]
}
```

### Send Message
```http
POST /api/v1/chat/messages/:conversationId
Authorization: Bearer <token>

{
  "content": "Message text",
  "messageType": "text",
  "metadata": {}
}
```

### Get Messages
```http
GET /api/v1/chat/messages/:conversationId?page=1&limit=50
Authorization: Bearer <token>
```

### Mark as Read
```http
PUT /api/v1/chat/messages/read
Authorization: Bearer <token>

{
  "messageIds": ["uuid1", "uuid2", "uuid3"]
}
```

## Socket.io Events

### Client → Server

**Join Conversation**
```javascript
socket.emit('join:conversation', {
  conversationId: 'uuid'
});
```

**Send Message**
```javascript
socket.emit('send:message', {
  conversationId: 'uuid',
  content: 'Hello!',
  messageType: 'text'
});
```

**Typing Indicator**
```javascript
socket.emit('typing:start', { conversationId: 'uuid' });
socket.emit('typing:stop', { conversationId: 'uuid' });
```

### Server → Client

**New Message**
```javascript
socket.on('message:received', (message) => {
  // Handle new message
});
```

**Read Receipt**
```javascript
socket.on('message:read', (data) => {
  // Update read status
});
```

**Typing Indicator**
```javascript
socket.on('typing:indicator', (data) => {
  // Show/hide typing indicator
});
```

## Business Rules

1. **Conversations**: Automatically created between patient and doctor
2. **Message Limit**: Maximum 5000 characters per message
3. **File Size**: Maximum 10MB per file upload
4. **File Types**: Images (jpg, png, gif), Documents (pdf)
5. **Read Receipts**: Automatically marked when messages viewed
6. **Typing Indicators**: 3-second timeout after last keystroke
7. **Message History**: Paginated, 50 messages per page
8. **Soft Delete**: Deleted messages hidden but retained in database

## Security

1. **Authentication**: JWT token required for all endpoints
2. **Authorization**: Users can only access their own conversations
3. **Participant Validation**: Verify user is conversation participant
4. **File Scanning**: Antivirus scanning on file uploads
5. **Content Filtering**: Profanity filter on text messages (optional)
6. **Rate Limiting**: Max 100 messages per minute per user

## Real-time Architecture

```
┌─────────────┐         WebSocket         ┌─────────────┐
│   Mobile    │◄──────────────────────────►│   Backend   │
│     App     │      Socket.io Client      │   Server    │
└─────────────┘                            └─────────────┘
       │                                           │
       │ HTTP REST API                             │
       │ (Fallback & Pagination)                   │
       │                                           │
       └───────────────────────────────────────────┘
```

### Connection Management
- Auto-reconnect on connection loss
- Exponential backoff retry strategy
- Connection state tracking
- Offline message queuing

### Message Flow
1. User types message in mobile app
2. Message sent via Socket.io (real-time)
3. Server validates and stores in database
4. Server broadcasts to conversation participants
5. Recipients receive via Socket.io
6. Fallback to HTTP polling if Socket.io fails

## Database Schema

```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY,
  participants JSONB NOT NULL,
  last_message_id UUID,
  last_message_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE messages (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id),
  sender_id UUID REFERENCES users(id),
  content TEXT NOT NULL,
  message_type VARCHAR(20),
  metadata JSONB,
  read_by JSONB,
  deleted_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_conversations_participants ON conversations USING GIN(participants);
```

## Testing

### Backend Tests
```bash
cd backend
npm test -- chat
```

### Mobile Tests
```bash
cd mobile
flutter test test/chat_test.dart
```

### Integration Tests
```bash
cd mobile
flutter test integration_test/chat_flow_test.dart
```

## Performance Optimizations

1. **Message Pagination**: Load messages in chunks (50 per page)
2. **Lazy Loading**: Infinite scroll for message history
3. **Caching**: Cache recent conversations and messages
4. **Connection Pooling**: Socket.io connection reuse
5. **Image Compression**: Compress images before upload
6. **Thumbnail Generation**: Generate thumbnails for images

## Future Enhancements

- [ ] Voice messages
- [ ] Video messages
- [ ] Message reactions (emoji)
- [ ] Message threading/replies
- [ ] Group chats (multi-participant)
- [ ] End-to-end encryption
- [ ] Message search
- [ ] File preview in-app
- [ ] Message forwarding
- [ ] Push notifications for new messages
- [ ] Message templates for common responses
- [ ] Auto-translate messages

## Dependencies

### Backend
- `socket.io`: Real-time communication
- `joi`: Validation
- `sequelize`: ORM
- `multer`: File uploads

### Mobile
- `socket_io_client`: WebSocket client
- `provider`: State management
- `cached_network_image`: Image caching
- `file_picker`: File selection

## Documentation Links

- [Chat API Documentation](../api/CHAT_API.md)
- [Socket.io Events Reference](../api/SOCKET_EVENTS.md)
- [Testing Guide](../TESTING_GUIDE.md)

---

**Status**: ✅ Complete  
**Last Updated**: November 2024  
**Maintained By**: Platform Team
