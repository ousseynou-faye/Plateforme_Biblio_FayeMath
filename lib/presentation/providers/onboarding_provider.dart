import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/repositories/preferences_onboarding_repository.dart';

/// Fournit l'implementation du contrat de memoire de l'onboarding.
///
/// NON resolue ici : `presentation/` n'importe pas `data/`
/// (docs/ARCHITECTURE.md §3). L'implementation coffre chiffre
/// ([StockageOnboarding]) est injectee a la racine (`main.dart`) via
/// `overrideWith` ; en test, on l'override par un faux repository.
final preferencesOnboardingRepositoryProvider =
    Provider<PreferencesOnboardingRepository>(
      (ref) => throw UnimplementedError(
        'preferencesOnboardingRepositoryProvider doit etre override a la racine '
        '(main.dart).',
      ),
    );

/// L'etat de l'onboarding tel que la navigation le voit. Trois cas, et trois
/// seulement — type scelle pour que le `switch` de redirection (app_router.dart)
/// reste exhaustif, comme [EtatAuth] et [EtatProfil].
///
///  - [OnboardingIndetermine] : le drapeau n'est pas encore lu (lecture disque
///    asynchrone en cours au demarrage). La navigation attend sur l'ecran neutre
///    de demarrage, comme pour un profil en chargement — jamais de « flash »
///    d'onboarding pour quelqu'un qui l'a deja vu.
///  - [OnboardingRequis]      : jamais vu sur cet appareil -> afficher l'ecran 1.
///  - [OnboardingVu]          : deja vu (ou passe) -> ne plus l'afficher.
sealed class EtatOnboarding {
  const EtatOnboarding();
}

class OnboardingIndetermine extends EtatOnboarding {
  const OnboardingIndetermine();
}

class OnboardingRequis extends EtatOnboarding {
  const OnboardingRequis();
}

class OnboardingVu extends EtatOnboarding {
  const OnboardingVu();
}

/// Charge le drapeau au demarrage (lecture disque asynchrone) et le porte comme
/// [EtatOnboarding] synchrone pour que la redirection go_router puisse trancher.
class EtatOnboardingNotifier extends Notifier<EtatOnboarding> {
  @override
  EtatOnboarding build() {
    // Lecture disque lancee sans attendre : l'etat initial est « indetermine »,
    // la redirection patiente sur l'ecran neutre le temps que le drapeau arrive.
    _charger();
    return const OnboardingIndetermine();
  }

  Future<void> _charger() async {
    final vu = await ref
        .read(preferencesOnboardingRepositoryProvider)
        .onboardingVu();
    state = vu ? const OnboardingVu() : const OnboardingRequis();
  }

  /// Appelee quand l'eleve passe ou termine l'onboarding. On bascule l'etat tout
  /// de suite (la redirection quitte l'ecran 1 sans attendre le disque), PUIS on
  /// persiste — l'ecriture ne peut pas bloquer l'eleve. Idempotente.
  Future<void> marquerVu() async {
    state = const OnboardingVu();
    await ref
        .read(preferencesOnboardingRepositoryProvider)
        .marquerOnboardingVu();
  }
}

final etatOnboardingProvider =
    NotifierProvider<EtatOnboardingNotifier, EtatOnboarding>(
      EtatOnboardingNotifier.new,
    );
