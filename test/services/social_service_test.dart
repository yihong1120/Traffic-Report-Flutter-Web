import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lib/services/social_service.dart';
import 'package:traffic_report_front_flutter/models/social_account.dart';

// Mock classes
class MockClient extends Mock implements http.Client {}

void main() {
  group('SocialService', () {
    late http.Client client;
    late SocialService socialService;

    setUp(() async {
      client = MockClient();
      socialService = SocialService(client: client);
      TestWidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");
    });

    test('getConnectedAccounts returns a list of SocialAccount', () async {
      final mockUri = Uri.parse('https://example.com');
      when(client.get(mockUri)).thenAnswer((_) async => http.Response(
          json.encode([
            {
              'provider': 'Facebook',
              'uid': '123e4567-e89b-12d3-a456-426614174000'
            },
            {
              'provider': 'Twitter',
              'uid': '123e4567-e89b-12d3-a456-426614174001'
            }
          ]),
          200));

      expect(await socialService.getConnectedAccounts(),
          isA<List<SocialAccount>>());
    });

    test('getAvailableProviders returns a list of SocialProvider', () async {
      when(client.get(isA<Uri>() as Uri)).thenAnswer((_) async => http.Response(
          json.encode([
            {'id': '123e4567-e89b-12d3-a456-426614174002', 'name': 'Facebook'},
            {'id': '123e4567-e89b-12d3-a456-426614174003', 'name': 'Twitter'}
          ]),
          200));

      expect(await socialService.getAvailableProviders(),
          isA<List<SocialProvider>>());
    });

    test('disconnectAccount returns true on successful disconnection',
        () async {
      when(client.post(isA as Uri, body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 200));

      SocialAccount account = SocialAccount(
          provider: 'Facebook', uid: '123e4567-e89b-12d3-a456-426614174000');
      expect(await socialService.disconnectAccount(account), isTrue);
    });

    test(
        'connectWithProvider throws an exception if the URL cannot be launched',
        () async {
      SocialProvider provider = SocialProvider(
          id: '123e4567-e89b-12d3-a456-426614174004', name: 'Facebook');
      final mockUri = Uri.parse('https://example.com');
      when(canLaunchUrl(mockUri)).thenAnswer((_) async => false);

      expect(() async => await socialService.connectWithProvider(provider),
          throwsA(isA<Exception>()));
    });
  });
}
