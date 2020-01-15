// Archivos Externos
import 'ElementoVida.dart';

// Clase
class Ciudad extends ElementoVida {
  // Constantes Estáticas
  static const int numeroVidasCiudad = 2;

  // Constructor
  Ciudad() {
    numTotalVidas = numeroVidasCiudad;
    numActualVidas = numTotalVidas;
  }

}