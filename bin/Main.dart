// Archivos Externos
import 'Consola.dart';
import 'Juego.dart';

// Función Principal
void main() {
  // Inicializar Consola y Juego
  Juego juego = Juego();
  Consola consola = Consola(juego);
  // Ejecutar Juego
  while (!juego.finalizado) consola.ejecutarSiguienteJugada();
  consola.mostrarTablero();
}
