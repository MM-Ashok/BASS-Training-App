import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/programme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/programme_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'attendance_screen.dart';
import 'feedback_journal_screen.dart';

enum SessionPickerMode { attendance, feedback }

/// Entry point for the dashboard's "Attendance" / "Feedback Journal"
/// tiles — both features are scoped to a single session, so this screen
/// lets a coach pick programme → session (→ trainee, for feedback)
/// before landing on the actual screen. Without this, those tiles had
/// nowhere to navigate to.
class SessionPickerScreen extends StatefulWidget {
  final SessionPickerMode mode;
  const SessionPickerScreen({super.key, required this.mode});

  @override
  State<SessionPickerScreen> createState() => _SessionPickerScreenState();
}

class _SessionPickerScreenState extends State<SessionPickerScreen> {
  Programme? _selectedProgramme;

  @override
  void initState() {
    super.initState();
    final orgId =
        context.read<AuthProvider>().currentUser?.organisationId ?? AppConstants.demoOrganisationId;
    context.read<ProgrammeProvider>().init(orgId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgrammeProvider>();
    final title = widget.mode == SessionPickerMode.attendance
        ? 'Mark Attendance'
        : 'Feedback Journal';

    if (_selectedProgramme == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: provider.programmes.isEmpty
            ? Center(
                child: Text('No programmes yet — create one first',
                    style: TextStyle(color: Colors.grey[600])))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.programmes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = provider.programmes[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_view_month, color: AppTheme.primary),
                      title: Text(p.title),
                      subtitle: const Text('Choose a session from this programme'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.read<ProgrammeProvider>().selectProgramme(p.id);
                        setState(() => _selectedProgramme = p);
                      },
                    ),
                  );
                },
              ),
      );
    }

    final dateFmt = DateFormat('EEE MMM d · HH:mm');
    final sessions = provider.sessions;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedProgramme!.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedProgramme = null),
        ),
      ),
      body: sessions.isEmpty
          ? Center(
              child: Text('No sessions scheduled in this programme yet',
                  style: TextStyle(color: Colors.grey[600])))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = sessions[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event, color: AppTheme.primary),
                    title: Text(s.title),
                    subtitle: Text(dateFmt.format(s.startTime)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (widget.mode == SessionPickerMode.attendance) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AttendanceScreen(
                              programme: _selectedProgramme!,
                              sessionId: s.id,
                              sessionTitle: s.title,
                            ),
                          ),
                        );
                      } else {
                        _pickTraineeThenOpenFeedback(context, s.id, s.title);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  void _pickTraineeThenOpenFeedback(BuildContext context, String sessionId, String sessionTitle) {
    final roster = _selectedProgramme!.traineeIds.isEmpty
        ? ['demo-trainee-1', 'demo-trainee-2', 'demo-trainee-3']
        : _selectedProgramme!.traineeIds;

    if (roster.length == 1) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => FeedbackJournalScreen(
          programmeId: _selectedProgramme!.id,
          sessionId: sessionId,
          traineeId: roster.first,
          traineeName: roster.first,
        ),
      ));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select trainee', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...roster.map((traineeId) => ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(traineeId),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FeedbackJournalScreen(
                        programmeId: _selectedProgramme!.id,
                        sessionId: sessionId,
                        traineeId: traineeId,
                        traineeName: traineeId,
                      ),
                    ));
                  },
                )),
          ],
        ),
      ),
    );
  }
}
