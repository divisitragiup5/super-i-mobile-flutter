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
          parsedData = jsonDecode(dataStr) as Map<String, dynamic>;
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
}
