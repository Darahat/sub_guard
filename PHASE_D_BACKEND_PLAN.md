# Phase D: Backend Integration - Implementation Plan

## Overview

Add cloud backend for multi-device sync, authentication, and data backup.

## Backend Service Selection

### Option 1: Firebase (RECOMMENDED) ✅

**Pros:**

- Excellent Flutter support with official packages
- Real-time sync out of the box
- Built-in authentication (email, Google, Apple, etc.)
- Offline persistence with automatic sync
- Cloud Firestore for document-based data
- Free tier: 50K reads/day, 20K writes/day, 1GB storage
- Cloud Functions for server-side logic
- Firebase Analytics and Crashlytics

**Cons:**

- Vendor lock-in to Google ecosystem
- Can get expensive at scale
- Complex pricing model

**Packages Needed:**

```yaml
firebase_core: ^3.3.0
firebase_auth: ^5.1.4
cloud_firestore: ^5.2.1
firebase_analytics: ^11.2.1
google_sign_in: ^6.2.1
```

### Option 2: Supabase

**Pros:**

- PostgreSQL-based (more flexible queries)
- Open source (self-hostable)
- Real-time subscriptions
- Built-in auth and storage
- More predictable pricing
- Row-level security

**Cons:**

- Smaller community than Firebase
- Less mature Flutter integration
- Manual offline sync implementation needed

**Packages Needed:**

```yaml
supabase_flutter: ^2.5.0
```

## Selected: Firebase ✅

**Reasons:**

1. Best Flutter integration
2. Automatic offline sync
3. Real-time listeners
4. Easy authentication
5. Free tier sufficient for MVP

## Architecture Changes

### Current Architecture

```
Presentation → Domain (Use Cases) → Data (Repository) → Isar Database
```

### New Architecture

```
Presentation → Domain (Use Cases) → Data (Repository) → [Local (Isar) + Remote (Firebase)]
                                                              ↓
                                                          Sync Service
```

### Sync Strategy: **Hybrid (Local-First)**

**Flow:**

1. **Write Operations**: Write to local Isar first, then sync to Firebase in background
2. **Read Operations**: Read from Isar (instant), fetch from Firebase in background
3. **Real-time Sync**: Listen to Firebase changes and update Isar
4. **Conflict Resolution**: Last-write-wins with timestamp comparison
5. **Offline Support**: Queue operations when offline, sync when back online

**Benefits:**

- Instant UI updates (no network latency)
- Works offline
- Data always available locally
- Automatic background sync

## Database Schema (Firestore)

### Collections Structure

```
users/
  {userId}/
    profile/
      - email
      - displayName
      - createdAt
      - lastSyncedAt

    subscriptions/
      {subscriptionId}/
        - serviceName
        - category
        - billingCycle
        - amount
        - currency
        - startDate
        - renewalDate
        - status
        - notes
        - reminderEnabled
        - createdAt
        - updatedAt
        - deletedAt (soft delete)

    budgets/
      {budgetId}/
        - name
        - amount
        - period
        - categoryFilter
        - createdAt
        - updatedAt

    sync_queue/
      {operationId}/
        - operation (create/update/delete)
        - collection (subscriptions/budgets)
        - documentId
        - data
        - timestamp
        - retryCount
```

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Implementation Phases

### Phase D1: Firebase Setup ✅ (Current Task)

- [ ] Create Firebase project
- [ ] Add Firebase to Flutter app (Android, iOS, Web)
- [ ] Configure authentication providers
- [ ] Add dependencies to pubspec.yaml
- [ ] Initialize Firebase in main.dart

### Phase D2: Authentication

- [ ] Create auth domain models (User entity)
- [ ] Build AuthRepository interface
- [ ] Implement FirebaseAuthDataSource
- [ ] Create auth use cases (sign in, sign up, sign out)
- [ ] Build login/signup screens
- [ ] Add AuthNotifier for state management
- [ ] Implement Google Sign-In
- [ ] Add onboarding flow for new users

### Phase D3: Remote Data Sources

- [ ] Create RemoteSubscriptionDataSource with Firestore
- [ ] Create RemoteBudgetDataSource with Firestore
- [ ] Implement CRUD operations for subscriptions
- [ ] Implement CRUD operations for budgets
- [ ] Add real-time listeners
- [ ] Handle Firebase exceptions

### Phase D4: Sync Service

- [ ] Create SyncService with sync queue
- [ ] Implement local → remote sync
- [ ] Implement remote → local sync
- [ ] Add conflict resolution (timestamp-based)
- [ ] Handle offline queue
- [ ] Add retry logic for failed syncs
- [ ] Track last sync timestamp

### Phase D5: Repository Updates

- [ ] Update SubscriptionRepository to use both local & remote
- [ ] Update BudgetRepository to use both local & remote
- [ ] Implement cache-first strategy
- [ ] Add background sync triggers
- [ ] Update error handling for network failures

### Phase D6: Sync UI

- [ ] Add sync status indicator in app bar
- [ ] Show offline mode banner
- [ ] Add pull-to-refresh for manual sync
- [ ] Display sync errors with retry
- [ ] Show last synced timestamp
- [ ] Add sync progress indicator

### Phase D7: Testing

- [ ] Test authentication flow
- [ ] Test CRUD operations with sync
- [ ] Test offline mode
- [ ] Test conflict resolution
- [ ] Test real-time updates
- [ ] Test data migration from local to cloud

## File Structure

```
lib/
  core/
    firebase/
      firebase_config.dart
      firebase_error_handler.dart
    sync/
      sync_service.dart
      sync_queue.dart
      sync_status.dart

  features/
    auth/
      domain/
        entities/
          user_entity.dart
        repositories/
          auth_repository.dart
        usecases/
          sign_in_usecase.dart
          sign_up_usecase.dart
          sign_out_usecase.dart
          get_current_user_usecase.dart
      data/
        datasources/
          firebase_auth_datasource.dart
        repositories/
          auth_repository_impl.dart
        models/
          user_model.dart
      presentation/
        providers/
          auth_providers.dart
          auth_notifier.dart
        screens/
          login_screen.dart
          signup_screen.dart
          onboarding_screen.dart
        widgets/
          auth_form.dart
          social_sign_in_buttons.dart

    subscriptions/
      data/
        datasources/
          remote_subscription_datasource.dart  # NEW
        repositories/
          subscription_repository_impl.dart    # UPDATE

    budget/
      data/
        datasources/
          remote_budget_datasource.dart        # NEW
        repositories/
          budget_repository_impl.dart          # UPDATE
```

## Data Models Updates

### Add to SubscriptionModel

```dart
@collection
class SubscriptionModel {
  // ... existing fields

  String? firebaseId;        // Firebase document ID
  DateTime? lastSyncedAt;    // Last sync timestamp
  bool needsSync;            // Pending sync flag
  bool isDeleted;            // Soft delete flag
}
```

### Add to BudgetModel

```dart
@collection
class BudgetModel {
  // ... existing fields

  String? firebaseId;
  DateTime? lastSyncedAt;
  bool needsSync;
  bool isDeleted;
}
```

## Sync Logic

### Write Operation Flow

```
1. User creates/updates subscription
2. Save to Isar immediately (UI updates instantly)
3. Mark needsSync = true
4. SyncService picks up changes
5. Upload to Firestore
6. Update firebaseId and lastSyncedAt
7. Mark needsSync = false
```

### Read Operation Flow

```
1. Read from Isar (instant display)
2. Fetch from Firestore in background
3. Compare timestamps
4. Update Isar if Firestore has newer data
5. Update lastSyncedAt
```

### Conflict Resolution

```
1. Compare lastSyncedAt timestamps
2. If local > remote: upload local to Firebase
3. If remote > local: update local from Firebase
4. If timestamps equal: no action needed
```

### Offline Mode

```
1. Queue all write operations
2. Continue reading from Isar
3. Show offline indicator
4. When back online:
   - Process queue in order
   - Retry failed operations
   - Clear queue after success
```

## Error Handling

### Network Errors

- Display user-friendly messages
- Offer retry button
- Queue operations for later
- Don't block UI

### Auth Errors

- Redirect to login
- Clear local cache on sign out
- Handle token expiration

### Firestore Errors

- Log errors to analytics
- Retry transient failures
- Display permanent failures to user

## Security

### Authentication

- Email/password with strong validation
- Google Sign-In for easy onboarding
- Optional: Apple Sign-In, Facebook

### Data Security

- All data encrypted in transit (HTTPS)
- Firestore security rules per user
- No public access to any data
- User can only access their own subscriptions

### Privacy

- No analytics without consent
- User can delete all data
- Export data option
- GDPR compliance

## Performance

### Optimization Strategies

1. **Batch Writes**: Group multiple updates
2. **Pagination**: Load subscriptions in chunks
3. **Caching**: Cache-first with background refresh
4. **Lazy Sync**: Only sync visible data initially
5. **Compression**: Compress large payloads

### Firestore Quotas (Free Tier)

- **Reads**: 50,000/day
- **Writes**: 20,000/day
- **Deletes**: 20,000/day
- **Storage**: 1 GB
- **Network**: 10 GB/month

**Estimated Usage (100 active users):**

- Avg 50 subscriptions/user
- 10 reads/user/day = 1,000 reads/day ✅
- 2 writes/user/day = 200 writes/day ✅
- Total storage: ~5 MB ✅

## Testing Strategy

### Unit Tests

- Test auth use cases
- Test sync service logic
- Test conflict resolution
- Test offline queue

### Integration Tests

- Test Firestore operations
- Test auth flow end-to-end
- Test sync scenarios

### Manual Tests

- Sign up new user
- Add subscription → verify sync
- Update subscription → verify sync
- Delete subscription → verify sync
- Switch devices → verify data appears
- Go offline → add subscription → go online → verify sync
- Create conflict → verify resolution

## Migration Plan

### From Local-Only to Cloud-Backed

1. **Phase 1**: Add Firebase (no breaking changes)
   - Existing users continue with local-only
   - New installs prompt for account creation

2. **Phase 2**: Prompt existing users to sign up
   - Show benefits (multi-device, backup)
   - Allow "Continue without account"
   - Migrate local data on first sign-in

3. **Phase 3**: Automatic migration
   - On sign-up/sign-in, upload all local data
   - Keep local data as backup
   - Mark all as synced

## Timeline Estimate

- **D1: Setup** - 1-2 hours
- **D2: Authentication** - 4-6 hours
- **D3: Remote Data Sources** - 3-4 hours
- **D4: Sync Service** - 6-8 hours
- **D5: Repository Updates** - 2-3 hours
- **D6: Sync UI** - 2-3 hours
- **D7: Testing** - 3-4 hours

**Total**: 21-30 hours of development

## Success Criteria

- ✅ User can sign up and log in
- ✅ Data syncs automatically across devices
- ✅ App works offline
- ✅ Conflicts resolve correctly
- ✅ No data loss during sync
- ✅ Sync status visible to user
- ✅ Fast and responsive (cache-first)
- ✅ Secure (user can only access their data)

## Next Steps

1. Create Firebase project at https://console.firebase.google.com
2. Add Firebase to Flutter app (use FlutterFire CLI)
3. Add dependencies to pubspec.yaml
4. Implement authentication flow
5. Build remote data sources
6. Create sync service
7. Update repositories
8. Add sync UI
9. Test thoroughly

---

**Status**: Planning Complete - Ready to implement
**Dependencies**: Firebase account, Google Sign-In credentials
**Blocking Issues**: None
