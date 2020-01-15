import 'Coordenada.dart';

// Clase
class Superficie {
  // Campos de Instancia
  Coordenada esquinaSuperior;
  Coordenada esquinaInferior;

  // Constructor
  Superficie([esquinaSuperior = const Coordenada(0,0), esquinaInferior = const Coordenada(0,0)]) {
    this.esquinaSuperior = esquinaSuperior;
    this.esquinaInferior = esquinaInferior;
  }
}
