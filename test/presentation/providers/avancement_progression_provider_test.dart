import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';

const _classe = Classe(id: 'c-6e', nom: '6e', cycle: Cycle.college, ordre: 1);
const _matiere = Matiere(id: 'm-maths', nom: 'Mathematiques');
const _cle = (classeId: 'c-6e', matiereId: 'm-maths');

Chapitre _chap(String id, int ordre) => Chapitre(
  id: id,
  classeId: 'c-6e',
  matiereId: 'm-maths',
  numero: ordre,
  titre: 'Chapitre $id',
  strate: null,
  ordre: ordre,
);

void main() {
  test('avancement : combine chapitres + progression en un AvancementProgression', () {
    final container = ProviderContainer(
      overrides: [
        bibliothequeCouranteProvider.overrideWithValue(
          const AsyncData(
            BibliothequeCourante(classe: _classe, matiere: _matiere),
          ),
        ),
        chapitresProvider(_cle).overrideWithValue(
          AsyncData([_chap('ch1', 1), _chap('ch2', 2)]),
        ),
        etatsChapitresProvider.overrideWithValue(
          const AsyncData({'ch1': EtatProgression.fait}),
        ),
      ],
    );
    addTearDown(container.dispose);

    final av = container.read(avancementProgressionProvider).value!;
    expect(av.total, 2);
    expect(av.fait, 1);
    expect(av.aFaire, 1);
    expect(av.pourcentageGlobal, 50);
    expect(av.parMatiere.single.matiereId, 'm-maths');
    expect(av.parMatiere.single.pourcentage, 50);
  });

  test('avancement : chapitres encore en chargement -> loading', () {
    final container = ProviderContainer(
      overrides: [
        bibliothequeCouranteProvider.overrideWithValue(
          const AsyncData(
            BibliothequeCourante(classe: _classe, matiere: _matiere),
          ),
        ),
        chapitresProvider(_cle).overrideWithValue(const AsyncLoading()),
        etatsChapitresProvider.overrideWithValue(
          const AsyncData(<String, EtatProgression>{}),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(avancementProgressionProvider).isLoading, isTrue);
  });
}
