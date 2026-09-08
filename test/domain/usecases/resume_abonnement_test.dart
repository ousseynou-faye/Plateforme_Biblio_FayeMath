// Tests de la regle pure ResumeAbonnement (etape 26 lot A) : formatage du
// libelle de formule et de l'echeance pour l'en-tete « Premium actif », sans
// Flutter ni base.

import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/usecases/resume_abonnement.dart';

Abonnement _abonnement(FormuleAbonnement formule, DateTime dateFin) => Abonnement(
  id: 'a1',
  utilisateurId: 'u1',
  formule: formule,
  dateDebut: DateTime(2026, 9, 1),
  dateFin: dateFin,
  referencePaiement: null,
);

void main() {
  test('libelleFormule : les 3 formules, sans accents', () {
    expect(ResumeAbonnement.libelleFormule(FormuleAbonnement.mensuel), 'Mensuel');
    expect(
      ResumeAbonnement.libelleFormule(FormuleAbonnement.trimestriel),
      'Trimestriel',
    );
    expect(
      ResumeAbonnement.libelleFormule(FormuleAbonnement.anneeScolaire),
      'Annee scolaire',
    );
  });

  test('dateCourte : JJ/MM/AAAA avec zeros de tete', () {
    expect(ResumeAbonnement.dateCourte(DateTime(2027, 6, 30)), '30/06/2027');
    expect(ResumeAbonnement.dateCourte(DateTime(2026, 1, 5)), '05/01/2026');
  });

  test('echeance : « Formule <formule>, jusqu\'au <date> »', () {
    expect(
      ResumeAbonnement.echeance(
        _abonnement(FormuleAbonnement.anneeScolaire, DateTime(2027, 6, 30)),
      ),
      'Formule annee scolaire, jusqu\'au 30/06/2027',
    );
    expect(
      ResumeAbonnement.echeance(
        _abonnement(FormuleAbonnement.mensuel, DateTime(2026, 10, 8)),
      ),
      'Formule mensuel, jusqu\'au 08/10/2026',
    );
  });
}
