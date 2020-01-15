// Archivos Externos
import 'package:meta/meta.dart';
import 'Coordenada.dart';
import 'Direccion.dart';
import 'Superficie.dart';

// Clase Abstracta
abstract class ElementoMovil {
  // Campos de Instancia
  Coordenada puntoInicial;
  Superficie posicionActual;
  int ancho;
  int alto;
  int posicionesMovimiento;

  // Constructor
  ElementoMovil({@required this.ancho, @required this.alto, @required this.puntoInicial, this.posicionesMovimiento}) {
    this.posicionActual = Superficie();
    moverAPosicionInicial();
  }

  // Métodos
  // Mover Nave a Posición Inicial
  void moverAPosicionInicial() {
    // La esquina superior izquierda corresponde al punto inicial
    this.posicionActual.esquinaSuperior = puntoInicial;
    _actualizarEsquinaInferior();
  }

  // Actualizar Esquina Inferior Nave según Esquina Superior, Ancho y Alto
  void _actualizarEsquinaInferior() {
    int nuevaPosYInferior = this.posicionActual.esquinaSuperior.posicionY + alto - 1;
    int nuevaPosXDerecha = this.posicionActual.esquinaSuperior.posicionX + ancho - 1;
    this.posicionActual.esquinaInferior = Coordenada(nuevaPosXDerecha, nuevaPosYInferior);
  }

  // Desplazar Elemento
  void desplazar(Direccion direccion){
    // Desplazar Esquina Superior
    if (direccion == Direccion.Vertical) {
      int nuevaPosX = this.posicionActual.esquinaSuperior.posicionX;
      int nuevaPosY = this.posicionActual.esquinaSuperior.posicionY + posicionesMovimiento;
      this.posicionActual.esquinaSuperior = Coordenada(nuevaPosX, nuevaPosY);
    }
    if (direccion == Direccion.Horizontal) {
      int nuevaPosX = this.posicionActual.esquinaSuperior.posicionX + posicionesMovimiento;
      int nuevaPosY = this.posicionActual.esquinaSuperior.posicionY;
      this.posicionActual.esquinaSuperior = Coordenada(nuevaPosX, nuevaPosY);
    }
    // Desplazar Esquina Inferior
    _actualizarEsquinaInferior();
  }

}
