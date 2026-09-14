import '../insurance.dart';
import 'base.dart';

/// Üçüncü profil modülü: kullanıcının farklı şirketlerden aldığı aktif
/// sigorta poliçeleri. Diğer profil modüllerinden tamamen bağımsız.
class InsuranceProfileCard extends FeedCard implements Collectible {
  final List<InsurancePolicy> policies;

  const InsuranceProfileCard({required String id, this.policies = const []})
    : super(id);

  int get activeCount => policies.where((p) => p.isActive).length;

  @override
  (String, String) toCollectionPreview() => ("Sigorta Profili", "");
}
