# BASS Training App

A role-based training management application built with Flutter, using Firebase Authentication and Cloud Firestore as the primary backend. BASS Training helps coaching organizations manage programmes, phases, sessions, tasks, attendance, feedback, and trainee experience tracking through a single mobile application.

## Table of Contents

- [About](#about)
- [Tech Stack](#tech-stack)
- [User Roles](#user-roles)
- [Core Training Hierarchy](#core-training-hierarchy)
- [Features](#features)
  - [Authentication & Account Flow](#authentication--account-flow)
  - [Dashboards](#dashboards)
  - [User Management](#user-management)
  - [Programme Management](#programme-management)
  - [Phase Management](#phase-management)
  - [Session Management](#session-management)
  - [Task Management](#task-management)
  - [Attendance Management](#attendance-management)
  - [Coach Feedback / Skill Assessment](#coach-feedback--skill-assessment)
  - [Trainee Experience / 70-Hour Tracking](#trainee-experience--70-hour-tracking)
  - [Messaging](#messaging)
- [Firestore Data Structure](#firestore-data-structure)
- [Permissions Overview](#permissions-overview)
- [Known Limitations / In-Progress Areas](#known-limitations--in-progress-areas)
- [Getting Started](#getting-started)

## About

BASS Training is built around a nested training hierarchy — **Programme → Phase → Session → Task** — with supporting records for attendance, coach feedback, and trainee experience. The app uses **Riverpod** for state and provider management and **Material 3** for UI.

## Tech Stack

- **Framework:** Flutter / Dart (Material 3 UI)
- **State Management:** Riverpod
- **Authentication:** Firebase Authentication (email/password)
- **Database:** Cloud Firestore
- **Storage:** Firebase Storage (profile photo uploads)
- **Messaging:** Firebase Cloud Messaging (dependency included)

## User Roles

| Role | Description |
|---|---|
| **Super Admin** | Full system administration |
| **Head Coach** | Manages users and training programmes at head-coach level |
| **Coach** | Works with programmes/training content and communicates with users |
| **Trainee** | Views personal training experience, communication, and profile |

## Core Training Hierarchy

```
Programme
 └── Phase
      └── Session
           ├── Task
           ├── Attendance
           └── Feedback

Trainee
 └── Experience
```

- **Programme** — top-level training programme/season with dates and lifecycle status.
- **Phase** — an ordered subdivision of a programme with dates and status.
- **Session** — a scheduled training session within a phase, assigned to a coach.
- **Task** — an item within a session with category, due date, and verification/review settings.
- **Attendance** — attendance recorded against a trainee for a specific session.
- **Feedback** — coach feedback recorded against a trainee for a specific session (rating + skills).
- **Experience** — a trainee's training-hours record, including location, coach notes, and approval status.

## Features

### Authentication & Account Flow

- Splash screen checks Firebase Authentication for an existing signed-in user.
- Unauthenticated users are routed to the Login screen.
- Authenticated users have their Firestore user profile loaded, and are routed into a role-specific navigation shell (`superAdmin`, `headCoach`, `coach`, `trainee`).
- Login supports email/password auth with error display.
- Forgot Password sends a password-reset email.
- Registration creates an auth account and matching user profile.
- Logout is available from role dashboards / profile flow.

### Dashboards

**Super Admin**
- Live counts for total users, coaches, trainees, and programmes.
- Navigation to Manage Users and Manage Programmes.
- Sessions entry point currently requires selecting a Programme and Phase first (no global session view yet).
- Reports & Analytics entry point present but not yet implemented.
- Messages and Logout navigation.

**Head Coach**
- Summary cards and schedule-style content.
- Navigation concepts for coaches, trainees, sessions, programmes, and pending tasks.
- Programme navigation wired to the programme list with edit enabled, delete disabled.
- Some dashboard values are currently static rather than live-calculated.

**Coach**
- Welcome area, summary cards, and today's schedule.
- Concepts for My Trainees, Sessions Today, My Tasks, and Attendance.
- Dashboard metrics and schedule are currently hard-coded sample values.
- Drawer entries for My Trainees, Sessions, and Tasks exist visually but are not yet wired to actions.

**Trainee**
- Summary cards for sessions, tasks, progress, and attendance.
- Sample schedule content.
- My Attendance opens the attendance history screen.
- My Sessions and My Tasks are currently placeholders.
- Experience tab is currently a placeholder screen.

### User Management

- Live list of Firestore users with search by name/email.
- Filter by role (All, Super Admin, Head Coach, Coach, Trainee).
- User detail screen showing role, programme assignment, and active/inactive status.
- Activate/deactivate users, change role, delete user profile.
- Create new user profile records (name, email, role).

### Programme Management

- Live Firestore stream listing.
- Create with name, description, season, start/end date, and status.
- Status options: `Draft`, `Active`, `Completed`.
- View, edit, delete (permission-dependent).
- Links to phase management.

### Phase Management

- Belongs to a programme; listed in order.
- Create with title, description, order, start/end date, and status (`Draft`, `Active`, `Completed`).
- View, edit, delete (permission-dependent).
- Links to session management.

### Session Management

- Belongs to a programme and phase.
- Create with title, description, coach name, date, start/end time, and status (`Draft`, `Scheduled`, `Completed`).
- Listed in date order.
- Edit/delete controls are permission-driven.
- Links to Tasks, Attendance, and Feedback, plus trainee selection/experience functionality.

### Task Management

- Belongs to a session.
- Create with title, description, category, status, and due date.
- Categories: `Technique`, `Fitness`, `Safety`, `Assessment`, `Theory`, `Other`.
- Statuses: `Pending`, `In Progress`, `Completed`.
- Toggle Auto Verify and Coach Review Required.
- Stores `createdBy` and `assignedTo`.
- Listed in due-date order.

### Attendance Management

- Belongs to a session; listed live.
- Mark Attendance form creates a record.
- Status values: `Present`, `Late`, `Excused`, `Absent`.
- Stores trainee, status, check-in time, notes, `markedBy`, and `markedAt`.
- Trainees see a My Attendance screen with a calculated attendance percentage.

### Coach Feedback / Skill Assessment

- Belongs to a session.
- Coach selects a trainee from active trainees assigned to the programme.
- Feedback includes title, free-text feedback, and a 1–5 star rating.
- Skill tags: `Balance`, `Edge Control`, `Turning`, `Carving`, `Pole Plant`, `Parallel Turns`, `Snowplough`, `Speed Control`, `Confidence`, `Safety Awareness`.
- Ordered by creation date; view/edit/delete per permission flags.

### Trainee Experience / 70-Hour Tracking

- Stored per trainee.
- Create with trainee, session title, hours, location, coach notes, date, and status.
- Status workflow: `Pending` / `Approved` / `Rejected`.
- Newest records listed first.
- Approved hours are summed from `Approved` records.
- Remaining hours and completion percentage are calculated against a **70-hour** target (`approved hours / 70 × 100`).

### Messaging

- Messages/Conversations screen; New Message screen lists other users.
- Conversation ID deterministically generated from sorted user IDs.
- Conversation document stores participants, `lastMessage`, and `updatedAt`.
- Messages store sender/receiver, text, attachment URL, read state, and sent time, displayed chronologically.
- Messages can be marked as read; update/delete service methods exist.
- Conversation list filtered to the current user's conversations, ordered by latest activity.

## Firestore Data Structure

```
users/{userId}
users/{traineeId}/experience/{experienceId}

programmes/{programmeId}
programmes/{programmeId}/phases/{phaseId}
programmes/{programmeId}/phases/{phaseId}/sessions/{sessionId}
programmes/{programmeId}/phases/{phaseId}/sessions/{sessionId}/tasks/{taskId}
programmes/{programmeId}/phases/{phaseId}/sessions/{sessionId}/attendance/{attendanceId}
programmes/{programmeId}/phases/{phaseId}/sessions/{sessionId}/feedback/{feedbackId}

conversations/{conversationId}/messages/{messageId}
```

## Permissions Overview

**Programme Management**

| Role | Create / List | Edit | Delete |
|---|---|---|---|
| Super Admin | Yes | Yes | Yes |
| Head Coach | Yes / List | Yes | No |
| Coach | List | No | No |
| Trainee | No | No | No |

Edit/delete permissions for phases, sessions, tasks, attendance, and feedback are similarly permission-driven based on role.

## Known Limitations / In-Progress Areas

- Super Admin's Reports & Analytics screen is not yet implemented.
- Super Admin Sessions entry requires manual Programme/Phase selection rather than a global session view.
- Head Coach and Coach dashboards show static/hard-coded sample metrics rather than live-calculated values.
- Coach drawer entries (My Trainees, Sessions, Tasks) are visually present but not yet wired to actions.
- Trainee My Sessions, My Tasks, and Experience tab are currently placeholder screens.

## Getting Started

### Prerequisites

- Flutter SDK installed
- A configured Firebase project (Authentication, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging)
- `google-services.json` / `GoogleService-Info.plist` added for your platform(s)

### Installation

```bash
git clone <repository-url>
cd bass-training-app
flutter pub get
```

### Firebase Setup

1. Create a Firebase project and enable **Authentication** (email/password), **Cloud Firestore**, and **Firebase Storage**.
2. Add your platform apps (Android/iOS/Web) in the Firebase console.
3. Download and place the platform config files in the appropriate directories.
4. Run `flutterfire configure` if using FlutterFire CLI to generate `firebase_options.dart`.

### Run the App

```bash
flutter run
```

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
