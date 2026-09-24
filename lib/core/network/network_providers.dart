import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_client.dart';

part 'network_providers.g.dart';

/// Diğer provider'larla (`cartRepositoryProvider` vb.) aynı desen:
/// repository'ler kendi Dio'sunu kurmak yerine bunu izler.
@riverpod
ApiClient apiClient(Ref ref) => ApiClient.main;
