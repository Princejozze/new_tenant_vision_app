# Blueprint: Rental Property Management Dashboard

## Overview

This document outlines the plan for creating a responsive rental property management dashboard in Flutter. The application will provide a user-friendly interface for managing rental houses, with a focus on a clean, modern design and a great user experience on both desktop and mobile devices.

## Features

### 1. Responsive Layout

*   **Desktop:** A multi-column layout with a persistent, collapsible sidebar on the left and a main content area on the right.
*   **Mobile:** The sidebar is hidden by default and accessible via a hamburger menu. A fixed bottom navbar provides primary navigation.

### 2. Header Section

*   A header at the top of the main content area.
*   **Left Side:** A bold title, "Dashboard".
*   **Right Side:**
    *   An outline-style button with a "Search" icon, labeled "Find Tenant & Add Payment".
    *   A primary, solid-background button with a "PlusCircle" icon, labeled "Add New House".

### 3. Main Content: The House List

*   A responsive grid that displays a collection of "House Cards".
*   An empty state placeholder with a prompt to "Get started by adding your first rental house."

### 4. "House Card" Component

*   A reusable card component representing a single property.
*   **Header:**
    *   Property name and address.
    *   "MoreVertical" (three-dot) icon button with "Edit" and "Delete" options.
*   **Image:** A prominent property image with a 3:2 aspect ratio.
*   **Stats Section:**
    *   Bed icon with the total number of rooms.
    *   Users icon with the number of occupied rooms.
*   **Footer:** A "Manage House" button with a right-arrow icon.

### 5. Sidebar (Desktop)

*   A vertical navigation panel with icons and labels.
*   **Menu Items:** Current Houses, Upcoming, Reminders, Overdue, Leases, Tenant History, Financials.
*   **Footer:** Language switcher and "Help & Tutorial" button.

### 6. Bottom Navbar (Mobile)

*   A fixed bottom bar with icon-and-label buttons.
*   **Navigation:** Houses, Upcoming, Leases, Settings, and Financials.

## Plan

1.  **Add Dependencies:** Add the `lucide_flutter` package for icons.
2.  **Create Folder Structure:** Create folders for `lib/src/widgets`, `lib/src/screens`, and `lib/src/models`.
3.  **Implement `main.dart`:** Set up the main application widget and theme.
4.  **Create Responsive Layout:** Build a `ResponsiveLayout` widget to handle desktop and mobile views.
5.  **Build UI Components:**
    *   `Sidebar`
    *   `BottomNavbar`
    *   `Header`
    *   `HouseList`
    *   `HouseCard`
    *   `EmptyState`
6.  **Assemble the Dashboard:** Combine the components into the final dashboard screen.
7.  **Code Quality:** Run `dart format .` and `flutter analyze` to ensure code quality.
8.  **Provide Code:** Present the complete code to the user.
