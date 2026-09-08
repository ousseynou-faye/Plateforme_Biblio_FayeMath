/// Coordonnees de contact du tuteur — SOURCE UNIQUE (etape 26, point 5.4).
///
/// Le CTA de l'ecran de l'offre s'en sert pour ouvrir WhatsApp et pour proposer
/// un appel, tant que le paiement en ligne n'existe pas (etape 27). Ces memes
/// numeros resserviront a l'ecran 20 (« Aide et contact du tuteur ») : ils ne
/// doivent exister qu'ICI, jamais recopies dans un widget.
///
/// Numeros officiels du projet (pied de page des specifications V2.1) —
/// **a mettre a jour ICI seulement** s'ils changent.
abstract final class ContactTuteur {
  /// Les numeros joignables : forme affichee (lisible) + forme E.164 (pour `tel:`
  /// et `wa.me`). Le premier sert aussi de numero WhatsApp.
  static const numeros = <({String affichage, String e164})>[
    (affichage: '78 136 43 36', e164: '+221781364336'),
    (affichage: '70 461 42 01', e164: '+221704614201'),
  ];

  /// Message pre-rempli du lien WhatsApp (sans accents, CONVENTIONS §1).
  static const messageWhatsApp =
      'Bonjour, je souhaite passer a FayeMath Premium.';

  /// Lien WhatsApp en https (wa.me) : ouvre l'app si installee, sinon le
  /// navigateur — aucun schema custom, donc aucune config native (`<queries>`)
  /// requise pour le lancer.
  static Uri get whatsApp {
    final numero = numeros.first.e164.replaceAll('+', '');
    return Uri.parse(
      'https://wa.me/$numero?text=${Uri.encodeComponent(messageWhatsApp)}',
    );
  }

  /// Lien `tel:` pour composer un numero donne (forme E.164).
  static Uri appel(String e164) => Uri(scheme: 'tel', path: e164);
}
