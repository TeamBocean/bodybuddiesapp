# BodyBuddies

BodyBuddies is a companion mobile app for clients and coaches to keep every part
of a training journey in one place. Users can manage sessions, check remaining
credits, review nutrition plans, log macros, and upload progress photos while
staying connected to their coach through curated content.

## Features

- Personalized dashboard that surfaces bookings, credits, and announcements
- Session management with bookings history, upcoming sessions, and reminders
- Nutrition and macro tracking, including nutrient breakdowns and daily targets
- Progress tracking via photo uploads and quick stats
- Secure authentication that supports email, Google, and Apple sign-in
- Firebase-backed data layer with Stripe-powered payments

## Tech Stack

- Flutter with Material 3 theming
- Firebase Authentication & Cloud Firestore
- Shared Preferences for local caching
- Stripe Payment Sheet for handling payments

## Run Locally

1. **Install prerequisites**
   - Flutter SDK (3.x recommended) and platform toolchains for Android/iOS
   - Xcode (for iOS) and Android Studio/SDK (for Android)
   - A configured Firebase project with `google-services.json` and
     `GoogleService-Info.plist`
2. **Install dependencies**
   ```bash
   cd /Volumes/mahmoudssd/bodybuddiesapp
   flutter pub get
   ```
3. **Configure environment variables**
   - Copy `env.example` to `.env`
   - Fill in `STRIPE_PUBLISHABLE_KEY` with your publishable key
   - Fill in `STRIPE_SECRET_KEY` with a backend-only key (only for secure dev)
4. **Set up platform configs**
   - Place your `google-services.json` in `android/app/`
   - Place your `GoogleService-Info.plist` in `ios/Runner/`
   - For iOS, run `cd ios && pod install && cd ..` after adding the plist
5. **Run the app**
   ```bash
   flutter run
   ```
   Use `flutter run -d ios` or `flutter run -d android` to target a specific
   device or simulator.

## Additional Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/docs/overview)
- [Stripe Flutter docs](https://stripe.com/docs/payments/accept-a-payment?platform=mobile&ui=payment-sheet)
