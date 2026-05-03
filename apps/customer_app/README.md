# Fattoush Customer App

Flutter mobile app for the Fattoush MVP.

This app currently includes:

- Splash flow
- Login / register / guest entry
- Product browsing
- Categories
- Product details
- Cart
- Delivery address
- Payment method UI
- Order completion flow
- Customer order history
- Admin dashboard access for testing

## Run Locally

1. Install Flutter dependencies:

```powershell
flutter pub get
```

2. Make sure the backend is running.

3. If using a real Android device over USB, map the backend port:

```powershell
adb reverse tcp:3000 tcp:3000
```

4. Run the app:

```powershell
flutter run
```

## Notes

- The app reads its API base URL from `lib/src/core/config/app_config.dart`.
- For local Android testing with `adb reverse`, the app can use `127.0.0.1`.
- Admin features are available when logging in with an admin account.
