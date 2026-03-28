# Marooneen Admin Dashboard

A professional, secure, and data-driven administrative panel for the Marooneen attendance system, built with **Flutter Web** and powered by **Firebase**.

## 🚀 Overview

The **Marooneen Admin Dashboard** is designed to provide real-time monitoring and administrative control over the student attendance ecosystem. With a minimalist, black-and-white aesthetics, it ensures a distraction-free and highly performant experience for school administrators and staff.

This dashboard synchronizes directly with Cloud Firestore to provide real-time updates and push notifications (FCM) to the accompanying mobile student application.

## 🌟 Key Features

* **Real-time Dashboard:** High-level analytics and overviews of student attendance and institutional operations.
* **Student & Employee Management:** Full CRUD operations for managing student profiles, employee records, and schedules.
* **Attendance Tracking:** Sophisticated paginated tables with filtering to review real-time check-ins and check-outs.
* **Fraud Detection Security:** Built-in auditing interfaces to identify and review potentially fraudulent attendance logs (e.g., GPS spoofing, device mismatch).
* **Broadcast Notifications:** Direct integration with Firebase Cloud Messaging (FCM) to send real-time announcements to the student mobile app.
* **Support Ticketing System:** Manage and respond to inquiries or issues raised by students through the mobile application.

## 🛠️ Technology Stack

* **Frontend:** Flutter Web (Dart)
* **Backend Shell:** Firebase (Cloud Firestore, Firebase Authentication, Firebase Cloud Messaging)
* **Design System:** Custom minimalist black-and-white theme, ensuring a modular and responsive layout across desktop screens.

## 📋 Getting Started

To run this project locally, ensure you have [Flutter](https://docs.flutter.dev/get-started/install) installed and configured on your machine.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/W0LF12AM/marooneen-dashboard.git
   cd marooneen-dashboard
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase (if not already set up):**
   Ensure your Firebase instances are initialized. If you don't have the `firebase_options.dart`, you'll need to run:
   ```bash
   flutterfire configure
   ```

4. **Run the project:**
   Execute the application on your local Chrome instance.
   ```bash
   flutter run -d chrome
   ```

## 🏗️ Project Structure

The codebase is organized in `lib/` to maximize modularity and separation of concerns:
* `auth/` - Authentication flows and UI components
* `pages/` - Core dashboard structure including the master sidebar
* `pages/views/` - Individual dashboard modules (Attendance, Fraud, Student, Broadcast, etc.)

---
*Developed for the Marooneen Attendance Ecosystem.*
