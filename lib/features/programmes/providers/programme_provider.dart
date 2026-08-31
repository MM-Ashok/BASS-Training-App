import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/programme_model.dart';
import '../services/programme_service.dart';

/// Service Provider
final programmeServiceProvider = Provider<ProgrammeService>((ref) {
  return ProgrammeService();
});

/// Stream of all programmes
final programmesProvider =
    StreamProvider<List<ProgrammeModel>>((ref) {
  final service = ref.watch(programmeServiceProvider);

  return service.getProgrammes();
});