import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/repositories/preferences_onboarding_repository.dart';
import 'package:fayemath_academy/presentation/providers/onboarding_provider.dart';

/// Faux repository en memoire : imite le coffre (le vrai `StockageOnboarding`
/// passe par un plugin, non testable sous Windows). Retient la valeur ecrite.
class _FauxPreferencesOnboarding implements PreferencesOnboardingRepository {
  _FauxPreferencesOnboarding({bool dejaVu = false}) : _vu = dejaVu;

  bool _vu;
  int nbMarquages = 0;

  @override
  Future<bool> onboardingVu() async => _vu;

  @override
  Future<void> marquerOnboardingVu() async {
    _vu = true;
    nbMarquages++;
  }

  @override
  Future<void> reinitialiserOnboarding() async => _vu = false;
}

/// Laisse tourner la microtache pour que la lecture disque (asynchrone) delivre.
Future<void> laisserLaLectureDelivrer() => Future<void>.delayed(Duration.zero);

void main() {
  ProviderContainer creerContainer(PreferencesOnboardingRepository repository) {
    final container = ProviderContainer(
      overrides: [
        preferencesOnboardingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    // Garde le provider actif (donc sa lecture disque lancee) pendant le test.
    container.listen(etatOnboardingProvider, (_, _) {});
    return container;
  }

  group('etatOnboardingProvider', () {
    test('indetermine au demarrage, avant la lecture du disque', () {
      final container = creerContainer(_FauxPreferencesOnboarding());

      expect(
        container.read(etatOnboardingProvider),
        isA<OnboardingIndetermine>(),
      );
    });

    test('devient requis quand le drapeau est absent (jamais vu)', () async {
      final container = creerContainer(
        _FauxPreferencesOnboarding(dejaVu: false),
      );

      await laisserLaLectureDelivrer();

      expect(container.read(etatOnboardingProvider), isA<OnboardingRequis>());
    });

    test('devient vu quand le drapeau est deja pose', () async {
      final container = creerContainer(_FauxPreferencesOnboarding(dejaVu: true));

      await laisserLaLectureDelivrer();

      expect(container.read(etatOnboardingProvider), isA<OnboardingVu>());
    });

    test('marquerVu bascule l\'etat immediatement et persiste', () async {
      final faux = _FauxPreferencesOnboarding(dejaVu: false);
      final container = creerContainer(faux);
      await laisserLaLectureDelivrer();
      expect(container.read(etatOnboardingProvider), isA<OnboardingRequis>());

      await container.read(etatOnboardingProvider.notifier).marquerVu();

      expect(container.read(etatOnboardingProvider), isA<OnboardingVu>());
      expect(faux.nbMarquages, 1);
    });
  });
}
