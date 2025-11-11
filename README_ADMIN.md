Admin Web Console (separate from landlord app)

Overview
- Separate Flutter web entry-point located at lib/admin/main_admin.dart
- Uses Firebase Auth + Firestore for admin auth and data
- Only users with a document in `admins/{uid}` (with active != false) can sign in

Run (web)
1. flutter pub get
2. flutter run -d chrome -t lib/admin/main_admin.dart

Build (web)
- flutter build web -t lib/admin/main_admin.dart -o build/web_admin

Firestore structure (suggested)
- admins/{uid}: { active: true, name, email }
- landlords/{uid}: { name, email, plan, active, createdAt }
- packages/{id}: { name, price, duration, features, active, createdAt }
- payments/{id}: { userId, userEmail, amount, status, gateway, txnId, createdAt }
- subscriptions/{id}: { userId, planId, active, startedAt, expiresAt }
- promos/{id}: { code, discount, validUntil }

Notes
- This admin is intentionally isolated; it does not share the landlord routing or UI.
- Add role documents in Firestore under admins/{uid} to enable access.
- Extend each tab with dialogs and validations as needed.
