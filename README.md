# RideEase - Smart Ride Sharing App

## Setup Instructions

### 1. Supabase Setup
1. Create a new Supabase Project.
2. Go to the SQL Editor and run the script found in `SUPABASE_SETUP.sql`.
3. Go to **Project Settings > API**.
4. Copy the `URL` and `anon` public key.
5. Open `lib/core/constants.dart` and paste these values into `supabaseUrl` and `supabaseAnonKey`.
6. Go to **Authentication > Providers** and enable Email/Password.
7. Go to **Database > Replication** and ensure the `rides` table is enabled for Realtime.

### 2. Google Maps Setup
1. Get a Google Maps API Key from Google Cloud Console.
2. Enable **Maps SDK for Android** and **Maps SDK for iOS**.
3. Add the key to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>
   ```
4. Add the key to `ios/Runner/AppDelegate.swift` (or `Info.plist` depending on config, usually AppDelegate `GMSServices.provideAPIKey("YOUR_KEY")`).

### 3. Run the App
```bash
flutter pub get
flutter run
```

## Features
- **Rider**: Request rides, see status, view history.
- **Driver**: View available requests, accept rides, track pickup/dropoff, complete rides.
- **Realtime**: Updates using Supabase Realtime (Streams).

## Architecture
- **Provider**: State Management.
- **Supabase**: Auth, DB, Realtime.
- **MVVM-ish**: Service -> Provider -> UI.
