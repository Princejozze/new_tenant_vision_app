# Project Blueprint

## Overview

A rental property management app that helps landlords easily manage their properties and track tenant information. The app is designed to be intuitive, responsive, and performant, with a focus on providing a seamless user experience across both mobile and desktop. It now features local data persistence, meaning all properties you add are saved on your device.

## Key Features

- **Property Management:** Landlords can add, view, and manage their rental properties.
- **Room & Tenant Tracking:** Each property contains rooms with details like rent status and tenant information (to be implemented).
- **Responsive UI:** The application adapts its layout for both mobile and desktop screens.
- **Light/Dark Mode:** A toggleable theme to switch between light and dark modes for user comfort.
- **Local Data Persistence:** Property data is saved locally on the user's device, ensuring data is retained between app sessions.

## Technology Stack & Core Packages

- **Framework:** Flutter
- **Routing:** `go_router` for declarative, URL-based navigation.
- **State Management:** `provider` for centralized, app-wide state management.
- **Local Storage:** `shared_preferences` for lightweight key-value data persistence.
- **Theming & Fonts:** `google_fonts` for custom typography.

## Architecture

The application follows a modern, provider-based architecture to ensure a clean separation of concerns and a reactive UI.

### State Management

- **`AppDataProvider`**: This central `ChangeNotifier` class is the single source of truth for the application's core data (the list of houses). It is initialized when the app starts, immediately beginning the process of loading data from local storage.
- **`Provider` Pattern**: The UI widgets (like `DashboardScreen`) use `Consumer` widgets to listen for changes in the `AppDataProvider`. This allows the UI to update reactively and efficiently, showing loading indicators, empty states, or the list of properties without requiring local `StatefulWidget`s.

### Data Persistence

- **`StorageService`**: This class abstracts the logic for interacting with local storage. It is responsible for encoding the list of `House` objects into JSON and saving it to `shared_preferences`, as well as decoding the JSON back into a list of `House` objects when loading.
- **Serializable Models**: The `House` and `Room` data models are equipped with `fromJson` and `toJson` methods, allowing them to be easily converted to and from JSON for storage. This makes the data layer robust and easy to maintain.

## Project Evolution & Key Architectural Decisions

### Initial Setup
The project began with a basic structure using dummy data hardcoded into the data models. This allowed for rapid UI prototyping and layout development.

### Update 1: Local Persistence & State Management Refactor
This major update addressed two key issues: data volatility and poor initial load experience.

1.  **Removed Dummy Data**: All hardcoded data was removed.
2.  **Implemented Local Storage**: `shared_preferences` was integrated via a `StorageService` to save and load property data, making user-added information persistent.
3.  **Resolved "Blank Screen" on Load**: The initial architecture caused a blank white screen while data was fetched. This was fixed by introducing the `AppDataProvider`, which is initialized at the app's startup. The UI now builds instantly and displays a loading spinner, providing a much better user experience. This new provider-based approach centralizes state logic and simplifies the UI widgets.
