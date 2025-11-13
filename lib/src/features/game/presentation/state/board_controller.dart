import 'package:flutter/foundation.dart';

import '../../domain/entities/game_session.dart';
import '../../domain/entities/tile.dart';
import 'game_notifier.dart';

class BoardController extends ChangeNotifier {
  BoardController(this._notifier);

  final GameNotifier _notifier;

  GameSession? _attachedSession;
  int? _selectedTileIndex;

  GameSession? get session => _notifier.state.session;

  int? get selectedTileIndex => _selectedTileIndex;

  bool get hasSelection => _selectedTileIndex != null;

  bool get isLocked => _notifier.state.showResults;

  void attachSession(GameSession? session) {
    if (session == null) {
      _attachedSession = null;
      if (_selectedTileIndex != null) {
        _selectedTileIndex = null;
        notifyListeners();
      }
      return;
    }

    if (_attachedSession?.level.id != session.level.id) {
      _attachedSession = session;
      if (_selectedTileIndex != null) {
        _selectedTileIndex = null;
        notifyListeners();
      }
      return;
    }

    _attachedSession = session;
  }

  bool isTileSelected(int index) => _selectedTileIndex == index;

  void handleTap(int index) {
    final GameSession? session = this.session;
    if (session == null || isLocked) {
      return;
    }

    final Tile tile = session.board.tileAt(index);
    if (tile.isAnchor) {
      return;
    }

    if (_selectedTileIndex == index) {
      _selectedTileIndex = null;
      notifyListeners();
      return;
    }

    if (_selectedTileIndex != null) {
      final int from = _selectedTileIndex!;
      _selectedTileIndex = null;
      notifyListeners();
      _notifier.swapTiles(from, index);
      return;
    }

    _selectedTileIndex = index;
    notifyListeners();
  }

  void swap(int fromIndex, int toIndex) {
    if (isLocked) {
      return;
    }

    final GameSession? session = this.session;
    if (session == null) {
      return;
    }

    final Tile fromTile = session.board.tileAt(fromIndex);
    final Tile toTile = session.board.tileAt(toIndex);
    if (fromTile.isAnchor || toTile.isAnchor) {
      return;
    }

    if (_selectedTileIndex != null) {
      _selectedTileIndex = null;
      notifyListeners();
    }

    _notifier.swapTiles(fromIndex, toIndex);
  }

  void clearSelection() {
    if (_selectedTileIndex == null) {
      return;
    }
    _selectedTileIndex = null;
    notifyListeners();
  }
}
