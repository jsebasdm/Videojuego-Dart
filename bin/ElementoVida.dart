// Archivos Externos
import 'package:meta/meta.dart';

// Clase Abstracta (Mixin)
abstract class ElementoVida {
  // Campos de Instancia
  int numActualVidas;
  int numTotalVidas;

  // Métodos
  void restarVida() => numActualVidas -= 1;
  bool get finVidas => (numActualVidas <= 0);
}