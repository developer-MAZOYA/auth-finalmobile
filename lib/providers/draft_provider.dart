import 'package:flutter/foundation.dart';

class DraftReport {
  final String id;
  final String projectName;
  final DateTime createdDate;
  final String description;

  DraftReport({
    required this.id,
    required this.projectName,
    required this.createdDate,
    required this.description,
  });
}

class DraftProvider with ChangeNotifier {
  List<DraftReport> _drafts = [
    DraftReport(
      id: '1',
      projectName: 'Road Construction',
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Daily site inspection report',
    ),
    DraftReport(
      id: '2',
      projectName: 'School Renovation',
      createdDate: DateTime.now().subtract(const Duration(hours: 5)),
      description: 'Progress update with photos',
    ),
  ];

  List<DraftReport> get drafts => _drafts;
  int get draftCount => _drafts.length;

  void addDraft(DraftReport draft) {
    _drafts.add(draft);
    notifyListeners();
  }

  void removeDraft(String id) {
    _drafts.removeWhere((draft) => draft.id == id);
    notifyListeners();
  }

  Future<void> syncAllDrafts() async {
    // Simulate API call to sync drafts
    await Future.delayed(const Duration(seconds: 2));
    _drafts.clear();
    notifyListeners();
  }

  Future<void> syncDraft(String id) async {
    // Simulate API call to sync single draft
    await Future.delayed(const Duration(seconds: 1));
    _drafts.removeWhere((draft) => draft.id == id);
    notifyListeners();
  }
}
