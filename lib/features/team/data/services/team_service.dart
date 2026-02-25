import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legalease/features/team/data/models/team.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teamsRef => _firestore.collection('teams');
  CollectionReference<Map<String, dynamic>> get _membersRef => _firestore.collection('team_members');
  CollectionReference<Map<String, dynamic>> get _documentsRef => _firestore.collection('team_documents');

  Future<Team> createTeam({
    required String name,
    String? description,
    required String ownerId,
    required String ownerName,
  }) async {
    final team = Team(
      id: '',
      name: name,
      description: description,
      ownerId: ownerId,
      ownerName: ownerName,
      createdAt: DateTime.now(),
    );

    final docRef = await _teamsRef.add(team.toJson());

    await _membersRef.add({
      'teamId': docRef.id,
      'userId': ownerId,
      'displayName': ownerName,
      'email': '',
      'role': 'admin',
      'joinedAt': DateTime.now().toIso8601String(),
    });

    return team.copyWith(id: docRef.id);
  }

  Future<void> updateTeam(Team team) async {
    await _teamsRef.doc(team.id).update({
      ...team.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTeam(String teamId) async {
    final members = await _membersRef.where('teamId', isEqualTo: teamId).get();
    for (final doc in members.docs) {
      await doc.reference.delete();
    }

    final documents = await _documentsRef.where('teamId', isEqualTo: teamId).get();
    for (final doc in documents.docs) {
      await doc.reference.delete();
    }

    await _teamsRef.doc(teamId).delete();
  }

  Future<List<Team>> getUserTeams(String userId) async {
    final memberSnapshot = await _membersRef.where('userId', isEqualTo: userId).get();
    
    if (memberSnapshot.docs.isEmpty) return [];

    final teamIds = memberSnapshot.docs.map((doc) => doc.data()['teamId'] as String).toList();
    
    final teams = <Team>[];
    for (final teamId in teamIds) {
      final doc = await _teamsRef.doc(teamId).get();
      if (doc.exists) {
        teams.add(Team.fromJson({'id': doc.id, ...doc.data()!}));
      }
    }

    return teams;
  }

  Stream<List<Team>> watchUserTeams(String userId) {
    return _membersRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((memberSnapshot) async {
      if (memberSnapshot.docs.isEmpty) return [];

      final teamIds = memberSnapshot.docs.map((doc) => doc.data()['teamId'] as String).toList();
      
      final teams = <Team>[];
      for (final teamId in teamIds) {
        final doc = await _teamsRef.doc(teamId).get();
        if (doc.exists) {
          teams.add(Team.fromJson({'id': doc.id, ...doc.data()!}));
        }
      }

      return teams;
    });
  }

  Future<Team?> getTeam(String teamId) async {
    final doc = await _teamsRef.doc(teamId).get();
    if (!doc.exists) return null;
    return Team.fromJson({'id': doc.id, ...doc.data()!});
  }

  Future<void> inviteMember({
    required String teamId,
    required String email,
    required TeamRole role,
    required String invitedBy,
  }) async {
    await _firestore.collection('team_invitations').add({
      'teamId': teamId,
      'email': email,
      'role': role.name,
      'invitedBy': invitedBy,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<List<TeamMember>> getTeamMembers(String teamId) async {
    final snapshot = await _membersRef.where('teamId', isEqualTo: teamId).get();
    return snapshot.docs
        .map((doc) => TeamMember.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Stream<List<TeamMember>> watchTeamMembers(String teamId) {
    return _membersRef
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TeamMember.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Future<void> updateMemberRole(String memberId, TeamRole newRole) async {
    await _membersRef.doc(memberId).update({'role': newRole.name});
  }

  Future<void> removeMember(String memberId) async {
    await _membersRef.doc(memberId).delete();
  }

  Future<void> shareDocument({
    required String teamId,
    required String documentId,
    required String title,
    required String uploadedBy,
    required String uploadedByName,
    int redFlagCount = 0,
  }) async {
    await _documentsRef.add({
      'teamId': teamId,
      'documentId': documentId,
      'title': title,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'uploadedAt': FieldValue.serverTimestamp(),
      'redFlagCount': redFlagCount,
      'status': 'shared',
    });

    await _teamsRef.doc(teamId).update({
      'documentCount': FieldValue.increment(1),
    });
  }

  Future<List<TeamDocument>> getTeamDocuments(String teamId) async {
    final snapshot = await _documentsRef
        .where('teamId', isEqualTo: teamId)
        .orderBy('uploadedAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => TeamDocument.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Stream<List<TeamDocument>> watchTeamDocuments(String teamId) {
    return _documentsRef
        .where('teamId', isEqualTo: teamId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TeamDocument.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Future<void> removeDocument(String documentId) async {
    await _documentsRef.doc(documentId).delete();
  }
}