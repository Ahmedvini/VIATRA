# Doctor Search with Persistence - Complete Implementation

## Overview

Advanced doctor search system with comprehensive filtering, search history persistence, favorites, and optimized search performance for the VIATRA Health Platform.

## Features Implemented

### Backend Implementation

#### 1. Search Service (`backend/src/services/doctorService.js`)

**Search Capabilities**:
- **Text Search**: Name, specialty, bio search with fuzzy matching
- **Specialty Filtering**: Primary and sub-specialty filters
- **Location Filtering**: City, state, zip code search with radius
- **Fee Range Filtering**: Min/max consultation fee
- **Language Filtering**: Multiple language support
- **Availability Filtering**: Accepting new patients, telehealth enabled
- **Sorting**: By experience, fee, rating, date joined
- **Pagination**: Efficient pagination for large result sets

**Search Algorithm**:
```javascript
// Multi-field search with weights
SELECT doctors.*, 
  SIMILARITY(name, search_query) * 0.4 +
  SIMILARITY(specialty, search_query) * 0.3 +
  SIMILARITY(bio, search_query) * 0.3 AS relevance_score
FROM doctors
WHERE relevance_score > 0.3
ORDER BY relevance_score DESC
```

#### 2. Controller (`backend/src/controllers/doctorController.js`)

**Endpoints**:
- `GET /api/v1/doctors/search`: Advanced search with filters
- `GET /api/v1/doctors/:id`: Get doctor profile
- `GET /api/v1/doctors/:id/availability`: Check availability
- `GET /api/v1/doctors/specialties`: List all specialties
- `GET /api/v1/doctors/popular`: Get popular/featured doctors

#### 3. Database Indexes
```sql
-- Full-text search index
CREATE INDEX idx_doctors_search ON doctors 
  USING GIN(to_tsvector('english', name || ' ' || specialty || ' ' || bio));

-- Location index
CREATE INDEX idx_doctors_location ON doctors(city, state, zip_code);

-- Specialty index
CREATE INDEX idx_doctors_specialty ON doctors(specialty, sub_specialty);

-- Availability index
CREATE INDEX idx_doctors_availability ON doctors(is_accepting_patients, telehealth_enabled);
```

### Mobile Implementation

#### 1. DoctorSearchProvider (`mobile/lib/providers/doctor_search_provider.dart`)

**State Management**:
- Search query and filters
- Search results with pagination
- Loading and error states
- Search history persistence
- Favorite doctors list
- Recently viewed doctors

**Key Features**:
- Debounced search (300ms delay)
- Infinite scroll pagination
- Local caching of results
- Offline search history
- Filter persistence across sessions

#### 2. Search Screens

**DoctorSearchScreen** (`mobile/lib/screens/doctor_search/doctor_search_screen.dart`):
- Search bar with autocomplete
- Filter chips (specialty, location, etc.)
- Search results list
- Empty state
- Loading indicators

**DoctorFilterSheet** (`mobile/lib/widgets/doctor_search/filter_sheet.dart`):
- Specialty dropdown
- Location input
- Fee range slider
- Language multi-select
- Availability checkboxes
- Clear all / Apply filters

**DoctorProfileScreen** (`mobile/lib/screens/doctor/doctor_profile_screen.dart`):
- Full doctor profile
- Reviews and ratings
- Availability calendar
- Book appointment button
- Favorite toggle

#### 3. Persistence Layer

**Storage Structure**:
```dart
// Search History
{
  "search_history": [
    {
      "query": "cardiologist",
      "timestamp": "2024-01-15T10:00:00Z",
      "filters": {...}
    }
  ]
}

// Favorites
{
  "favorite_doctors": [
    "doctor-uuid-1",
    "doctor-uuid-2"
  ]
}

// Recently Viewed
{
  "recently_viewed": [
    {
      "doctorId": "uuid",
      "timestamp": "2024-01-15T10:00:00Z"
    }
  ]
}
```

## API Endpoints

### Search Doctors
```http
GET /api/v1/doctors/search?
  searchQuery=cardiologist&
  specialty=Cardiology&
  city=New+York&
  state=NY&
  minFee=50&
  maxFee=200&
  languages=English,Spanish&
  isAcceptingPatients=true&
  telehealthEnabled=true&
  page=1&
  limit=20&
  sortBy=years_of_experience&
  sortOrder=DESC

Response:
{
  "success": true,
  "data": {
    "doctors": [
      {
        "id": "uuid",
        "user": {
          "firstName": "John",
          "lastName": "Smith",
          "profilePicture": "url"
        },
        "specialty": "Cardiology",
        "subSpecialty": "Interventional Cardiology",
        "licenseNumber": "MD123456",
        "yearsOfExperience": 15,
        "consultationFee": 150,
        "bio": "...",
        "education": [...],
        "languages": ["English", "Spanish"],
        "isAcceptingPatients": true,
        "telehealthEnabled": true,
        "rating": 4.8,
        "totalReviews": 142
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalItems": 87,
      "itemsPerPage": 20
    }
  }
}
```

### Get Doctor by ID
```http
GET /api/v1/doctors/:id

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "user": {...},
    "specialty": "Cardiology",
    "licenseNumber": "MD123456",
    "yearsOfExperience": 15,
    "consultationFee": 150,
    "bio": "Full biography...",
    "education": [
      {
        "degree": "MD",
        "institution": "Harvard Medical School",
        "year": "2005"
      }
    ],
    "certifications": [...],
    "languages": ["English", "Spanish"],
    "officeAddress": {...},
    "isAcceptingPatients": true,
    "telehealthEnabled": true,
    "rating": 4.8,
    "totalReviews": 142,
    "reviews": [...]
  }
}
```

## Search Features

### 1. Text Search
- **Name Search**: Exact and partial matches
- **Specialty Search**: Primary and sub-specialties
- **Bio Search**: Keywords in doctor biography
- **Fuzzy Matching**: Handles typos and variations

### 2. Filters

**Specialty Filter**:
```dart
SpecialtyDropdown(
  value: selectedSpecialty,
  onChanged: (specialty) {
    setState(() => selectedSpecialty = specialty);
    _applyFilters();
  },
)
```

**Location Filter**:
```dart
LocationInput(
  onLocationSelected: (location) {
    setState(() {
      city = location.city;
      state = location.state;
      zipCode = location.zipCode;
    });
  },
)
```

**Fee Range Filter**:
```dart
RangeSlider(
  min: 0,
  max: 500,
  values: RangeValues(minFee, maxFee),
  onChanged: (values) {
    setState(() {
      minFee = values.start;
      maxFee = values.end;
    });
  },
)
```

### 3. Search History

**Storage**:
```dart
class SearchHistoryManager {
  static const int maxHistoryItems = 20;
  
  Future<void> addSearchQuery(String query, Map<String, dynamic> filters) async {
    final history = await getSearchHistory();
    history.insert(0, {
      'query': query,
      'filters': filters,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only latest 20 searches
    if (history.length > maxHistoryItems) {
      history.removeRange(maxHistoryItems, history.length);
    }
    
    await StorageService.instance.setValue('search_history', history);
  }
  
  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    return await StorageService.instance.getValue('search_history') ?? [];
  }
  
  Future<void> clearHistory() async {
    await StorageService.instance.remove('search_history');
  }
}
```

**Display**:
```dart
ListView.builder(
  itemCount: searchHistory.length,
  itemBuilder: (context, index) {
    final item = searchHistory[index];
    return ListTile(
      leading: Icon(Icons.history),
      title: Text(item['query']),
      subtitle: Text(_formatFilters(item['filters'])),
      trailing: IconButton(
        icon: Icon(Icons.close),
        onPressed: () => _removeFromHistory(index),
      ),
      onTap: () => _applyHistoricalSearch(item),
    );
  },
)
```

### 4. Favorites

**Toggle Favorite**:
```dart
Future<void> toggleFavorite(String doctorId) async {
  final favorites = await getFavorites();
  
  if (favorites.contains(doctorId)) {
    favorites.remove(doctorId);
  } else {
    favorites.add(doctorId);
  }
  
  await StorageService.instance.setValue('favorite_doctors', favorites);
  notifyListeners();
}
```

**Display Favorites**:
```dart
IconButton(
  icon: Icon(
    isFavorite ? Icons.favorite : Icons.favorite_border,
    color: isFavorite ? Colors.red : null,
  ),
  onPressed: () => provider.toggleFavorite(doctor.id),
)
```

### 5. Recently Viewed

**Track Views**:
```dart
Future<void> addToRecentlyViewed(String doctorId) async {
  final recentlyViewed = await getRecentlyViewed();
  
  // Remove if already exists
  recentlyViewed.removeWhere((item) => item['doctorId'] == doctorId);
  
  // Add to beginning
  recentlyViewed.insert(0, {
    'doctorId': doctorId,
    'timestamp': DateTime.now().toIso8601String(),
  });
  
  // Keep only latest 10
  if (recentlyViewed.length > 10) {
    recentlyViewed.removeRange(10, recentlyViewed.length);
  }
  
  await StorageService.instance.setValue('recently_viewed', recentlyViewed);
}
```

## Performance Optimizations

### 1. Debounced Search
```dart
Timer? _debounceTimer;

void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    _performSearch(query);
  });
}
```

### 2. Pagination
```dart
Future<void> loadMore() async {
  if (_isLoadingMore || !_hasMore) return;
  
  setState(() => _isLoadingMore = true);
  
  final nextPage = _currentPage + 1;
  final result = await _searchService.search(query, page: nextPage);
  
  setState(() {
    _doctors.addAll(result.doctors);
    _currentPage = nextPage;
    _hasMore = result.pagination.hasNextPage;
    _isLoadingMore = false;
  });
}
```

### 3. Caching
```dart
final _cache = <String, SearchResult>{};
final _cacheExpiry = Duration(minutes: 5);

Future<SearchResult> search(String query) async {
  final cacheKey = _generateCacheKey(query);
  final cached = _cache[cacheKey];
  
  if (cached != null && !cached.isExpired) {
    return cached;
  }
  
  final result = await _api.search(query);
  _cache[cacheKey] = result;
  
  return result;
}
```

## Testing

### Backend Tests
```bash
cd backend
npm test -- doctor
```

### Mobile Tests
```bash
cd mobile
flutter test test/providers/doctor_search_provider_test.dart
flutter test test/services/doctor_search_service_test.dart
```

### Integration Tests
```bash
cd mobile
flutter test integration_test/doctor_search_booking_test.dart
```

## Future Enhancements

- [ ] Autocomplete suggestions
- [ ] Voice search
- [ ] Map view of doctors
- [ ] Distance-based search (GPS)
- [ ] Save custom search filters
- [ ] Search filters based on insurance
- [ ] Doctor comparison feature
- [ ] Advanced rating filters
- [ ] Availability-first search
- [ ] AI-powered doctor recommendations

## Dependencies

### Backend
- `sequelize`: ORM with full-text search
- `pg`: PostgreSQL driver

### Mobile
- `provider`: State management
- `shared_preferences`: Local storage
- `flutter_typeahead`: Autocomplete
- `geolocator`: Location services

## Documentation Links

- [Doctor API Documentation](../api/DOCTOR_API.md)
- [Search Optimization Guide](../guides/SEARCH_OPTIMIZATION.md)
- [Testing Guide](../TESTING_GUIDE.md)

---

**Status**: ✅ Complete  
**Last Updated**: November 2024  
**Maintained By**: Platform Team
