import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Pengelola Database SQLite lokal perangkat untuk mendukung kemampuan Offline-First.
class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase();
  static const String _dbName = 'super_i_mobile.db';
  static const int _dbVersion = 2;

  Database? _database;

  /// Getter untuk memastikan koneksi database sudah terbuka sebelum dipakai
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Membuat tabel-tabel draft saat database pertama kali dibuat di HP
  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabel draft pekerjaan Line Walker (PPL, Pembumian, Waterpass)
    await db.execute('''
      CREATE TABLE unfinish_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT
      )
    ''');

    // 2. Tabel draft pekerjaan Gardu Induk 20kV (Beban, IL1, Manuver, Anomali)
    await db.execute('''
      CREATE TABLE unfinished_items_gi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        periode INTEGER NOT NULL,
        data TEXT
      )
    ''');

    // 3. Tabel draft inspeksi pemeliharaan distribusi SUTM
    await db.execute('''
      CREATE TABLE sutm_drafts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        work_order_sutm_item_id TEXT NOT NULL UNIQUE,
        data TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now', 'localtime')),
        updated_at TEXT DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // 4. Tabel cache respon GET API
    await _createCacheTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createCacheTable(db);
    }
  }

  Future<void> _createCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS api_cache (
        key TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        ttl_seconds INTEGER NOT NULL
      )
    ''');
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. LINE WALKER UNFINISHED ITEMS
  // ═══════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> addUnfinishItem({
    required String nama,
    required String date,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    final existing = await db.query(
      'unfinish_items',
      columns: ['id'],
      where: 'nama = ? AND type = ?',
      whereArgs: [nama, type],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.update(
        'unfinish_items',
        {
          'date': date,
          'data': jsonEncode(data),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return {'updated': true, 'id': id};
    }

    final id = await db.insert('unfinish_items', {
      'nama': nama,
      'date': date,
      'type': type,
      'data': jsonEncode(data),
    });
    return {'updated': false, 'id': id};
  }

  Future<List<Map<String, dynamic>>> getUnfinishItems({String? type}) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'unfinish_items',
      where: type != null ? 'type = ?' : null,
      whereArgs: type != null ? [type] : null,
      orderBy: 'id DESC',
    );

    return result.map((row) {
      final dataStr = row['data'] as String?;
      Map<String, dynamic> parsedData = {};
      if (dataStr != null && dataStr.isNotEmpty) {
        try {
          parsedData = jsonDecode(dataStr) as Map<String, dynamic>;
        } catch (_) {}
      }
      return {
        ...row,
        'data': parsedData,
      };
    }).toList();
  }

  Future<int> removeUnfinishItem(int id) async {
    final db = await database;
    return await db.delete(
      'unfinish_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> insertUnfinishItem(Map<String, dynamic> row) async {
    dynamic data = row['data'];
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        data = {'raw': data};
      }
    }
    return addUnfinishItem(
      nama: row['nama']?.toString() ?? '',
      date: row['date']?.toString() ?? DateTime.now().toIso8601String(),
      type: row['type']?.toString() ?? 'draft',
      data: data is Map<String, dynamic> ? data : {},
    );
  }

  Future<int> deleteUnfinishItem(int id) async {
    return removeUnfinishItem(id);
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. OPGI 20kV UNFINISHED ITEMS
  // ═══════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> addUnfinishItemGi({
    required String nama,
    required String date,
    required String type,
    required int periode,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    final existing = await db.query(
      'unfinished_items_gi',
      columns: ['id'],
      where: 'nama = ? AND type = ? AND periode = ?',
      whereArgs: [nama, type, periode],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.update(
        'unfinished_items_gi',
        {
          'date': date,
          'data': jsonEncode(data),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return {'updated': true, 'id': id};
    }

    final id = await db.insert('unfinished_items_gi', {
      'nama': nama,
      'date': date,
      'type': type,
      'periode': periode,
      'data': jsonEncode(data),
    });
    return {'updated': false, 'id': id};
  }

  Future<List<Map<String, dynamic>>> getUnfinishItemGi({
    int? id,
    String? nama,
    String? date,
    String? type,
    int? periode,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (id != null) {
      conditions.add('id = ?');
      args.add(id);
    }
    if (nama != null && nama.isNotEmpty) {
      conditions.add('nama LIKE ?');
      args.add('%$nama%');
    }
    if (date != null && date.isNotEmpty) {
      conditions.add('date = ?');
      args.add(date);
    }
    if (type != null && type.isNotEmpty) {
      conditions.add('type = ?');
      args.add(type);
    }
    if (periode != null) {
      conditions.add('periode = ?');
      args.add(periode);
    }

    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    final result = await db.query(
      'unfinished_items_gi',
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'id DESC',
    );

    return result.map((row) {
      final dataStr = row['data'] as String?;
      Map<String, dynamic> parsedData = {};
      if (dataStr != null && dataStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(dataStr);
          if (decoded is Map) {
            parsedData = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }
      return {
        ...row,
        'data': parsedData,
      };
    }).toList();
  }

  Future<int> removeFinishedItemGi(int id) async {
    final db = await database;
    return await db.delete(
      'unfinished_items_gi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearUnfinishedItemsGi() async {
    final db = await database;
    return await db.delete('unfinished_items_gi');
  }

  Future<int> deleteUnfinishedItemsByType(String type) async {
    final db = await database;
    return await db.delete(
      'unfinished_items_gi',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<List<Map<String, dynamic>>> getUnfinishedItemsGI({
    int? id,
    String? nama,
    String? date,
    String? type,
    int? periode,
  }) async {
    return getUnfinishItemGi(
      id: id,
      nama: nama,
      date: date,
      type: type,
      periode: periode,
    );
  }

  Future<Map<String, dynamic>> insertUnfinishedItemGI(Map<String, dynamic> row) async {
    dynamic data = row['data'];
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        data = {'raw': data};
      }
    }
    return addUnfinishItemGi(
      nama: row['nama']?.toString() ?? '',
      date: row['date']?.toString() ?? DateTime.now().toIso8601String(),
      type: row['type']?.toString() ?? 'gi_draft',
      periode: (row['periode'] is int)
          ? row['periode'] as int
          : int.tryParse(row['periode']?.toString() ?? '1') ?? 1,
      data: data is Map<String, dynamic> ? data : {},
    );
  }

  Future<int> deleteUnfinishedItemGI(int id) async {
    return removeFinishedItemGi(id);
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. SUTM DRAFTS
  // ═══════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> saveSutmDraft({
    required String workOrderSutmItemId,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    final existing = await db.query(
      'sutm_drafts',
      columns: ['id'],
      where: 'work_order_sutm_item_id = ?',
      whereArgs: [workOrderSutmItemId],
      limit: 1,
    );

    final now = DateTime.now().toIso8601String();
    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.update(
        'sutm_drafts',
        {
          'data': jsonEncode(data),
          'updated_at': now,
        },
        where: 'work_order_sutm_item_id = ?',
        whereArgs: [workOrderSutmItemId],
      );
      return {'updated': true, 'id': id};
    }

    final id = await db.insert('sutm_drafts', {
      'work_order_sutm_item_id': workOrderSutmItemId,
      'data': jsonEncode(data),
      'created_at': now,
      'updated_at': now,
    });
    return {'updated': false, 'id': id};
  }

  Future<Map<String, dynamic>?> getSutmDraft(String workOrderSutmItemId) async {
    final db = await database;
    final result = await db.query(
      'sutm_drafts',
      where: 'work_order_sutm_item_id = ?',
      whereArgs: [workOrderSutmItemId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    final dataStr = result.first['data'] as String?;
    if (dataStr == null || dataStr.isEmpty) return null;
    try {
      return jsonDecode(dataStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllSutmDrafts() async {
    final db = await database;
    final result = await db.query(
      'sutm_drafts',
      orderBy: 'updated_at DESC',
    );

    return result.map((row) {
      final dataStr = row['data'] as String?;
      Map<String, dynamic> parsedData = {};
      if (dataStr != null && dataStr.isNotEmpty) {
        try {
          parsedData = jsonDecode(dataStr) as Map<String, dynamic>;
        } catch (_) {}
      }
      return {
        'id': row['id'],
        'workOrderSutmItemId': row['work_order_sutm_item_id'],
        'createdAt': row['created_at'],
        'updatedAt': row['updated_at'],
        'data': parsedData,
      };
    }).toList();
  }

  Future<int> deleteSutmDraft(String workOrderSutmItemId) async {
    final db = await database;
    return await db.delete(
      'sutm_drafts',
      where: 'work_order_sutm_item_id = ?',
      whereArgs: [workOrderSutmItemId],
    );
  }

  Future<int> deleteAllSutmDrafts() async {
    final db = await database;
    return await db.delete('sutm_drafts');
  }

  Future<int> getSutmDraftCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sutm_drafts');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. API GET CACHE (PERSISTENT 24H DEFAULT)
  // ═══════════════════════════════════════════════════════════════

  /// Menyimpan respon GET ke dalam cache SQLite lokal
  Future<void> saveApiCache(
    String key,
    String data, {
    int ttlSeconds = 86400, // Default 24 jam (sesuai TanStack Query di super-i-mobile)
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await db.insert(
      'api_cache',
      {
        'key': key,
        'data': data,
        'cached_at': now,
        'ttl_seconds': ttlSeconds,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mengambil respon cache jika masih berlaku (atau fallback jika ignoreExpiration = true)
  Future<String?> getApiCache(String key, {bool ignoreExpiration = false}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final List<Map<String, dynamic>> results;
    if (ignoreExpiration) {
      results = await db.query(
        'api_cache',
        columns: ['data'],
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
    } else {
      results = await db.query(
        'api_cache',
        columns: ['data'],
        where: 'key = ? AND (cached_at + ttl_seconds) > ?',
        whereArgs: [key, now],
        limit: 1,
      );
    }

    if (results.isNotEmpty) {
      return results.first['data'] as String?;
    }
    return null;
  }

  /// Mengecek apakah cache sudah kadaluarsa atau belum ada
  Future<bool> isApiCacheExpired(String key) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final results = await db.query(
      'api_cache',
      columns: ['cached_at', 'ttl_seconds'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (results.isEmpty) return true;
    final cachedAt = results.first['cached_at'] as int;
    final ttl = results.first['ttl_seconds'] as int;
    return (cachedAt + ttl) <= now;
  }

  /// Menghapus cache spesifik
  Future<int> deleteApiCache(String key) async {
    final db = await database;
    return await db.delete('api_cache', where: 'key = ?', whereArgs: [key]);
  }

  /// Menghapus cache berdasarkan pola URL (misal: '/data/asset/%' saat ada mutasi)
  Future<int> deleteApiCachePattern(String pattern) async {
    final db = await database;
    return await db.delete('api_cache', where: 'key LIKE ?', whereArgs: [pattern]);
  }

  /// Membersihkan seluruh cache API (misal saat logout)
  Future<int> clearApiCache() async {
    final db = await database;
    return await db.delete('api_cache');
  }

  /// Menutup koneksi database saat aplikasi dimatikan
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // OPTIMISTIC API CACHE UPDATES
  // ═══════════════════════════════════════════════════════════════

  /// Optimistis menghapus beban penyulang dari semua baris api_cache terkait
  Future<void> optimisticDeleteBebanPenyulang(int bebanId) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%beban-penyulang%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          // Periksa apakah list berisi penyulang (memiliki key 'beban') atau beban item
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('beban') &&
              (list.first as Map)['beban'] is List) {
            // Main list: List<PenyulangModel>
            for (final p in list) {
              if (p is Map && p['beban'] is List) {
                final bebanList = p['beban'] as List;
                final initialLen = bebanList.length;
                bebanList.removeWhere((b) =>
                    b is Map &&
                    (b['id'] == bebanId || '${b['id']}' == '$bebanId'));
                if (bebanList.length != initialLen) {
                  modified = true;
                }
              }
            }
          } else {
            // Today list: List<BebanTodayItem>
            final initialLen = list.length;
            list.removeWhere((item) =>
                item is Map &&
                (item['id'] == bebanId || '${item['id']}' == '$bebanId'));
            if (list.length != initialLen) {
              modified = true;
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  /// Optimistis memperbarui beban penyulang di semua baris api_cache terkait
  Future<void> optimisticUpdateBebanPenyulang(
    int bebanId,
    Map<String, dynamic> updatedItem,
  ) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%beban-penyulang%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('beban') &&
              (list.first as Map)['beban'] is List) {
            // Main list penyulangs
            for (final p in list) {
              if (p is Map && p['beban'] is List) {
                final bebanList = p['beban'] as List;
                for (int i = 0; i < bebanList.length; i++) {
                  if (bebanList[i] is Map &&
                      (bebanList[i]['id'] == bebanId ||
                          '${bebanList[i]['id']}' == '$bebanId')) {
                    bebanList[i] = {
                      ...bebanList[i] as Map,
                      ...updatedItem,
                    };
                    modified = true;
                  }
                }
              }
            }
          } else {
            // Today list
            for (int i = 0; i < list.length; i++) {
              if (list[i] is Map &&
                  (list[i]['id'] == bebanId ||
                      '${list[i]['id']}' == '$bebanId')) {
                list[i] = {
                  ...list[i] as Map,
                  ...updatedItem,
                };
                modified = true;
              }
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  /// Optimistis menambahkan beban penyulang baru ke baris api_cache terkait
  Future<void> optimisticAddBebanPenyulang(
    int penyulangId,
    Map<String, dynamic> newItem,
  ) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%beban-penyulang%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('beban') &&
              (list.first as Map)['beban'] is List) {
            // Main list: find penyulang with id == penyulangId
            for (final p in list) {
              if (p is Map &&
                  (p['id'] == penyulangId || '${p['id']}' == '$penyulangId')) {
                final bebanList = (p['beban'] as List?) ?? [];
                final exists = bebanList.any((b) =>
                    b is Map &&
                    (b['id'] == newItem['id'] ||
                        (b['periode'] == newItem['periode'] &&
                            b['tanggal'] == newItem['tanggal'])));
                if (!exists) {
                  bebanList.add(newItem);
                  p['beban'] = bebanList;
                  modified = true;
                }
              }
            }
          } else if (key.contains('/today/$penyulangId')) {
            // Today list for this penyulang
            final exists = list.any((b) =>
                b is Map &&
                (b['id'] == newItem['id'] ||
                    (b['periode'] == newItem['periode'] &&
                        b['tanggal'] == newItem['tanggal'])));
            if (!exists) {
              list.add(newItem);
              list.sort((a, b) {
                final pa = a is Map ? (a['periode'] as int? ?? 0) : 0;
                final pb = b is Map ? (b['periode'] as int? ?? 0) : 0;
                return pa.compareTo(pb);
              });
              modified = true;
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. OPTIMISTIC HELPERS: BEBAN TRAFO
  // ═══════════════════════════════════════════════════════════════

  Future<void> optimisticDeleteBebanTrafo(int bebanId) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%beban-trafo%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('beban') &&
              (list.first as Map)['beban'] is List) {
            for (final trafo in list) {
              if (trafo is Map && trafo.containsKey('beban') && trafo['beban'] is List) {
                final bebanList = trafo['beban'] as List;
                final beforeCount = bebanList.length;
                bebanList.removeWhere((item) =>
                    item is Map &&
                    (item['id'] == bebanId || '${item['id']}' == '$bebanId'));
                if (bebanList.length != beforeCount) {
                  modified = true;
                }
              }
            }
          } else {
            final beforeCount = list.length;
            list.removeWhere((item) =>
                item is Map &&
                (item['id'] == bebanId || '${item['id']}' == '$bebanId'));
            if (list.length != beforeCount) {
              modified = true;
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticUpdateBebanTrafo(
    int bebanId,
    Map<String, dynamic> updatedItem,
  ) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%beban-trafo%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('beban') &&
              (list.first as Map)['beban'] is List) {
            for (final trafo in list) {
              if (trafo is Map && trafo.containsKey('beban') && trafo['beban'] is List) {
                final bebanList = trafo['beban'] as List;
                for (int i = 0; i < bebanList.length; i++) {
                  if (bebanList[i] is Map &&
                      (bebanList[i]['id'] == bebanId ||
                          '${bebanList[i]['id']}' == '$bebanId')) {
                    bebanList[i] = {
                      ...bebanList[i] as Map,
                      ...updatedItem,
                    };
                    modified = true;
                  }
                }
              }
            }
          } else {
            for (int i = 0; i < list.length; i++) {
              if (list[i] is Map &&
                  (list[i]['id'] == bebanId ||
                      '${list[i]['id']}' == '$bebanId')) {
                list[i] = {
                  ...list[i] as Map,
                  ...updatedItem,
                };
                modified = true;
              }
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticAddBebanTrafo(
    int trafoId,
    Map<String, dynamic> newItem,
  ) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%beban-trafo%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('beban') &&
              (list.first as Map)['beban'] is List) {
            for (final t in list) {
              if (t is Map &&
                  (t['id'] == trafoId || '${t['id']}' == '$trafoId')) {
                final bebanList = (t['beban'] as List?) ?? [];
                final exists = bebanList.any((b) =>
                    b is Map &&
                    (b['id'] == newItem['id'] ||
                        (b['periode'] == newItem['periode'] &&
                            b['tanggal'] == newItem['tanggal'])));
                if (!exists) {
                  bebanList.add(newItem);
                  t['beban'] = bebanList;
                  modified = true;
                }
              }
            }
          } else if (key.contains('/today/$trafoId')) {
            final exists = list.any((b) =>
                b is Map &&
                (b['id'] == newItem['id'] ||
                    (b['periode'] == newItem['periode'] &&
                        b['tanggal'] == newItem['tanggal'])));
            if (!exists) {
              list.add(newItem);
              list.sort((a, b) {
                final pa = a is Map ? (a['periode'] as int? ?? 0) : 0;
                final pb = b is Map ? (b['periode'] as int? ?? 0) : 0;
                return pa.compareTo(pb);
              });
              modified = true;
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 6. OPTIMISTIC HELPERS: TEGANGAN TRAFO
  // ═══════════════════════════════════════════════════════════════

  Future<void> optimisticDeleteTeganganTrafo(int teganganId) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%tegangan-trafo%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('tegangan') &&
              (list.first as Map)['tegangan'] is List) {
            for (final trafo in list) {
              if (trafo is Map && trafo.containsKey('tegangan') && trafo['tegangan'] is List) {
                final teganganList = trafo['tegangan'] as List;
                final beforeCount = teganganList.length;
                teganganList.removeWhere((item) =>
                    item is Map &&
                    (item['id'] == teganganId || '${item['id']}' == '$teganganId'));
                if (teganganList.length != beforeCount) {
                  modified = true;
                }
              }
            }
          } else {
            final beforeCount = list.length;
            list.removeWhere((item) =>
                item is Map &&
                (item['id'] == teganganId || '${item['id']}' == '$teganganId'));
            if (list.length != beforeCount) {
              modified = true;
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticUpdateTeganganTrafo(
    int teganganId,
    Map<String, dynamic> updatedItem,
  ) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%tegangan-trafo%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('tegangan') &&
              (list.first as Map)['tegangan'] is List) {
            for (final trafo in list) {
              if (trafo is Map && trafo.containsKey('tegangan') && trafo['tegangan'] is List) {
                final teganganList = trafo['tegangan'] as List;
                for (int i = 0; i < teganganList.length; i++) {
                  if (teganganList[i] is Map &&
                      (teganganList[i]['id'] == teganganId ||
                          '${teganganList[i]['id']}' == '$teganganId')) {
                    teganganList[i] = {
                      ...teganganList[i] as Map,
                      ...updatedItem,
                    };
                    modified = true;
                  }
                }
              }
            }
          } else {
            for (int i = 0; i < list.length; i++) {
              if (list[i] is Map &&
                  (list[i]['id'] == teganganId ||
                      '${list[i]['id']}' == '$teganganId')) {
                list[i] = {
                  ...list[i] as Map,
                  ...updatedItem,
                };
                modified = true;
              }
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticAddTeganganTrafo(
    int trafoId,
    Map<String, dynamic> newItem,
  ) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%tegangan-trafo%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('tegangan') &&
              (list.first as Map)['tegangan'] is List) {
            for (final t in list) {
              if (t is Map &&
                  (t['id'] == trafoId || '${t['id']}' == '$trafoId')) {
                final teganganList = (t['tegangan'] as List?) ?? [];
                final exists = teganganList.any((b) =>
                    b is Map &&
                    (b['id'] == newItem['id'] ||
                        (b['periode'] == newItem['periode'] &&
                            b['tanggal'] == newItem['tanggal'])));
                if (!exists) {
                  teganganList.add(newItem);
                  t['tegangan'] = teganganList;
                  modified = true;
                }
              }
            }
          } else if (key.contains('/today/$trafoId')) {
            final exists = list.any((b) =>
                b is Map &&
                (b['id'] == newItem['id'] ||
                    (b['periode'] == newItem['periode'] &&
                        b['tanggal'] == newItem['tanggal'])));
            if (!exists) {
              list.add(newItem);
              list.sort((a, b) {
                final pa = a is Map ? (a['periode'] as int? ?? 0) : 0;
                final pb = b is Map ? (b['periode'] as int? ?? 0) : 0;
                return pa.compareTo(pb);
              });
              modified = true;
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 7. OPTIMISTIC HELPERS: KWH HARIAN
  // ═══════════════════════════════════════════════════════════════

  Future<void> optimisticDeleteKwhHarian(List<int> deletedIds) async {
    if (deletedIds.isEmpty) return;
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%kwh-harian%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('kwhHarian') &&
              (list.first as Map)['kwhHarian'] is List) {
            for (final obj in list) {
              if (obj is Map && obj.containsKey('kwhHarian') && obj['kwhHarian'] is List) {
                final kwhList = obj['kwhHarian'] as List;
                final beforeCount = kwhList.length;
                kwhList.removeWhere((item) =>
                    item is Map &&
                    deletedIds.any((id) => item['id'] == id || '${item['id']}' == '$id'));
                if (kwhList.length != beforeCount) {
                  modified = true;
                }
              }
            }
          } else {
            final beforeCount = list.length;
            list.removeWhere((item) =>
                item is Map &&
                deletedIds.any((id) => item['id'] == id || '${item['id']}' == '$id'));
            if (list.length != beforeCount) {
              modified = true;
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticUpdateKwhHarian(
    int kwhId,
    Map<String, dynamic> updatedItem,
  ) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%kwh-harian%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('kwhHarian') &&
              (list.first as Map)['kwhHarian'] is List) {
            for (final obj in list) {
              if (obj is Map && obj.containsKey('kwhHarian') && obj['kwhHarian'] is List) {
                final kwhList = obj['kwhHarian'] as List;
                for (int i = 0; i < kwhList.length; i++) {
                  if (kwhList[i] is Map &&
                      (kwhList[i]['id'] == kwhId ||
                          '${kwhList[i]['id']}' == '$kwhId')) {
                    kwhList[i] = {
                      ...kwhList[i] as Map,
                      ...updatedItem,
                    };
                    modified = true;
                  }
                }
              }
            }
          } else {
            for (int i = 0; i < list.length; i++) {
              if (list[i] is Map &&
                  (list[i]['id'] == kwhId ||
                      '${list[i]['id']}' == '$kwhId')) {
                list[i] = {
                  ...list[i] as Map,
                  ...updatedItem,
                };
                modified = true;
              }
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticAddKwhHarian(
    int objectId,
    List<Map<String, dynamic>> newItems,
  ) async {
    if (newItems.isEmpty) return;
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%kwh-harian%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;

        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          if (list.isNotEmpty &&
              list.first is Map &&
              (list.first as Map).containsKey('kwhHarian') &&
              (list.first as Map)['kwhHarian'] is List) {
            for (final obj in list) {
              if (obj is Map &&
                  (obj['id'] == objectId || '${obj['id']}' == '$objectId')) {
                obj['isDone'] = true;
                final kwhList = (obj['kwhHarian'] as List?) ?? [];
                for (final item in newItems) {
                  final idx = kwhList.indexWhere((k) =>
                      k is Map &&
                      (k['id'] == item['id'] || k['jenis'] == item['jenis']));
                  if (idx != -1) {
                    kwhList[idx] = item;
                  } else {
                    kwhList.add(item);
                  }
                  modified = true;
                }
                obj['kwhHarian'] = kwhList;
              }
            }
          } else if (key.contains('/today/$objectId')) {
            for (final item in newItems) {
              final exists = list.any((k) =>
                  k is Map &&
                  (k['id'] == item['id'] || k['jenis'] == item['jenis']));
              if (!exists) {
                list.add(item);
                modified = true;
              }
            }
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 8. OPTIMISTIC HELPERS: IL1 KUBIKEL
  // ═══════════════════════════════════════════════════════════════

  Future<void> optimisticDeleteIl1Kubikel(int id) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-kubikel%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && item['il1'] is List) {
              final il1List = item['il1'] as List;
              final lenBefore = il1List.length;
              il1List.removeWhere((i) => i is Map && (i['id'] == id || '${i['id']}' == '$id'));
              if (il1List.length != lenBefore) {
                modified = true;
              }
            }
          }
        } else if (decoded['data'] is Map) {
          final dataMap = decoded['data'] as Map;
          if (dataMap['id'] == id || '${dataMap['id']}' == '$id') {
            decoded['data'] = null;
            modified = true;
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticUpdateIl1Kubikel(int id, Map<String, dynamic> updatePayload) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-kubikel%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && item['il1'] is List) {
              final il1List = item['il1'] as List;
              for (final i in il1List) {
                if (i is Map && (i['id'] == id || '${i['id']}' == '$id')) {
                  if (updatePayload.containsKey('status')) {
                    i['status'] = updatePayload['status'];
                  }
                  modified = true;
                }
              }
            }
          }
        } else if (decoded['data'] is Map) {
          final dataMap = decoded['data'] as Map;
          if (dataMap['id'] == id || '${dataMap['id']}' == '$id') {
            dataMap.addAll(updatePayload);
            modified = true;
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticAddIl1Kubikel(int penyulangId, Map<String, dynamic> newRecord) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-kubikel%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && (item['id'] == penyulangId || '${item['id']}' == '$penyulangId')) {
              item['il1'] = [newRecord];
              modified = true;
            }
          }
        } else if (key.contains('/today/$penyulangId')) {
          decoded['data'] = newRecord;
          modified = true;
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 9. OPTIMISTIC HELPERS: IL1 TRAFO PS
  // ═══════════════════════════════════════════════════════════════

  Future<void> optimisticDeleteIl1TrafoPs(int id) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-trafo-ps%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && item['il1TrafoPS'] is List) {
              final il1List = item['il1TrafoPS'] as List;
              final lenBefore = il1List.length;
              il1List.removeWhere((i) => i is Map && (i['id'] == id || '${i['id']}' == '$id'));
              if (il1List.length != lenBefore) {
                modified = true;
              }
            }
          }
        } else if (decoded['data'] is Map) {
          final dataMap = decoded['data'] as Map;
          if (dataMap['id'] == id || '${dataMap['id']}' == '$id') {
            decoded['data'] = null;
            modified = true;
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticUpdateIl1TrafoPs(int id, Map<String, dynamic> updatePayload) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-trafo-ps%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && item['il1TrafoPS'] is List) {
              final il1List = item['il1TrafoPS'] as List;
              for (final i in il1List) {
                if (i is Map && (i['id'] == id || '${i['id']}' == '$id')) {
                  if (updatePayload.containsKey('status')) {
                    i['status'] = updatePayload['status'];
                  }
                  modified = true;
                }
              }
            }
          }
        } else if (decoded['data'] is Map) {
          final dataMap = decoded['data'] as Map;
          if (dataMap['id'] == id || '${dataMap['id']}' == '$id') {
            dataMap.addAll(updatePayload);
            modified = true;
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticAddIl1TrafoPs(int trafoId, Map<String, dynamic> newRecord) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-trafo-ps%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && (item['id'] == trafoId || '${item['id']}' == '$trafoId')) {
              item['il1TrafoPS'] = [newRecord];
              modified = true;
            }
          }
        } else if (key.contains('/today/$trafoId')) {
          decoded['data'] = newRecord;
          modified = true;
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 10. OPTIMISTIC HELPERS: IL1 SIPIL
  // ═══════════════════════════════════════════════════════════════

  Future<void> optimisticDeleteIl1Sipil(int id) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-sipil%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && item['il1Sipil'] is List) {
              final il1List = item['il1Sipil'] as List;
              final lenBefore = il1List.length;
              il1List.removeWhere((i) => i is Map && (i['id'] == id || '${i['id']}' == '$id'));
              if (il1List.length != lenBefore) {
                modified = true;
              }
            }
          }
        } else if (decoded['data'] is Map) {
          final dataMap = decoded['data'] as Map;
          if (dataMap['id'] == id || '${dataMap['id']}' == '$id') {
            decoded['data'] = null;
            modified = true;
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticUpdateIl1Sipil(int id, Map<String, dynamic> updatePayload) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-sipil%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && item['il1Sipil'] is List) {
              final il1List = item['il1Sipil'] as List;
              for (final i in il1List) {
                if (i is Map && (i['id'] == id || '${i['id']}' == '$id')) {
                  if (updatePayload.containsKey('status')) {
                    i['status'] = updatePayload['status'];
                  }
                  modified = true;
                }
              }
            }
          }
        } else if (decoded['data'] is Map) {
          final dataMap = decoded['data'] as Map;
          if (dataMap['id'] == id || '${dataMap['id']}' == '$id') {
            dataMap.addAll(updatePayload);
            modified = true;
          }
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }

  Future<void> optimisticAddIl1Sipil(int sipilId, Map<String, dynamic> newRecord) async {
    final db = await database;
    final rows = await db.query(
      'api_cache',
      where: 'key LIKE ?',
      whereArgs: ['%il1-sipil%'],
    );

    for (final row in rows) {
      final key = row['key'] as String;
      final rawData = row['data'] as String;
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is! Map<String, dynamic>) continue;
        bool modified = false;

        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          for (final item in list) {
            if (item is Map && (item['id'] == sipilId || '${item['id']}' == '$sipilId')) {
              item['il1Sipil'] = [newRecord];
              modified = true;
            }
          }
        } else if (key.contains('/today/$sipilId')) {
          decoded['data'] = newRecord;
          modified = true;
        }

        if (modified) {
          await db.update(
            'api_cache',
            {'data': jsonEncode(decoded)},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      } catch (_) {}
    }
  }
}

