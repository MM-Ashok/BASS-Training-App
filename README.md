# BASS Training App — Flutter Scaffold

A Flutter/Firebase codebase for the BASS multi-role training academy
platform, covering every feature area in the project brief with working
logic and screens. This is a strong build-ready foundation — not
device-tested, store-submitted, production-polished software. Read
"What still needs real dev time" below before treating anything here as
launch-ready.

## What's implemented

- **Data models** for all four roles, programmes, phases, sessions, task
  library, ski hours, feedback journal, attendance/engagement, messaging,
  and org branding.
- **Firestore data model** — org-scoped multi-tenant structure supporting
  white-label licensing (`lib/services/firestore_paths.dart`).
- **Programme builder** — full create/edit/delete for programmes, phases
  (drag-reorder), and sessions.
- **Task library** — auto-verified and coach-reviewed tasks, trainee
  submission flow, coach approval queue.
- **70-hour Ski School Experience tracker** — weighted pace calculation
  engine (`lib/services/pace_calculation_service.dart`) with a dashboard
  screen: progress bar, pace status, activity breakdown chart.
- **Session feedback journal** — coach and self-reflection entries,
  skills-framework tagging, voice-to-text dictation (`speech_to_text`),
  and a cross-reference view filtering a trainee's whole history by skill
  tag (`lib/screens/shared/feedback_journal_screen.dart`,
  `trainee_feedback_history_screen.dart`).
- **Attendance tracking** — coach check-in screen per session, trainee
  history view, feeds directly into engagement scoring.
- **Engagement scoring** — composite score from real attendance, task
  completion, and coach responsiveness (measured from actual
  submittedAt→reviewedAt gaps on task completions, not a placeholder).
  Live squad-wide view for Head Coach (`squad_engagement_screen.dart`).
- **Messaging** — team channels, one-way programme broadcasts (posting
  restricted to Head Coach/Super Admin), and DMs, with a channel list and
  chat screen.
- **Offline functionality** — outbox write-queue pattern
  (`lib/services/offline_service.dart`), wired end-to-end: attendance
  writes route through it when offline, queue optimistically updates the
  UI, and `main.dart` replays the queue against Firestore once
  connectivity returns. Other write paths still write directly to
  Firestore and rely on the Firestore SDK's own offline cache — extending
  the explicit queue to those is straightforward following the
  `AttendanceProvider` pattern.
- **End-of-season PDF and XLSX reporting** — wired to real ski-hours,
  task, and attendance data with a report-preview screen and native
  share sheet (`season_report_screen.dart`).
- **White-label architecture** — per-organisation branding (app name,
  primary/accent color, logo URL) stored in Firestore, loaded at runtime
  by `BrandingProvider`, editable via a Super Admin settings screen
  (`branding_settings_screen.dart`). Swapping a licensee's look is a data
  change, not a rebuild.
- Role-based routing (Super Admin / Head Coach / Coach / Trainee).
- Firestore security rules draft (`firestore.rules`) matching the data
  model, including notes on collectionGroup query coverage.

## What still needs real dev time before this is a shippable app

- **Device/SDK validation** — this was built without a Flutter SDK
  available in the build environment, so it has not been run through
  `flutter analyze`, `flutter pub get`, or an emulator. Expect to fix a
  handful of minor type/import issues on first build.
- **User management screen** — Super Admin can theoretically provision
  users via `AuthService.createUser`, but there's no UI for it yet.
- **Roster-aware feedback/attendance** — session screens currently assume
  a simple trainee list (`programme.traineeIds`); a real roster
  picker/multi-select UI is still needed for sessions with several
  trainees.
- **Full offline write coverage** — only attendance currently
  demonstrates the outbox queue end-to-end; task submissions, feedback
  entries, ski-hours logs, and chat messages still write directly to
  Firestore (safe online, but not queued if offline — Firestore's cache
  handles reads offline regardless).
- **Push notifications** — Cloud Messaging is a dependency, not yet
  configured.
- **Programme-linked ski hours target dates** — the 70-hour tracker and
  season report currently use a placeholder programme date window;
  wire to the trainee's actual assigned programme once that relationship
  is finalized in the UI.
- **App Store / Play Store submission assets and automated tests.**

## Getting it running

1. Install Flutter (stable channel) — https://docs.flutter.dev/get-started/install
2. `flutter pub get`
3. **Firebase setup** (required before the app will do anything beyond
   showing the login screen):
   - Create a Firebase project in the console
   - Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
   - Run `flutterfire configure` from the project root — this generates
     `lib/firebase_options.dart` (intentionally gitignored/not included
     here since it's tied to a specific Firebase project)
   - Enable Email/Password auth in Firebase Console → Authentication
   - Create a Firestore database (production mode)
   - Deploy `firestore.rules`: `firebase deploy --only firestore:rules`
     (requires `firebase-tools`: `npm install -g firebase-tools`)
   - Add the composite/collectionGroup indexes Firestore will prompt for
     the first time you run the attendance-history, feedback-history, and
     squad-engagement screens (Firestore's error message includes a
     direct "create index" link — click it).
4. Since sign-up is invite-only by design (see `AuthService.createUser`),
   manually seed one Super Admin user for first login — either via the
   Firebase Console (Authentication tab, add user) plus a matching
   Firestore doc at `organisations/demo-org/users/{uid}`, or write a
   one-off script calling `AuthService.createUser(...)`.
5. `flutter run`

## Project structure

```
lib/
  models/       Data models (User, Programme, Phase, Session, Task,
                SkiHours, Feedback, Attendance, Message, Branding)
  services/     Firestore access, auth, pace calc, engagement scoring,
                offline sync, PDF/XLSX export, branding
  providers/    State management (Provider/ChangeNotifier)
  screens/      UI, organised by role + shared screens
  widgets/      Shared UI components
  utils/        Theme, constants
firestore.rules Security rules draft
```

## Next steps

If this looks like the right foundation, the natural next steps are:
(1) feed it into Primio as the starting codebase per your brief, or
(2) have a developer run through the "still needs real dev time" list
above directly against a live Firebase project and real devices. The
data model and the pace/engagement calculation logic should hold up as
the backbone either way.
