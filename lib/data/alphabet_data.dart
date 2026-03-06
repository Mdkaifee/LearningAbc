import '../models/alphabet_entry.dart';

const List<AlphabetEntry> alphabetEntries = [
  AlphabetEntry(
    letter: 'A',
    letterImageName: 'A',
    animalName: 'Alligator',
    animalImageName: 'Alligator',
    soundName: 'a',
  ),
  AlphabetEntry(
    letter: 'B',
    letterImageName: 'B',
    animalName: 'Bear',
    animalImageName: 'Bear',
    soundName: 'b',
  ),
  AlphabetEntry(
    letter: 'C',
    letterImageName: 'C',
    animalName: 'Cat',
    animalImageName: 'cat',
    soundName: 'c',
  ),
  AlphabetEntry(
    letter: 'D',
    letterImageName: 'D',
    animalName: 'Dog',
    animalImageName: 'Dog',
    soundName: 'd',
  ),
  AlphabetEntry(
    letter: 'E',
    letterImageName: 'E',
    animalName: 'Elephant',
    animalImageName: 'Elephant',
    soundName: 'e',
  ),
  AlphabetEntry(
    letter: 'F',
    letterImageName: 'F',
    animalName: 'Fox',
    animalImageName: 'Fox',
    soundName: 'f',
  ),
  AlphabetEntry(
    letter: 'G',
    letterImageName: 'G',
    animalName: 'Giraffe',
    animalImageName: 'Giraffe',
    soundName: 'g',
  ),
  AlphabetEntry(
    letter: 'H',
    letterImageName: 'H',
    animalName: 'Hippo',
    animalImageName: 'Hippo',
    soundName: 'h',
  ),
  AlphabetEntry(
    letter: 'I',
    letterImageName: 'I',
    animalName: 'Iguana',
    animalImageName: 'Iguana',
    soundName: 'i',
  ),
  AlphabetEntry(
    letter: 'J',
    letterImageName: 'J',
    animalName: 'Jellyfish',
    animalImageName: 'JellyFish',
    soundName: 'j',
  ),
  AlphabetEntry(
    letter: 'K',
    letterImageName: 'K',
    animalName: 'Kangaroo',
    animalImageName: 'Kangaroo',
    soundName: 'k',
  ),
  AlphabetEntry(
    letter: 'L',
    letterImageName: 'L',
    animalName: 'Lion',
    animalImageName: 'Lion',
    soundName: 'l',
  ),
  AlphabetEntry(
    letter: 'M',
    letterImageName: 'M',
    animalName: 'Monkey',
    animalImageName: 'Monkey',
    soundName: 'm',
  ),
  AlphabetEntry(
    letter: 'N',
    letterImageName: 'N',
    animalName: 'Numbat',
    animalImageName: 'Numbat',
    soundName: 'n',
  ),
  AlphabetEntry(
    letter: 'O',
    letterImageName: 'O',
    animalName: 'Owl',
    animalImageName: 'Owl',
    soundName: 'o',
  ),
  AlphabetEntry(
    letter: 'P',
    letterImageName: 'P',
    animalName: 'Penguin',
    animalImageName: 'Penguin',
    soundName: 'p',
  ),
  AlphabetEntry(
    letter: 'Q',
    letterImageName: 'Q',
    animalName: 'Quail',
    animalImageName: 'Quail',
    soundName: 'q',
  ),
  AlphabetEntry(
    letter: 'R',
    letterImageName: 'R',
    animalName: 'Raccoon',
    animalImageName: 'Racoon',
    soundName: 'r',
  ),
  AlphabetEntry(
    letter: 'S',
    letterImageName: 'S',
    animalName: 'Sheep',
    animalImageName: 'Sheep',
    soundName: 's',
  ),
  AlphabetEntry(
    letter: 'T',
    letterImageName: 'T',
    animalName: 'Tiger',
    animalImageName: 'Tiger',
    soundName: 't',
  ),
  AlphabetEntry(
    letter: 'U',
    letterImageName: 'U',
    animalName: 'Unicorn',
    animalImageName: 'Unicorn',
    soundName: 'u',
  ),
  AlphabetEntry(
    letter: 'V',
    letterImageName: 'V',
    animalName: 'Vampire Bat',
    animalImageName: 'Vampire_Bat',
    soundName: 'v',
  ),
  AlphabetEntry(
    letter: 'W',
    letterImageName: 'W',
    animalName: 'Whale',
    animalImageName: 'Whale',
    soundName: 'w',
  ),
  AlphabetEntry(
    letter: 'X',
    letterImageName: 'X',
    animalName: 'X-Ray Fish',
    animalImageName: 'X_Ray_fish',
    soundName: 'x',
  ),
  AlphabetEntry(
    letter: 'Y',
    letterImageName: 'Y',
    animalName: 'Yak',
    animalImageName: 'Yak',
    soundName: 'y',
  ),
  AlphabetEntry(
    letter: 'Z',
    letterImageName: 'Z',
    animalName: 'Zebra',
    animalImageName: 'Zebra',
    soundName: 'z',
  ),
];

final Map<String, String> animalByLetter = {
  for (final entry in alphabetEntries) entry.letter: entry.animalName,
};

List<String> buildAlphabetLetters() =>
    List<String>.generate(26, (i) => String.fromCharCode(65 + i));

String spellTargetWord(String letter) {
  final animal = animalByLetter[letter] ?? '';
  return animal.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
}

AlphabetEntry? entryForLetter(String letter) {
  for (final entry in alphabetEntries) {
    if (entry.letter == letter) {
      return entry;
    }
  }
  return null;
}
