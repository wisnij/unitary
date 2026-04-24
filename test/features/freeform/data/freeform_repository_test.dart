import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/freeform/data/freeform_repository.dart';

void main() {
  group('FreeformRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<FreeformRepository> makeRepo() async {
      final prefs = await SharedPreferences.getInstance();
      return FreeformRepository(prefs);
    }

    group('load', () {
      test('returns empty strings when prefs are empty', () async {
        final repo = await makeRepo();
        final (:input, :output) = repo.load();
        expect(input, '');
        expect(output, '');
      });

      test('restores saved input text', () async {
        final repo = await makeRepo();
        await repo.save('5 ft', '');
        final (:input, :output) = repo.load();
        expect(input, '5 ft');
        expect(output, '');
      });

      test('restores saved output text', () async {
        final repo = await makeRepo();
        await repo.save('', 'm');
        final (:input, :output) = repo.load();
        expect(input, '');
        expect(output, 'm');
      });

      test('round-trips both fields correctly', () async {
        final repo = await makeRepo();
        await repo.save('5 ft', 'm');
        final (:input, :output) = repo.load();
        expect(input, '5 ft');
        expect(output, 'm');
      });

      test(
        'returns empty string for input when only output key is present',
        () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(FreeformRepository.outputKey, 'm');
          final repo = FreeformRepository(prefs);
          final (:input, :output) = repo.load();
          expect(input, '');
          expect(output, 'm');
        },
      );

      test(
        'returns empty string for output when only input key is present',
        () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(FreeformRepository.inputKey, '5 ft');
          final repo = FreeformRepository(prefs);
          final (:input, :output) = repo.load();
          expect(input, '5 ft');
          expect(output, '');
        },
      );
    });

    group('save', () {
      test('overwrites previous values', () async {
        final repo = await makeRepo();
        await repo.save('5 ft', 'm');
        await repo.save('3 kg', '');
        final (:input, :output) = repo.load();
        expect(input, '3 kg');
        expect(output, '');
      });
    });
  });
}
