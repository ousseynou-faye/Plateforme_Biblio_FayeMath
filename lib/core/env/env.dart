/// Acces centralise aux variables d'environnement, injectees au build via
/// `--dart-define-from-file=config/dev.json` (SECURITY.md §1).
///
/// Aucune valeur de secret n'est ecrite en dur ici : ce sont des constantes
/// `String.fromEnvironment`, remplies a la compilation depuis le fichier local
/// `config/dev.json` (ignore par Git). La cle exposee est la cle ANON de
/// Supabase — publique, destinee au client et protegee par le RLS —, jamais la
/// cle `service_role`.
abstract final class Env {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Vrai si les deux variables ont bien ete injectees au build. Permet de
  /// donner un message clair quand on oublie le flag `--dart-define-from-file`,
  /// plutot qu'un plantage cryptique de `Supabase.initialize`.
  static bool get estConfigure =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
