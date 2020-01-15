// Archivos Externos
import 'package:meta/meta.dart';
import 'Coordenada.dart';
import 'ElementoMovil.dart';

// Clase
class Proyectil extends ElementoMovil {
  // Constantes Estáticas
  static const int anchoProyectiles = 1;
  static const int altoProyectiles = 2;

  // Constructor
  Proyectil({@required Coordenada puntoInicial})
      : super(alto: altoProyectiles, ancho: anchoProyectiles, puntoInicial: puntoInicial, posicionesMovimiento : -1);
}
