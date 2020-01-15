// Archivos Externos
import 'package:meta/meta.dart';
import 'Coordenada.dart';
import 'ElementoMovil.dart';

// Clase
class Enemigo extends ElementoMovil {
  // Constantes Estáticas
  static const int minimaCantEnemigos = 3;
  static const int anchoEnemigos = 3;
  static const int altoEnemigos = 2;

  // Constructor
  Enemigo({@required Coordenada puntoInicial})
      : super(alto: altoEnemigos, ancho: anchoEnemigos, puntoInicial: puntoInicial, posicionesMovimiento : 1);

}
