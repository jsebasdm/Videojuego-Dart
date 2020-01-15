// Archivos Externos
import 'dart:math';
import 'Consola.dart';
import 'Coordenada.dart';
import 'ElementoMovil.dart';
import 'Enemigo.dart';
import 'Limite.dart';
import 'NaveJugador.dart';
import 'Proyectil.dart';
import 'Superficie.dart';

// Clase
class CalculadorPosiciones {
  // Constantes Estáticas
  static const double _porcentajeLineaNave = 0.8;
  static const double _porcentajeLineaInicialEnemigos = 0.1;
  static final int _posicionYEnemigos = (_porcentajeLineaInicialEnemigos * Consola.altoPantalla).toInt();
  static final int limiteProyectiles = _posicionYEnemigos + Enemigo.altoEnemigos - 1;

  // Método Cálculo Posición Inicial Nave
  static Coordenada calcularPosInicialNave() {
    // Calcular Posición Inicial X
    int posXMedio = Consola.anchoPantalla ~/ 2;
    int mitadAnchoNave = NaveJugador.anchoNaves ~/ 2;
    int posXInicial = posXMedio - mitadAnchoNave;
    // Calcular Posición Inicial Y
    int posYInicial = (_porcentajeLineaNave * Consola.altoPantalla).toInt();
    return Coordenada(posXInicial, posYInicial);
  }

  // Método Cálculo Posición Inicial Nuevo Enemigo
  static Coordenada calcularPosInicialNuevoEnemigo(List<Enemigo> listaEnemigos) {
    // Calcular Posición Inicial X
    var listaRangos = _obtenerRangosOcupadosEnemigos(listaEnemigos);
    listaRangos = _calcularRangosLista(listaRangos, Consola.anchoPantalla);
    var listaDisponibles = _obtenerNumDisponibles(listaRangos, Enemigo.anchoEnemigos);
    int posXInicial = _escogerValorAleatorio(listaDisponibles);
    return Coordenada(posXInicial, _posicionYEnemigos);
  }

  // Métodos Auxiliares
  // Método Obtener Rangos de Posiciones Ocupadas por Enemigos
  static List<Map<String, int>> _obtenerRangosOcupadosEnemigos(List<Enemigo> listaEnemigos) {
    // Obtener lista de la forma: [{'inicio':0}, {'inicio': 5}, {'inicio': 8}, ... ]
    // ... según espacios ocupados por Enemigos en Línea Inicial
    var listaRangos = List<Map<String, int>>();
    listaRangos.add({'inicio': 0}); // Inicialización
    listaEnemigos.forEach( (enemigo) {
      listaRangos.add({'inicio' : enemigo.posicionActual.esquinaSuperior.posicionX});
      listaRangos.add({'inicio' : enemigo.posicionActual.esquinaInferior.posicionX + 1});
    });
    return listaRangos;
  }

  // Método Calcular Rango en Lista
  static List<Map<String, int>> _calcularRangosLista(List<Map<String, int>> listaRangos, int total) {
    // Partiendo de variable "listaRangos" de la forma: [{'inicio':0}, {'inicio': 5}, {'inicio': 8}, ... ]
    // ...Completar variable "listaRangos" así: [{'inicio': 0, 'rango': 5, {'inicio': 5, 'rango': 3}, ... ]
    listaRangos.asMap().forEach((indice, rango) {
      if (rango == listaRangos.last)
        listaRangos[indice]['rango'] = total - rango['inicio'];
      else
        listaRangos[indice]['rango'] = listaRangos[indice + 1]['inicio'] - rango['inicio'];
    });
    return listaRangos;
  }

  // Método Obtener Número Disponibles
  static List<int> _obtenerNumDisponibles(List<Map<String, int>> listaRangos, int anchoElemento) {
    // Partiendo de variable "listaRangos" de la forma: [{'inicio': 0, 'rango': 5, {'inicio': 5, 'rango': 3}, ... ]
    // ... Obtener números de posiciones disponibles para insertar objeto con determinado ancho (a la izquierda)
    var disponibles = List<int>();
    listaRangos.forEach((rango) {
      int margen = 1;
      int espacioMinimo = anchoElemento + 2 * margen;
      if (rango['rango'] >= espacioMinimo) {
        int numDisponibles = rango['rango'] - anchoElemento - margen;
        for (int indice = 0; indice < numDisponibles; indice++) {
          disponibles.add(rango['inicio'] + indice + margen);
        }
      }
    });
    // Evitar enemigo en borde izquierdo
    if (disponibles.contains(0)) disponibles.remove(0);
    return disponibles;
  }

  // Método Escoger Valor Aleatorio Lista
  static int _escogerValorAleatorio(List<int> lista) {
    int indice = Random().nextInt(lista.length);
    return lista[indice];
  }

  // Método Cálculo Posición Proyectil según Centro Nave
  static Coordenada calcularPosInicialProyectil(NaveJugador naveJugador) {
    // Calcular posición X de esquina superior (Proyectil centrado según nave)
    int posXCentro = naveJugador.posicionActual.esquinaSuperior.posicionX + (NaveJugador.anchoNaves ~/ 2);
    int posXIzquierdaProyectil = posXCentro - (Proyectil.anchoProyectiles ~/ 2);
    // Retornar coordenada con posiciones X y Y del proyectil
    return Coordenada(posXIzquierdaProyectil, naveJugador.posicionActual.esquinaSuperior.posicionY);
  }

  // Método Verificar Colisión entre Elementos Móviles
  static bool verificarColision(ElementoMovil elementoA, ElementoMovil elementoB) {
    // Identificar cuál rectángulo es el superior y cuál el inferior
    bool inferiorA = _primerRectanguloInferior(elementoA.posicionActual, elementoB.posicionActual);
    Superficie rectInferior = (inferiorA) ? elementoA.posicionActual : elementoB.posicionActual;
    Superficie rectSuperior = (inferiorA) ? elementoB.posicionActual : elementoA.posicionActual;

    // Opción Colisión 1: Esquina superior izquierda de rectángulo inferior, al interior de rectángulo superior
    bool opcion1 = coordenadaEnSuperficie(rectInferior.esquinaSuperior, rectSuperior);

    // Opción Colisión 2: Esquina superior derecha de rectángulo inferior, al interior de rectángulo superior
    Coordenada esquinaSD = Coordenada(rectInferior.esquinaInferior.posicionX, rectInferior.esquinaSuperior.posicionY);
    bool opcion2 = coordenadaEnSuperficie(esquinaSD, rectSuperior);

    // Colisión existente en cualquiera de los dos casos
    return (opcion1 || opcion2);
  }

  // Método Identificar si Primer Rectángulo es Inferior al Segundo
  static bool _primerRectanguloInferior(Superficie rectanguloA, Superficie rectanguloB) {
    return (rectanguloA.esquinaSuperior.posicionY > rectanguloB.esquinaSuperior.posicionY);
  }

  // Método Verificar Coordenada al Interior Superficie
  static bool coordenadaEnSuperficie(Coordenada punto, Superficie superficie) {
    // Extraer información en variables individuales
    int x = punto.posicionX;
    int y = punto.posicionY;
    Coordenada superiorIzquierdo = superficie.esquinaSuperior;
    Coordenada inferiorDerecho = superficie.esquinaInferior;

    // Verificar punto en interior de límites de la superficie, horizontal y verticalmente
    bool cumpleRangoHorizontal = (x >= superiorIzquierdo.posicionX && x <= inferiorDerecho.posicionX);
    bool cumpleRangoVertical = (y >= superiorIzquierdo.posicionY && y <= inferiorDerecho.posicionY);
    return (cumpleRangoHorizontal && cumpleRangoVertical);
  }

  // Método Verificar Superación Línea por Figura
  static bool verificarLimiteSuperado(Limite limite, Superficie rectangulo, int valorPosicionLinea) {
    // Límite superior: Verificar si rectángulo está por encima de línea
    if (limite == Limite.Superior) {
      int valorPosRectangulo = rectangulo.esquinaSuperior.posicionY;
      if (valorPosRectangulo <= valorPosicionLinea) return true;
    }
    // Límite inferior: Verificar si rectángulo está por debajo de línea
    if (limite == Limite.Inferior) {
      int valorPosRectangulo = rectangulo.esquinaInferior.posicionY;
      if (valorPosRectangulo >= valorPosicionLinea) return true;
    }
    // Si no se cumple ningún caso, retornar falso
    return false;
  }

}