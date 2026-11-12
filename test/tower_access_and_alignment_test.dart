import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/constants/role_constants.dart';
import 'package:super_i_mobile/core/constants/storage_constants.dart';
import 'package:super_i_mobile/core/storage/preferences_service.dart';
import 'package:super_i_mobile/core/widgets/input_container.dart';
import 'package:super_i_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:super_i_mobile/features/line_walker/data/datasources/line_walker_remote_data_source.dart';
import 'package:super_i_mobile/features/line_walker/data/models/tower_asset_model.dart';
import 'package:super_i_mobile/features/line_walker/data/repositories/line_walker_repository_impl.dart';

class FakeLineWalkerRemoteDataSource implements LineWalkerRemoteDataSource {
  int getTowersCallCount = 0;
  String? lastType;

  @override
  Future<List<TowerAssetModel>> getTowers({String type = 'GANTRY,TOWER'}) async {
    getTowersCallCount++;
    lastType = type;
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePreferencesService implements PreferencesService {
  String? userProfileString;

  @override
  String? getString(String key) {
    if (key == StorageConstants.userProfile) return userProfileString;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('UserEntity Role & Line Walker Tower Access Tests', () {
    test('Petugas Line Walker should have access to Line Walker towers', () {
      const user = UserEntity(
        id: 1,
        namaLengkap: 'Petugas LW',
        noTelepon: '08123456789',
        nip: '12345',
        roles: [AppRoles.petugasLineWalker],
      );

      expect(user.isLineWalker, isTrue);
      expect(user.isOpgi, isFalse);
      expect(user.isDistribusi, isFalse);
      expect(user.canAccessLineWalkerTower, isTrue);
    });

    test('Operator GI 20kV should NOT have access to Line Walker towers', () {
      const user = UserEntity(
        id: 2,
        namaLengkap: 'Operator GI',
        noTelepon: '08123456789',
        nip: '12346',
        roles: [AppRoles.operatorGi20kv],
      );

      expect(user.isLineWalker, isFalse);
      expect(user.isOpgi, isTrue);
      expect(user.isDistribusi, isFalse);
      expect(user.canAccessLineWalkerTower, isFalse);
    });

    test('Distribusi SUTM user should NOT have access to Line Walker towers', () {
      const user = UserEntity(
        id: 3,
        namaLengkap: 'Petugas Distribusi',
        noTelepon: '08123456789',
        nip: '12347',
        roles: [AppRoles.petugasInspeksiSutm],
      );

      expect(user.isLineWalker, isFalse);
      expect(user.isOpgi, isFalse);
      expect(user.isDistribusi, isTrue);
      expect(user.canAccessLineWalkerTower, isFalse);
    });

    test('User with both OPGI and Line Walker roles should NOT access tower if OPGI is present', () {
      const user = UserEntity(
        id: 4,
        namaLengkap: 'Mixed User',
        noTelepon: '08123456789',
        nip: '12348',
        roles: [AppRoles.operatorGi20kv, AppRoles.petugasLineWalker],
      );

      expect(user.isOpgi, isTrue);
      expect(user.canAccessLineWalkerTower, isFalse);
    });
  });

  group('LineWalkerRepositoryImpl Endpoint Guarding Tests', () {
    late FakeLineWalkerRemoteDataSource fakeRemoteDataSource;
    late FakePreferencesService fakePreferencesService;
    late LineWalkerRepositoryImpl repository;

    setUp(() {
      fakeRemoteDataSource = FakeLineWalkerRemoteDataSource();
      fakePreferencesService = FakePreferencesService();
      repository = LineWalkerRepositoryImpl(
        fakeRemoteDataSource,
        fakePreferencesService,
      );
    });

    test('getTowers returns Right([]) immediately without calling API if user is OPGI', () async {
      fakePreferencesService.userProfileString =
          '{"id": 1, "namaLengkap": "User GI", "noTelepon": "081", "nip": "123", "roles": ["Operator GI 20kV"]}';

      final result = await repository.getTowers(type: 'JOINT,SPAN');

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r, isEmpty),
      );
      expect(fakeRemoteDataSource.getTowersCallCount, equals(0));
    });

    test('getTowers calls remoteDataSource if user is Line Walker', () async {
      fakePreferencesService.userProfileString =
          '{"id": 1, "namaLengkap": "User LW", "noTelepon": "081", "nip": "123", "roles": ["Petugas Line Walker"]}';

      final result = await repository.getTowers(type: 'JOINT,SPAN');

      expect(result.isRight(), isTrue);
      expect(fakeRemoteDataSource.getTowersCallCount, equals(1));
      expect(fakeRemoteDataSource.lastType, equals('JOINT,SPAN'));
    });

    test('prefetchTowers does nothing if user is Distribusi', () async {
      fakePreferencesService.userProfileString =
          '{"id": 1, "namaLengkap": "User SUTM", "noTelepon": "081", "nip": "123", "roles": ["Petugas Inspeksi SUTM"]}';

      await repository.prefetchTowers();

      expect(fakeRemoteDataSource.getTowersCallCount, equals(0));
    });
  });

  group('InputWithLabel Left-Alignment Verification', () {
    testWidgets('InputWithLabel has left-aligned label and child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputContainer(
              label: 'INFO',
              child: InputWithLabel(
                label: 'Gardu Induk',
                child: Text('GI AGP-CIPUTRA'),
              ),
            ),
          ),
        ),
      );

      final labelFinder = find.text('Gardu Induk');
      final valueFinder = find.text('GI AGP-CIPUTRA');

      expect(labelFinder, findsOneWidget);
      expect(valueFinder, findsOneWidget);

      final labelPos = tester.getTopLeft(labelFinder);
      final valuePos = tester.getTopLeft(valueFinder);

      // Both should start at the same left x-coordinate inside the container
      expect(labelPos.dx, equals(valuePos.dx));
    });
  });
}
