# My Presence UMM - Attendance App
## Project Structure

```
lib/
├── app_routes/          # Navigation hub
│   ├── app_pages.dart   # Route mapping & dependency injection
│   └── app_routes.dart  # Route name constants
├── models/              # Data blueprints for DB(Models/POJOs)
├── modules/             # CORE FEATURES
│   ├── home/            # Dashboard feature
│   │   ├── bindings/    # Dependency injection for Home
│   │   ├── controllers/ # Business logic & state management
│   │   └── views/       # UI components
│   ├── login/           # Authentication feature
│   ├── rekap_kehadiran/ # Attendance history & recap
│   └── map_detail/      # Presence/Map tracking feature
├── utils/               # Global helpers (AppColors, styles, constants)
└── main.dart            # Entry point & app configuration
```

### 💡 Folder Responsibilities

- **Modules**: Every feature has its own folder containing its UI (Views), Logic (Controllers), and Dependency Management (Bindings).
- **App Routes**: Centralized navigation. To add a new screen, define the path in `app_routes.dart` and map it in `app_pages.dart`.
- **Bindings**: Used by GetX to manage memory efficiently. Controllers are only initialized when the corresponding view is active.
- **Utils**: Shared constants like `AppColors` for consistent branding across the app.

---

## Tech Stack
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Backend**: [Supabase](https://supabase.com/)
- **Maps**: [Flutter Map](https://pub.dev/packages/flutter_map)
- **Location**: [Geolocator](https://pub.dev/packages/geolocator)

## Getting Started

1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

---
*Developed with ❤️ for Universitas Muhammadiyah Malang.*
