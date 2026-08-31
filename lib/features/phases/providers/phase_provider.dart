import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/phase_model.dart';
import '../services/phase_service.dart';

final phaseServiceProvider = Provider<PhaseService>((ref) {
  return PhaseService();
});

final phasesProvider =
    StreamProvider.family<List<PhaseModel>, String>((ref, programmeId) {
  return ref.read(phaseServiceProvider).getPhases(programmeId);
});

class PhaseParams {
  final String programmeId;
  final String phaseId;

  const PhaseParams({
    required this.programmeId,
    required this.phaseId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseParams &&
          programmeId == other.programmeId &&
          phaseId == other.phaseId;

  @override
  int get hashCode => Object.hash(programmeId, phaseId);
}

final phaseProvider =
    StreamProvider.family<PhaseModel?, PhaseParams>((ref, params) {
  return ref.read(phaseServiceProvider).getPhaseStream(
        params.programmeId,
        params.phaseId,
      );
});