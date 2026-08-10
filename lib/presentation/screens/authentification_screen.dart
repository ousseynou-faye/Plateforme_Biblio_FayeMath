import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/formulaire_auth_provider.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';

/// L'ecran unique d'authentification (maquette V2.1, ecran 2). Il bascule sur
/// place entre « Creer mon compte » et « Se connecter » (etat dans
/// [formulaireAuthProvider]), et propose « Continuer sans compte ».
///
/// Ecarts assumes a la maquette (decisions du 10/08, cf. Journal) : identifiant
/// = e-mail seul (au lieu de « Telephone ou e-mail »), champ « Ton nom » retire.
class AuthentificationScreen extends ConsumerStatefulWidget {
  const AuthentificationScreen({super.key});

  @override
  ConsumerState<AuthentificationScreen> createState() =>
      _AuthentificationScreenState();
}

class _AuthentificationScreenState
    extends ConsumerState<AuthentificationScreen> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _cacherMotDePasse = true;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  void _soumettre() {
    // Ferme le clavier pour laisser voir les messages d'erreur.
    FocusScope.of(context).unfocus();
    if (_cleFormulaire.currentState?.validate() ?? false) {
      ref
          .read(formulaireAuthProvider.notifier)
          .soumettre(email: _email.text.trim(), motDePasse: _motDePasse.text);
    }
  }

  String? _validerEmail(String? valeur) {
    final v = (valeur ?? '').trim();
    if (v.isEmpty) return 'Entre ton e-mail.';
    // Validation volontairement simple : un @ et un point apres. La verite
    // reste le serveur ; ceci evite juste les fautes de frappe evidentes.
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Saisis une adresse e-mail valide.';
    }
    return null;
  }

  String? _validerMotDePasse(String? valeur, ModeAuth mode) {
    final v = valeur ?? '';
    if (v.isEmpty) return 'Entre ton mot de passe.';
    // A la CONNEXION, on ne juge pas la force : un compte ancien peut avoir un
    // mot de passe qui ne suit plus la regle. La regle « 8 + un chiffre » ne
    // vaut qu'a l'INSCRIPTION — c'est elle qui evite que Supabase renvoie
    // `weak_password` (non traduit specifiquement, cf. lot C).
    if (mode == ModeAuth.connexion) return null;
    if (v.length < 8) return '8 caracteres minimum, dont un chiffre.';
    if (!RegExp(r'\d').hasMatch(v)) {
      return 'Il manque un chiffre. 8 caracteres minimum, dont un chiffre.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final etat = ref.watch(formulaireAuthProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: etat.statut is InscriptionAConfirmer
                  ? _PanneauConfirmation(email: _email.text.trim())
                  : _formulaire(context, etat),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formulaire(BuildContext context, EtatFormulaireAuth etat) {
    final textTheme = Theme.of(context).textTheme;
    final estInscription = etat.mode == ModeAuth.inscription;
    final enCours = etat.statut is SoumissionEnCours;

    return Form(
      key: _cleFormulaire,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EnTete(estInscription: estInscription),
          const SizedBox(height: 4),
          _Bascule(estInscription: estInscription, active: !enCours),
          const SizedBox(height: 18),
          if (etat.statut is SoumissionEchouee) ...[
            _Encadre(
              type: _TypeEncadre.alerte,
              titre: 'Connexion impossible',
              message: _messagePourEchec(
                (etat.statut as SoumissionEchouee).echec,
              ),
            ),
            const SizedBox(height: 14),
          ],
          TextFormField(
            controller: _email,
            enabled: !enCours,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'E-mail',
              hintText: 'awa@example.com',
              border: OutlineInputBorder(),
            ),
            validator: _validerEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _motDePasse,
            enabled: !enCours,
            obscureText: _cacherMotDePasse,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _soumettre(),
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              helperText: estInscription
                  ? '8 caracteres minimum, dont un chiffre.'
                  : null,
              helperMaxLines: 2,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _cacherMotDePasse = !_cacherMotDePasse),
                icon: Icon(
                  _cacherMotDePasse
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: _cacherMotDePasse
                    ? 'Afficher le mot de passe'
                    : 'Masquer le mot de passe',
              ),
            ),
            validator: (valeur) => _validerMotDePasse(valeur, etat.mode),
          ),
          if (!estInscription) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: enCours ? null : () => _motDePasseOublie(context),
                child: const Text('Mot de passe oublie ?'),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (enCours) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          BoutonPrimaireWidget(
            libelle: estInscription ? 'Creer mon compte' : 'Se connecter',
            onPressed: enCours ? null : _soumettre,
          ),
          const SizedBox(height: 18),
          const _Encadre(
            type: _TypeEncadre.info,
            titre: 'Decouvrir sans compte',
            message:
                'Tu peux lire les cours gratuits tout de suite. En revanche ta '
                'progression et tes telechargements ne seront pas conserves si '
                'tu changes de telephone.',
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: enCours
                ? null
                : () =>
                      ref.read(etatAuthProvider.notifier).continuerSansCompte(),
            child: const Text('Continuer sans compte'),
          ),
          // Rappel discret de la signature de marque.
          const SizedBox(height: 20),
          Text(
            'La reussite se construit a domicile',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _motDePasseOublie(BuildContext context) {
    // Ecart de perimetre assume (etape 13) : la reinitialisation par e-mail
    // exige son propre flux (envoi + lien profond + ecran de nouveau mot de
    // passe), hors de cette etape. Le lien reste present pour la fidelite a la
    // maquette ; on l'indique sans faire croire a une action.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La reinitialisation du mot de passe arrivera bientot.'),
      ),
    );
  }
}

/// Traduit un echec metier en message affiche a l'eleve. Le `switch` sur le
/// type scelle est exhaustif : ajouter un cas sans le traiter ne compilera pas.
String _messagePourEchec(EchecAuthentification echec) => switch (echec) {
  IdentifiantsInvalides() => 'E-mail ou mot de passe incorrect.',
  CompteExistant() =>
    'Un compte existe deja avec cet e-mail. Connecte-toi plutot.',
  EmailNonConfirme() =>
    'Confirme d\'abord ton e-mail (clique le lien recu), puis connecte-toi.',
  PanneReseau() => 'Pas de connexion. Verifie ton reseau et reessaie.',
  EchecAuthentificationInattendu() => 'Une erreur est survenue. Reessaie.',
};

/// Logo (provisoire) + titre de l'ecran. Le vrai logo de marque sera cable avec
/// l'onboarding ; ici, un placeholder textue pour ne pas toucher `assets/`.
class _EnTete extends StatelessWidget {
  const _EnTete({required this.estInscription});

  final bool estInscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: 40,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text('FayeMath Academy', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        Text(
          estInscription ? 'Creer mon compte' : 'Se connecter',
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}

/// La ligne « Deja inscrit ? Se connecter » / « Pas encore de compte ? ... »,
/// qui bascule le mode du formulaire sur place.
class _Bascule extends ConsumerWidget {
  const _Bascule({required this.estInscription, required this.active});

  final bool estInscription;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    // Wrap plutot que Row : sur un petit telephone (la cible reelle du projet),
    // « Pas encore de compte ? » + le bouton peuvent depasser une ligne ; on
    // passe alors a la ligne au lieu de deborder.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          estInscription ? 'Deja inscrit ?' : 'Pas encore de compte ?',
          style: textTheme.bodyMedium,
        ),
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: active
              ? () => ref.read(formulaireAuthProvider.notifier).basculerMode()
              : null,
          child: Text(estInscription ? 'Se connecter' : 'Creer un compte'),
        ),
      ],
    );
  }
}

/// L'ecran de relais apres inscription : la confirmation e-mail etant activee,
/// aucune session n'est ouverte tout de suite (decision 5.8).
class _PanneauConfirmation extends ConsumerWidget {
  const _PanneauConfirmation({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 56,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          'Verifie ta boite mail',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Nous avons envoye un lien de confirmation'
          '${email.isEmpty ? '' : ' a $email'}. '
          'Clique dessus, puis connecte-toi.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        BoutonPrimaireWidget(
          libelle: 'J\'ai confirme, me connecter',
          // basculerMode part de l'inscription -> connexion et remet le statut
          // a « pret » : on revient au formulaire en mode connexion.
          onPressed: () =>
              ref.read(formulaireAuthProvider.notifier).basculerMode(),
        ),
      ],
    );
  }
}

enum _TypeEncadre { info, alerte }

/// Encadre d'information ou d'alerte (les « callout » de la maquette), tout en
/// couleurs du theme : jamais de couleur en dur (docs/CONVENTIONS.md §4).
class _Encadre extends StatelessWidget {
  const _Encadre({
    required this.type,
    required this.titre,
    required this.message,
  });

  final _TypeEncadre type;
  final String titre;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final estAlerte = type == _TypeEncadre.alerte;
    final fond = estAlerte
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final surTexte = estAlerte
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            estAlerte ? Icons.error_outline : Icons.info_outline,
            color: surTexte,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: theme.textTheme.labelLarge?.copyWith(color: surTexte),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(color: surTexte),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
