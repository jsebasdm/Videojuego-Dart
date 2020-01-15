// Archivos Externos
import 'package:meta/meta.dart';
import 'Consola.dart';
import 'Coordenada.dart';
import 'Direccion.dart';
import 'ElementoMovil.dart';
import 'ElementoVida.dart';

// Clase
class NaveJugador extends ElementoMovil with ElementoVida {
  // Constantes Estáticas
  static const int valorProyectilCargado = 3;
  static const int anchoNaves = 3;
  static const int _altoNaves = 1;
  static const int numeroVidasNave = 3;

  // Campos de Instancia Propios
  int cargaActualProyectil;
  bool activa;

  // Constructor
  NaveJugador({@required Coordenada puntoInicial})
      : super(alto: _altoNaves, ancho: anchoNaves, puntoInicial: puntoInicial, posicionesMovimiento: 0) {
    numTotalVidas = numeroVidasNave;
    numActualVidas = numTotalVidas;
    reiniciarNave();
  }

  // Métodos GET Campos Calculados
  bool get proyectilDisponible => (cargaActualProyectil >= valorProyectilCargado);

  // Verificar Límites al Desplazar
  @override
  void desplazar(Direccion direccion){
    // Verificar Límite Izquierdo
    int nuevaPosXIzquierda = posicionActual.esquinaSuperior.posicionX + posicionesMovimiento;
    if (nuevaPosXIzquierda < 1) posicionesMovimiento = -1 * (posicionActual.esquinaSuperior.posicionX - 1);

    // Verificar Límite Derecho
    int nuevaPosXDerecha = posicionActual.esquinaInferior.posicionX + posicionesMovimiento;
    int posMaxima = Consola.anchoPantalla - 2;
    if (nuevaPosXDerecha > posMaxima) posicionesMovimiento = posMaxima - posicionActual.esquinaInferior.posicionX;

    // Desplazar con límites verificados
    if (activa) super.desplazar(direccion);
  }

  // Métodos Propios Clase Nave
  void aumentarCargaProyectil() {
    if (activa && !proyectilDisponible) cargaActualProyectil +=1;
  }

  void reiniciarNave() {
    activa = true;
    cargaActualProyectil = valorProyectilCargado; // Iniciar proyectil cargado
    moverAPosicionInicial();
  }

}