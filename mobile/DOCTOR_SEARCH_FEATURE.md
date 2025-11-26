# Doctor Search Feature Documentation

## Overview

The Doctor Search feature provides a comprehensive, user-friendly interface for patients to discover and connect with healthcare providers. It includes real-time search, advanced filtering, pagination, and detailed doctor profiles.

## Architecture

### Components

```
lib/
├── models/
│   ├── doctor_model.dart              # Doctor data model
│   └── doctor_search_filter.dart      # Filter model with serialization
├── services/
│   └── doctor_service.dart            # API integration
├── providers/
│   └── doctor_search_provider.dart    # State management & caching
├── screens/
│   └── doctor_search/
│       ├── doctor_search_screen.dart         # Main search UI
│       ├── doctor_detail_screen.dart         # Doctor profile view
│       └── doctor_search_filter_sheet.dart   # Filter bottom sheet
├── widgets/
│   └── doctor/
│       └── doctor_card.dart           # Doctor list item
└── utils/
    └── constants.dart                 # DoctorSearchConstants
```

## Features

### 1. Real-Time Search

- **Debounced Input**: 500ms delay to prevent excessive API calls
- **Query Persistence**: Search query maintained in filter state
- **Clear Action**: One-tap to clear search
- **Visual Feedback**: Search icon/clear button toggle

**Implementation**:
```dart
Timer? _debounce;

void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  
  _debounce = Timer(DoctorSearchConstants.searchDebounce, () {
    final provider = context.read<DoctorSearchProvider>();
    final newFilter = provider.filter.copyWith(searchQuery: query);
    provider.updateFilter(newFilter);
  });
}
```

### 2. Advanced Filtering

**Available Filters**:
- **Specialty**: Primary medical specialty
- **Sub-Specialty**: Contextual sub-specialization
- **Location**: City, State, ZIP code
- **Fee Range**: Custom range or presets
- **Languages**: Multi-select from 40+ languages
- **Accepting Patients**: Boolean toggle
- **Telehealth**: Boolean toggle

**Filter UI**:
- Bottom sheet with scrollable content
- Active filter count badge
- Clear all filters button
- Apply button triggers search
- Form validation

**Filter Persistence**:
```dart
class DoctorSearchFilter {
  final String? specialty;
  final String? city;
  final double? minFee;
  final double? maxFee;
  // ... other fields
  
  Map<String, String> toQueryParams() {
    // Converts filter to API query parameters
  }
  
  Map<String, dynamic> toJson() {
    // For caching and serialization
  }
}
```

### 3. Sorting

**Sort Options** (configurable in `DoctorSearchConstants.sortOptions`):
1. Newest First (default)
2. Oldest First
3. Fee: Low to High
4. Fee: High to Low
5. Name: A-Z
6. Name: Z-A

**Implementation**:
```dart
DropdownButton<String>(
  value: selectedSort,
  items: DoctorSearchConstants.sortOptions.map((option) {
    return DropdownMenuItem(
      value: '${option['sortBy']}_${option['sortOrder']}',
      child: Text(option['label']!),
    );
  }).toList(),
  onChanged: (value) => _handleSortChange(value),
)
```

### 4. Pagination

**Configuration**:
- Default page size: 20 doctors
- Load more threshold: 200 pixels from bottom
- Infinite scroll with "load more" indicator
- Total results and page count displayed

**Scroll Detection**:
```dart
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 
      DoctorSearchConstants.loadMoreThreshold) {
    final provider = context.read<DoctorSearchProvider>();
    if (provider.hasMore && !provider.isLoadingMore) {
      provider.loadMoreDoctors();
    }
  }
}
```

**Provider Implementation**:
```dart
Future<void> loadMoreDoctors() async {
  if (!hasMore || _state == DoctorSearchState.loadingMore) return;
  
  _state = DoctorSearchState.loadingMore;
  _currentPage++;
  notifyListeners();
  
  try {
    final response = await _doctorService.searchDoctors(
      _filter,
      page: _currentPage,
      limit: DoctorSearchConstants.defaultPageSize,
    );
    
    if (response.success && response.data != null) {
      _doctors.addAll(response.data!.doctors);
      _totalPages = response.data!.pagination.totalPages;
      _state = DoctorSearchState.loaded;
    }
  } catch (e) {
    _currentPage--;
    _state = DoctorSearchState.error;
  }
  
  notifyListeners();
}
```

### 5. Caching Strategy

**Local Cache**:
- Cache key: JSON-encoded filter combination
- TTL: 5 minutes (configurable)
- Automatic expiration check
- Cache invalidation on filter change

**Implementation**:
```dart
class CachedSearchResult {
  final List<Doctor> doctors;
  final int totalPages;
  final int totalResults;
  final DateTime timestamp;
  
  bool get isExpired {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff.inMinutes >= DoctorSearchConstants.cacheTTLMinutes;
  }
}

final Map<String, CachedSearchResult> _cachedResults = {};

String _getCacheKey() {
  return json.encode(_filter.toJson());
}

CachedSearchResult? _getCachedResults() {
  final key = _getCacheKey();
  final cached = _cachedResults[key];
  
  if (cached != null && !cached.isExpired) {
    return cached;
  }
  
  // Remove expired cache
  if (cached != null && cached.isExpired) {
    _cachedResults.remove(key);
  }
  
  return null;
}
```

**Backend Cache**:
- Redis-backed caching on backend
- 5-minute TTL matches frontend
- Cache key includes all query parameters
- Transparent to frontend

### 6. Doctor Profile View

**Displayed Information**:
- Profile picture (with fallback)
- Full name and title
- Primary specialty and sub-specialty
- Years of experience
- Education and qualifications
- Consultation fee (formatted)
- Languages spoken (chips)
- Location (address, city, state, ZIP, country)
- Contact details (phone, email)
- Working hours
- Bio/description
- Status badges (accepting patients, telehealth)

**UI Components**:
- AppBar with back button
- Scrollable content
- Section headers
- Information cards
- Status badges
- Action buttons (Book, Contact)

**Navigation**:
```dart
context.push('/doctors/${doctor.id}');
```

### 7. UI States

**Initial State**:
- Empty search bar
- Helper text: "Search for doctors by name, specialty, or location"
- Illustration or icon
- No loading indicator

**Loading State**:
- Full-screen loading indicator (initial search)
- Bottom loading indicator (pagination)
- Disabled interactions during load

**Loaded State**:
- Doctor cards in list
- Pagination info: "Showing X-Y of Z results"
- Load more indicator when scrolling

**Empty State**:
- No results icon
- Message: "No doctors found"
- Suggestion: "Try adjusting your filters"
- Button to clear filters

**Error State**:
- Error icon
- Error message (user-friendly)
- Retry button
- Back to search button

**State Transitions**:
```dart
enum DoctorSearchState {
  initial,      // Before first search
  loading,      // Initial load
  loaded,       // Results displayed
  error,        // Error occurred
  loadingMore,  // Pagination in progress
}
```

### 8. User Experience

**Search Flow**:
1. User opens Doctor Search from home
2. Initial state displayed
3. User types search query (debounced)
4. Loading indicator shown
5. Results displayed
6. User scrolls, more results load
7. User taps filter, sheet opens
8. User applies filters
9. Results refresh

**Filter Flow**:
1. User taps filter button
2. Bottom sheet slides up
3. User selects filters
4. Active count updates
5. User taps "Apply"
6. Sheet closes
7. Search executes with new filters
8. Results update

**Detail Flow**:
1. User taps doctor card
2. Navigate to detail screen
3. Load doctor details (cached or API)
4. Display full profile
5. User can book appointment or contact

**Refresh Flow**:
1. User pulls down on results
2. Refresh indicator shown
3. Cache bypassed
4. Fresh data fetched
5. Results update
6. Cache updated

## API Integration

### Endpoints

**Search Doctors**:
```
GET /api/v1/doctors/search
```

**Query Parameters**:
- `specialty` (string)
- `subSpecialty` (string)
- `city` (string)
- `state` (string)
- `zipCode` (string)
- `minFee` (number)
- `maxFee` (number)
- `languages` (comma-separated)
- `isAcceptingPatients` (boolean)
- `telehealthEnabled` (boolean)
- `sortBy` (string)
- `sortOrder` (string: ASC/DESC)
- `page` (number, default: 1)
- `limit` (number, default: 20, max: 100)

**Response**:
```json
{
  "success": true,
  "message": "Doctors retrieved successfully",
  "data": {
    "doctors": [
      {
        "id": "uuid",
        "user": {
          "firstName": "John",
          "lastName": "Doe",
          "email": "john.doe@example.com",
          "phone": "+1234567890"
        },
        "specialty": "Cardiology",
        "subSpecialty": "Interventional Cardiology",
        "yearsOfExperience": 15,
        "consultationFee": 150.00,
        "education": "MD, Harvard Medical School",
        "languages": ["English", "Spanish"],
        "address": "123 Medical Plaza",
        "city": "New York",
        "state": "NY",
        "zipCode": "10001",
        "country": "USA",
        "isAcceptingPatients": true,
        "telehealthEnabled": true,
        "bio": "Board-certified cardiologist...",
        "profilePicture": "https://cdn.example.com/profile.jpg",
        "workingHours": {...}
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 156,
      "totalPages": 8
    },
    "filters": {
      "specialty": "Cardiology",
      "city": "New York",
      "minFee": 100,
      "maxFee": 200
    }
  }
}
```

**Get Doctor Details**:
```
GET /api/v1/doctors/:id
```

**Response**: Single doctor object with full details.

### Rate Limiting

- 100 requests per 15 minutes per IP
- Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- 429 status code when exceeded

### Error Handling

**Common Errors**:
- 400: Invalid query parameters
- 401: Unauthorized (missing/invalid token)
- 404: Doctor not found
- 429: Rate limit exceeded
- 500: Server error

**Error Display**:
```dart
if (response.statusCode == 429) {
  _errorMessage = 'Too many requests. Please wait a moment.';
} else if (response.statusCode == 500) {
  _errorMessage = 'Server error. Please try again later.';
} else {
  _errorMessage = response.message ?? 'Failed to search doctors';
}
```

## Configuration

### Constants (lib/utils/constants.dart)

```dart
class DoctorSearchConstants {
  // Pagination
  static const int defaultPageSize = 20;
  static const int loadMoreThreshold = 200;
  
  // Caching
  static const int cacheTTLMinutes = 5;
  
  // Search debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  
  // Sort options
  static const List<Map<String, String>> sortOptions = [
    {'label': 'Newest First', 'sortBy': 'created_at', 'sortOrder': 'DESC'},
    {'label': 'Oldest First', 'sortBy': 'created_at', 'sortOrder': 'ASC'},
    {'label': 'Fee: Low to High', 'sortBy': 'consultation_fee', 'sortOrder': 'ASC'},
    {'label': 'Fee: High to Low', 'sortBy': 'consultation_fee', 'sortOrder': 'DESC'},
    {'label': 'Name: A-Z', 'sortBy': 'user.first_name', 'sortOrder': 'ASC'},
    {'label': 'Name: Z-A', 'sortBy': 'user.first_name', 'sortOrder': 'DESC'},
  ];
  
  // Fee range presets
  static const List<Map<String, double?>> feeRanges = [
    {'label': 'Any', 'min': null, 'max': null},
    {'label': 'Under \$50', 'min': null, 'max': 50},
    {'label': '\$50 - \$100', 'min': 50, 'max': 100},
    {'label': '\$100 - \$200', 'min': 100, 'max': 200},
    {'label': 'Over \$200', 'min': 200, 'max': null},
  ];
}
```

### Customization

To customize the feature:

1. **Change page size**:
   ```dart
   DoctorSearchConstants.defaultPageSize = 30;
   ```

2. **Adjust cache TTL**:
   ```dart
   DoctorSearchConstants.cacheTTLMinutes = 10;
   ```

3. **Modify debounce delay**:
   ```dart
   DoctorSearchConstants.searchDebounce = Duration(milliseconds: 300);
   ```

4. **Add/modify sort options**:
   ```dart
   DoctorSearchConstants.sortOptions.add({
     'label': 'Rating: High to Low',
     'sortBy': 'rating',
     'sortOrder': 'DESC'
   });
   ```

## Testing

### Unit Tests

```dart
// Test filter serialization
test('DoctorSearchFilter toQueryParams', () {
  final filter = DoctorSearchFilter(
    specialty: 'Cardiology',
    city: 'New York',
    minFee: 100,
    maxFee: 200,
  );
  
  final params = filter.toQueryParams();
  
  expect(params['specialty'], 'Cardiology');
  expect(params['city'], 'New York');
  expect(params['minFee'], '100.0');
  expect(params['maxFee'], '200.0');
});

// Test cache expiration
test('CachedSearchResult expires after TTL', () {
  final cached = CachedSearchResult(
    doctors: [],
    totalPages: 0,
    totalResults: 0,
    timestamp: DateTime.now().subtract(Duration(minutes: 6)),
  );
  
  expect(cached.isExpired, true);
});
```

### Widget Tests

```dart
testWidgets('DoctorCard displays doctor info', (tester) async {
  final doctor = Doctor(
    id: '1',
    user: User(firstName: 'John', lastName: 'Doe'),
    specialty: 'Cardiology',
    consultationFee: 150,
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DoctorCard(doctor: doctor),
      ),
    ),
  );
  
  expect(find.text('Dr. John Doe'), findsOneWidget);
  expect(find.text('Cardiology'), findsOneWidget);
  expect(find.text('\$150'), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('Search flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navigate to doctor search
  await tester.tap(find.text('Find Doctors'));
  await tester.pumpAndSettle();
  
  // Enter search query
  await tester.enterText(find.byType(TextField), 'cardiology');
  await tester.pumpAndSettle(Duration(milliseconds: 600));
  
  // Verify results
  expect(find.byType(DoctorCard), findsWidgets);
  
  // Open filter
  await tester.tap(find.byIcon(Icons.filter_list));
  await tester.pumpAndSettle();
  
  // Apply filter
  await tester.tap(find.text('Apply'));
  await tester.pumpAndSettle();
  
  // Verify filtered results
  expect(find.byType(DoctorCard), findsWidgets);
});
```

## Performance

### Optimization Techniques

1. **Debounced Search**: Prevents excessive API calls
2. **Local Caching**: Reduces backend load and improves UX
3. **Pagination**: Loads data in chunks
4. **Lazy Loading**: Only renders visible items
5. **Image Caching**: Caches doctor profile pictures
6. **State Management**: Efficient rebuilds with Provider

### Metrics

- **Initial Load**: < 1 second (cached), < 2 seconds (uncached)
- **Search Input**: 500ms debounce
- **Pagination**: < 500ms per page
- **Filter Apply**: < 1 second
- **Cache Hit**: Instant
- **Detail View**: < 500ms

## Accessibility

- Semantic labels for screen readers
- Keyboard navigation support
- High contrast support
- Scalable text
- Focus management
- ARIA labels on interactive elements

## Future Enhancements

1. **Favorites**: Save favorite doctors
2. **Recent Searches**: Store recent search queries
3. **Map View**: Show doctors on map
4. **Ratings & Reviews**: Display and filter by ratings
5. **Advanced Availability**: Filter by specific time slots
6. **Insurance Filter**: Filter by accepted insurance
7. **Distance Filter**: Filter by proximity (requires location)
8. **Voice Search**: Voice-to-text search
9. **AI Recommendations**: Personalized doctor suggestions
10. **Appointment Preview**: View available slots in search results

## Troubleshooting

### Common Issues

**No results returned**:
- Check API connectivity
- Verify filter values
- Check backend logs
- Clear cache and retry

**Pagination not working**:
- Verify scroll controller attached
- Check `hasMore` state
- Review API response structure

**Cache not expiring**:
- Verify TTL configuration
- Check timestamp logic
- Force refresh with pull-to-refresh

**Search too slow**:
- Increase debounce duration
- Reduce page size
- Check network latency
- Optimize backend queries

## Support

For issues or questions:
1. Check this documentation
2. Review code comments
3. Check backend API documentation
4. Contact development team

---

**Version**: 1.0.0  
**Last Updated**: 2024-01-02  
**Author**: Viatra Health Development Team
