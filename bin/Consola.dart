// Librerías Dart
import 'dart:io';

// Archivos Externos
import 'CalculadorPosiciones.dart';
import 'Coordenada.dart';
import 'Direccion.dart';
import 'ElementoMovil.dart';
import 'Juego.dart';

// Clase
class Consola {
  // Constantes Estáticas
  static const int altoPantalla = 15;
  static const int anchoPantalla = 30;
  static const Map<String, String> _caracteres = {
    'vacio': '-',
    'nave': '█',
    'enemigo': '▼',
    'proyectil': '●',
    'bordeLateral': '║',
    'bordeHorizontal': '═',
  };
  static const List<String> _instruccionesValidas = ['', 'q', 'p'];

  // Campos de Instancia
  Juego _juego;

  // Constructor
  Consola(this._juego);

  // Métodos
  // Imprimir Juego en Pantalla con Caracteres
  void _imprimirJuego() {
    print(_juego.informacioRelevanteJuego()); // Mostrar Información
    mostrarTablero();
  }

  // Mostrar Tablero
  void mostrarTablero() {
    List<String> matrizCaracteres = _crearMatrizCaracteres();
    matrizCaracteres.forEach((fila) => print(fila));
  }

  // Crear Matriz Caracteres
  List<String> _crearMatrizCaracteres() {
    // Inicializar matriz de caracteres
    var matrizCaracteres = List<String>(altoPantalla);
    // Recorrer posiciones
    for (int y = 0; y < altoPantalla; y++) {
      String linea = '';
      for (int x = 0; x < anchoPantalla; x++) linea += _caracterElementoPosicion(x, y);
      matrizCaracteres[y] = linea;
    }
    return matrizCaracteres;
  }

  // Verificar Presencia Elemento y Asignar Caracter
  String _caracterElementoPosicion(int x, int y) {
    // Verificar todos los elementos móviles
    if (_verificarBorde(x, y, Direccion.Horizontal)) return _caracteres['bordeHorizontal'];
    if (_verificarBorde(x, y, Direccion.Vertical)) return _caracteres['bordeLateral'];
    if (_verificarPresenciaElemento(x, y, [_juego.naveJugador]) && _juego.naveJugador.activa) return _caracteres['nave'];
    if (_verificarPresenciaElemento(x, y, _juego.listaEnemigos)) return _caracteres['enemigo'];
    if (_verificarPresenciaElemento(x, y, _juego.listaProyectiles)) return _caracteres['proyectil'];
    return _caracteres['vacio'];
  }

  // Verificar Borde
  bool _verificarBorde(int x, int y, Direccion direccion) {
    // Verificar Dirección Vertical (Borde Izquierdo y Derecho)
    if (direccion == Direccion.Vertical) {
      bool lineaIzquierda = (x == 0);
      bool lineaDerecha = (x == anchoPantalla - 1);
      if (lineaIzquierda || lineaDerecha) return true;
    }
    // Verificar Dirección Horizontal (Borde Superior e Inferior)
    if (direccion == Direccion.Horizontal) {
      bool lineaSuperior = (y == 0);
      bool lineaInferior = (y == altoPantalla - 1);
      if (lineaSuperior || lineaInferior) return true;
    }
    return false;
  }

  // Verificar Presencia Elemento Móvil
  bool _verificarPresenciaElemento(int x, int y, List<ElementoMovil> listaElementos) {
    Coordenada punto = Coordenada(x, y);
    for (var elemento in listaElementos) {
      if (CalculadorPosiciones.coordenadaEnSuperficie(punto, elemento.posicionActual)) return true;
    }
    return false;
  }

  // Método Pedir por Teclado Siguiente Jugada (Frame)
  void ejecutarSiguienteJugada() {
    _juego.precargarSiguienteJugada();
    _imprimirJuego();
    String textoEntrada = _leerInstruccionTeclado().trim().toLowerCase();
    _ejecutarInstruccion(textoEntrada);
    _juego.siguienteJugada();
  }

  // Método Leer teclas presionados por turno
  String _leerInstruccionTeclado() {
    print('Ingrese siguiente movimiento: ');
    String entrada = stdin.readLineSync();
    while (!_validarInstruccion(entrada)) {
      print('La instrucción ingresada es inválida. Ingrese de nuevo el siguiente movimiento: ');
      entrada = stdin.readLineSync();
    }
    return entrada;
  }

  // Validar Instruccion
  bool _validarInstruccion(String texto) {
    // Validar respuesta si es un número o si está en la lista de textos válidos
    if (_instruccionesValidas.contains(texto)) return true;
    if (_textoEsNumero(texto)) return true;
    return false;
  }

  // Validar Texto como Número
  bool _textoEsNumero(String texto) => (num.tryParse(texto) != null);

  // Metodo Decisión según Instrucción Teclado
  void _ejecutarInstruccion(String textoEntrada) {
    // Opción 1: Finalizar Juego
    if (textoEntrada == "q") {
      _juego.finalizarJuego();
      return;
    }

    // Opción 2: Disparar Proyectil
    if (textoEntrada == 'p') _juego.generarProyectil();

    // Opción 2: Cambiar Posiciones Movimiento Nave
    if (_textoEsNumero(textoEntrada)) _juego.cambiarMovimientosNave(int.parse(textoEntrada));
    else _juego.cambiarMovimientosNave(0);
  }

}
