import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/team/data/models/team.dart';
import 'package:legalease/features/team/data/services/team_service.dart';
import 'package:legalease/features/auth/domain/providers/providers.dart';

final teamServiceProvider = Provider<TeamService>((ref) {
  return TeamService();
});

final userTeamsProvider = FutureProvider<List<Team>>((ref) async {
  final service = ref.watch(teamServiceProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return [];
  return service.getUserTeams(user.uid);
});

final userTeamsStreamProvider = StreamProvider<List<Team>>((ref) {
  final service = ref.watch(teamServiceProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value([]);
  return service.watchUserTeams(user.uid);
});

final teamProvider = FutureProvider.family<Team?, String>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  return service.getTeam(teamId);
});

final teamMembersProvider = FutureProvider.family<List<TeamMember>, String>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  return service.getTeamMembers(teamId);
});

final teamMembersStreamProvider = StreamProvider.family<List<TeamMember>, String>((ref, teamId) {
  final service = ref.watch(teamServiceProvider);
  return service.watchTeamMembers(teamId);
});

final teamDocumentsProvider = FutureProvider.family<List<TeamDocument>, String>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  return service.getTeamDocuments(teamId);
});

final teamDocumentsStreamProvider = StreamProvider.family<List<TeamDocument>, String>((ref, teamId) {
  final service = ref.watch(teamServiceProvider);
  return service.watchTeamDocuments(teamId);
});

final selectedTeamProvider = StateProvider<Team?>((ref) => null);

final isTeamAdminProvider = Provider.family<bool, String>((ref, teamId) {
  final membersAsync = ref.watch(teamMembersProvider(teamId));
  final user = ref.watch(authStateChangesProvider).value;
  
  return membersAsync.when(
    data: (members) {
      final member = members.firstWhere(
        (m) => m.userId == user?.uid,
        orElse: () => members.first,
      );
      return member.isAdmin;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
