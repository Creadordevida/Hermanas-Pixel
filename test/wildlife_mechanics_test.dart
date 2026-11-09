import 'package:flutter_test/flutter_test.dart';
import 'package:hermanas_aventura/main.dart';

void main() {
  group('Mejora 9: perros con comportamiento y mordisco visible', () {
    test('No corren cuando están fuera del campo de detección', () {
      final dog = Enemy(0, 'dog_brown', 300);
      final hit = dog.advanceAnimal(.12, 1200, groundY);
      expect(hit, false);
      expect(dog.animalMode, 'idle');
      expect(dog.x, 300);
    });

    test('Primero alertan; después persiguen sin teletransportarse', () {
      final dog = Enemy(0, 'dog_doberman', 300);
      expect(dog.advanceAnimal(.10, 415, groundY), false);
      expect(dog.animalMode, 'alert');
      expect(dog.x, 300);
      dog.advanceAnimal(.42, 415, groundY);
      expect(dog.animalMode, 'run');
      expect(dog.x, greaterThan(300));
      expect(dog.x, lessThan(360));
    });

    test('Mordisco daña una sola vez y solo tras el gesto de 240ms', () {
      final dog = Enemy(0, 'dog_brown', 300)..attackCooldown = 0;
      dog.advanceAnimal(.40, 335, groundY); // alert
      dog.advanceAnimal(.40, 335, groundY); // starts biting
      expect(dog.animalMode, 'bite');
      expect(dog.advanceAnimal(.20, 335, groundY), false);
      expect(dog.advanceAnimal(.05, 335, groundY), true);
      expect(dog.advanceAnimal(.05, 335, groundY), false);
      expect(dog.attackCooldown, greaterThan(0));
    });

    test('No hay mordisco a la heroína si está muy elevada', () {
      final dog = Enemy(0, 'dog_dalmatian', 300)..attackCooldown = 0;
      dog.advanceAnimal(.40, 330, groundY);
      dog.advanceAnimal(.40, 330, groundY - 130);
      expect(dog.animalMode, isNot('bite'));
    });
  });

  group('Mejora 11: palomas con vuelo físico', () {
    test('Empiezan posadas y despegan al acercarse Miren/Sara', () {
      final bird = Enemy(0, 'pigeon', 300);
      expect(bird.animalMode, 'perch');
      expect(bird.flightAltitude, 0);
      bird.advanceAnimal(.10, 450, groundY);
      expect(bird.animalMode, 'takeoff');
      final x = bird.x;
      bird.advanceAnimal(.07, 450, groundY);
      expect(bird.flightAltitude, 0);
      expect(bird.x, x);
      bird.advanceAnimal(.20, 450, groundY);
      expect(bird.flightAltitude, greaterThan(25));
      expect(bird.flightAltitude, lessThan(83));
      bird.advanceAnimal(.36, 450, groundY);
      expect(bird.animalMode, 'flap');
      expect(bird.flightAltitude, closeTo(82, .001));
    });

    test('La paloma avisa antes del picado y fija la dirección de ataque', () {
      final bird = Enemy(1, 'pigeon', 300)..attackCooldown = 0;
      bird.advanceAnimal(.10, 450, groundY);
      bird.advanceAnimal(.60, 450, groundY);
      bird.advanceAnimal(.10, 450, groundY);
      expect(bird.animalMode, 'dive_warning');
      final heading = bird.facing;
      expect(bird.advanceAnimal(.20, 250, groundY), isFalse);
      expect(bird.animalMode, 'dive_warning');
      expect(bird.advanceAnimal(.03, 250, groundY), isFalse);
      expect(bird.animalMode, 'dive');
      expect(bird.advanceAnimal(.4, 250, groundY), isFalse);
      expect(bird.facing, heading);
      expect(bird.flightAltitude, lessThan(82));
    });

    test('El aterrizaje baja sin saltar a una posición fija en el aire', () {
      final bird = Enemy(0, 'pigeon', 300)
        ..animalMode = 'landing'
        ..flightAltitude = 80;
      bird.advanceAnimal(.25, 900, groundY);
      expect(bird.flightAltitude, closeTo(59.5, .001));
      bird.advanceAnimal(.90, 900, groundY);
      expect(bird.flightAltitude, 0);
      expect(bird.animalMode, 'perch');
    });
  });
}
