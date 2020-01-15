// Archivos Externos
import 'CalculadorPosiciones.dart';
import 'Ciudad.dart';
import 'Consola.dart';
import 'Coordenada.dart';
import 'Direccion.dart';
import 'ElementoMovil.dart';
import 'Enemigo.dart';
import 'NaveJugador.dart';
import 'Proyectil.dart';
import 'Limite.dart';

// Clase
class Juego {
  // Constantes Estáticas
  static const int _valorEnemigoDestruido = 50;

  // Campos de Instancia
  Ciudad _ciudad;
  NaveJugador naveJugador;
  List<Proyectil> listaProyectiles;
  List<Enemigo> listaEnemigos;
  int _puntaje;
  bool finalizado;

  // Constructor
  Juego() {
    // Incializar Campos
    finalizado = false;
    _puntaje = 0;
    _ciudad = Ciudad();
    naveJugador = NaveJugador(puntoInicial: CalculadorPosiciones.calcularPosInicialNave());
    listaEnemigos = List<Enemigo>();
    listaProyectiles = List<Proyectil>();
    // Generar Primeros Enemigos
    _regenerarEnemigos();
  }

  // Métodos
  // Método Crear/Regenerar Enemigos
  void _regenerarEnemigos() {
    while (listaEnemigos.length < Enemigo.minimaCantEnemigos) {
      _reordenarEnemigosPosicion();
      Enemigo nuevoEnemigo = Enemigo(puntoInicial: CalculadorPosiciones.calcularPosInicialNuevoEnemigo(listaEnemigos));
      listaEnemigos.add(nuevoEnemigo);
    }
  }

  // Método Reordenar Enemigos por Posición
  void _reordenarEnemigosPosicion() {
    listaEnemigos.sort((enemigoA, enemigoB) {
      int posicionEnemigoA = enemigoA.posicionActual.esquinaSuperior.posicionX;
      int posicionEnemigoB = enemigoB.posicionActual.esquinaSuperior.posicionX;
      return posicionEnemigoA.compareTo(posicionEnemigoB);
    });
  }

  // Método Finalizar Juego
  void finalizarJuego() => finalizado = true;

  // Método Operaciones Previas a Impresión de Pantalla
  void precargarSiguienteJugada() {
    _regenerarEnemigos();
    naveJugador.aumentarCargaProyectil();
    _reaparecerNaveJugador();
  }

  // Método Cargar Siguiente Jugada
  void siguienteJugada() {
    if (finalizado) return;
    // Desplazamiento de Elementos
    _desplazarElementosSiguienteFrame();
    // Operaciones Posteriores a Desplazamiento de Elementos
    _verificarColisionEnemigosNave();
    _verificarColisionEnemigosProyectiles();
    _verificarLimiteProyectiles();
    _verificarLimiteCiudadEnemigos();
    _verificarFinJuego();
  }

  // Método Cambiar Movimientos Nave Jugador
  void cambiarMovimientosNave(int posiciones) => naveJugador.posicionesMovimiento = posiciones;

  // Método Mover Elementos Siguiente Frame
  void _desplazarElementosSiguienteFrame() {
    // Desplazar Enemigos
    listaEnemigos.asMap().forEach((indice, enemigo) => listaEnemigos[indice].desplazar(Direccion.Vertical));
    // Desplazar Nave
    naveJugador.desplazar(Direccion.Horizontal);
    // Desplazar Proyectiles
    listaProyectiles.asMap().forEach((indice, enemigo) => listaProyectiles[indice].desplazar(Direccion.Vertical));
  }

  // Método Generar Proyectil
  void generarProyectil() {
    // Verificar carga de proyectil
    if (!naveJugador.proyectilDisponible || !naveJugador.activa) return;
    // Crear proyectil en juego
    Coordenada puntoProyectil = CalculadorPosiciones.calcularPosInicialProyectil(naveJugador);
    listaProyectiles.add(Proyectil(puntoInicial: puntoProyectil));
    // Vaciar carga de proyectil
    naveJugador.cargaActualProyectil = -1;
  }

  // Información Relevantee Juego
  String informacioRelevanteJuego() {
    String mensaje = 'PUNTAJE: $_puntaje \n';
    mensaje += 'Vida Ciudad: ${_ciudad.numActualVidas} / ${Ciudad.numeroVidasCiudad} \n';
    mensaje += 'Vida Nave: ${naveJugador.numActualVidas} / ${NaveJugador.numeroVidasNave} \n';
    if (naveJugador.activa)
      mensaje += 'Carga Proyectil: ${naveJugador.cargaActualProyectil} / ${NaveJugador.valorProyectilCargado}';
    return mensaje;
  }

  // Método Verificar Colisión de Enemigos con Nave
  void _verificarColisionEnemigosNave() {
    // Verificar que la nave esté activa
    if (!naveJugador.activa) return;
    // Identificar enemigo que colisionó con nave
    int indiceEnemigoRemover;
    listaEnemigos.asMap().forEach((indiceEnemigo, enemigo) {
      if (CalculadorPosiciones.verificarColision(naveJugador, enemigo)) indiceEnemigoRemover = indiceEnemigo;
    });
    // Remover enemigo, desactivar nave y restar vida
    if (indiceEnemigoRemover != null) {
      listaEnemigos.removeAt(indiceEnemigoRemover);
      naveJugador.activa = false;
      print('¡LA NAVE HA COLISIONADO CON UN ENEMIGO!');
      naveJugador.restarVida();
    }
  }

  // Reaparecer Nave Inactiva Jugador
  void _reaparecerNaveJugador() {
    // No reaparecer nave si ya está activa
    if (naveJugador.activa) return;
    // Verificar si posición inicial sólo si está libre de enemigos
    bool posicionInicialLibre = true;
    var naveFantasma = NaveJugador(puntoInicial: CalculadorPosiciones.calcularPosInicialNave());
    for (var enemigo in listaEnemigos) {
      if (CalculadorPosiciones.verificarColision(naveFantasma, enemigo)) posicionInicialLibre = false;
    }
    // Aparecer nave en posición inicial (si está libre)
    if (posicionInicialLibre) naveJugador.reiniciarNave();
  }

  // Método Verificar Colisión de Enemigos con Proyectiles
  void _verificarColisionEnemigosProyectiles() {
    // Identificar lista de enemigos y proyectiles que colisionaron
    var indicesEnemigosRemover = <int>{};
    var indicesProyectilesRemover = <int>{};
    // Recorrer enemigos y proyectiles al tiempo
    listaEnemigos.asMap().forEach((indiceEnemigo, enemigo) {
      listaProyectiles.asMap().forEach( (indiceProyectil, proyectil) {
        if (CalculadorPosiciones.verificarColision(enemigo, proyectil)) {
          indicesEnemigosRemover.add(indiceEnemigo);
          indicesProyectilesRemover.add(indiceProyectil);
        }
      });
    });
    // Remover Enemigos Colisionados
    for (int indice in _ordenInverso(indicesEnemigosRemover)) {
      listaEnemigos.removeAt(indice);
      _aumentarPuntajeEnemigo();
      print('¡Felicitaciones: Has derribado a un enemigo!');
    }
    // Remover Proyectiles Colisionados
    for (int indice in _ordenInverso(indicesProyectilesRemover)) listaProyectiles.removeAt(indice);
  }

  // Aumentar Puntaje al Destruir Enemigo
  void _aumentarPuntajeEnemigo() => _puntaje += _valorEnemigoDestruido;

  // Eliminar Proyectiles en Línea Base Enemiga (cerca de salir de pantalla)
  void _verificarLimiteProyectiles() {
    int posLineaLimite = CalculadorPosiciones.limiteProyectiles;
    Set<int> indicesProyectilesRemover = _indicesRemoverLimite(listaProyectiles, Limite.Superior, posLineaLimite);
    // Remover proyectiles que superaron el límite superior
    for (int indice in _ordenInverso(indicesProyectilesRemover)) listaProyectiles.removeAt(indice);
  }

  // Eliminar Enemigos al Alcanzar Ciudad
  void _verificarLimiteCiudadEnemigos() {
    int posLineaLimite = Consola.altoPantalla - 1;
    Set<int> indicesEnemigosRemover = _indicesRemoverLimite(listaEnemigos, Limite.Inferior, posLineaLimite);
    // Remover enemigos que colisionaron con ciudad y restar vida
    for (int indice in _ordenInverso(indicesEnemigosRemover)) {
      listaEnemigos.removeAt(indice);
      print('¡UN ENEMIGO HA GOLPEADO LA CIUDAD!');
      _ciudad.restarVida();
    }
  }

  // Índices Elementos Remover según Límite
  Set<int> _indicesRemoverLimite(List<ElementoMovil> listaElementos, Limite limite, int posLineaLimite) {
    var indicesElementosRemover = <int>{};
    listaElementos.asMap().forEach( (indice, elemento) {
      if (CalculadorPosiciones.verificarLimiteSuperado(limite, elemento.posicionActual, posLineaLimite)) {
        indicesElementosRemover.add(indice);
      }
    });
    return indicesElementosRemover;
  }

  // Método Auxiliar: Ordenar Set Inversamente
  List<int> _ordenInverso(Set<int> setValores) {
    List<int> listaValores = setValores.toList();
    listaValores.sort((b, a) => a.compareTo(b));
    return listaValores;
  }

  // Verificar Fin Juego según Vidas
  void _verificarFinJuego() {
    // Verificar Vidas Ciudad
    if (!_ciudad.finVidas && !naveJugador.finVidas) return;
    if (_ciudad.finVidas) print('¡EL JUEGO HA TERMINADO: LA CIUDAD HA PERDIDO SUS VIDAS!');
    if (naveJugador.finVidas) print('¡EL JUEGO HA TERMINADO: LA NAVE HA PERDIDO SUS VIDAS!');
    print('PUNTAJE FINAL: $_puntaje');
    finalizado = true;
  }

}
