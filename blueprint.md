# Project Blueprint

## Overview

This project is a Flutter application for managing rental properties. It provides a dashboard to view and manage properties, with features for adding new properties and viewing existing ones.

## Style and Design

The application uses the Material 3 design system with a blue-based color scheme. It features a responsive layout that adapts to different screen sizes, with a focus on a clean and modern user interface.

- **Color Scheme:** Based on `Colors.blue`.
- **Typography:** Standard Material 3 typography.
- **Layout:** Responsive layout that adjusts for mobile and desktop screens.
- **Card Theme:** Cards have a slight elevation, rounded corners, and a subtle border.

## Features

- **Dashboard:** The main screen of the application, displaying a summary of properties.
- **Property List:** A responsive grid of properties, displayed as cards.
- **Add Property:** A dialog for adding new properties, with fields for property name, address, and rent. The dialog is displayed as a bottom sheet on mobile and a dialog on desktop.
- **Property Details:** A detailed view of a property, showing its rooms and other information.
- **Room Management:** A card-based view of rooms within a property, with a "Manage" button for future actions.

## Current Task

**Task:** Complete the initial development of the application.

**Plan:**

1.  **Fix mobile layout issues:** Resolved the "two dashboards" problem by deleting the duplicate dashboard screen and correcting the import statements.
2.  **Improve mobile UX:** Added a `FloatingActionButton` to the dashboard for adding new properties on mobile devices.
3.  **Enhance "Add New Property" dialog:** Restored the full functionality of the dialog, including form validation and fields for property details.
4.  **Add "Manage" button:** Added a "Manage" button to the `RoomCard` widget to provide a consistent user experience.
5.  **Finalize and document:** Update the `blueprint.md` file to reflect the current state of the project and ensure all features are working as expected.
