
Tengo la siguiente lista
[
  { 'ID_incremental': 1, 'Elemento_tipo': 1, 'ID_elemento': 1, 'Longitud': 12.0, 'NodoIncio': '0effd11a', 'NodoFin': '47dc7570', 'Direccion': 'Arriba' },
  { 'ID_incremental': 2, 'Elemento_tipo': 1, 'ID_elemento': 1, 'Longitud': 5.0, 'NodoIncio': '47dc7570', 'NodoFin': '4d9f7a02', 'Direccion': 'Izquierda' },
  { 'ID_incremental': 3, 'Elemento_tipo': 1, 'ID_elemento': 1, 'Longitud': 8.0, 'NodoIncio': '47dc7570', 'NodoFin': '02658be0', 'Direccion': 'Atrás' },
  { 'ID_incremental': 4, 'Elemento_tipo': 1, 'ID_elemento': 1, 'Longitud': 3.0, 'NodoIncio': '4d9f7a02', 'NodoFin': '245ab470', 'Direccion': 'Izquierda' }
]

Necesito que se agrupen por tramos, es decir, si el nodo de inicio de un elemento es igual al nodo de fin de otro elemento, entonces esos elementos pertenecen al mismo tramo hasta que encuentre una bifurcacion, donde el nodo de incio sea el mismo que el nodo de fin de al menos 2 tramos (como una Y).
Separación de tramos en bifurcaciones: Cada vez que encontramos más de una conexión desde el mismo nodo (conexiones.length > 1), creamos un nuevo tramo para cada camino en la bifurcación. Es decir, los registros de una bifurcación se procesan por separado y  seguimos añadiendo elementos al tramo hasta que no haya más conexiones.
Continuidad de los tramos: Si solo hay una conexión desde un nodo (conexiones.length == 1), simplemente seguimos añadiendo elementos al tramo hasta que no haya más conexiones.


La salida esperada sería:
TRAMO 1:
[{ID_incremental: 1, Elemento_tipo: 1, ID_elemento: 1, Longitud: 12.0, NodoIncio: 0effd11a, NodoFin: 47dc7570, Direccion: Arriba}]
TRAMO 2:
[{ID_incremental: 2, Elemento_tipo: 1, ID_elemento: 1, Longitud: 5.0, NodoIncio: 47dc7570, NodoFin: 4d9f7a02, Direccion: Izquierda},
 {ID_incremental: 4, Elemento_tipo: 1, ID_elemento: 1, Longitud: 3.0, NodoIncio: 4d9f7a02, NodoFin: 245ab470, Direccion: Izquierda}]
TRAMO 3:
[{ID_incremental: 3, Elemento_tipo: 1, ID_elemento: 1, Longitud: 8.0, NodoIncio: 47dc7570, NodoFin: 02658be0, Direccion: Atrás}]

Dame una function que lo realice:
void TrazarInstalacion(List<Map<String, dynamic>> listaElementosJson) {



  Devuelve actualmente eso:
  I/flutter (20908): TRAMO 1:
I/flutter (20908): {ID_incremental: 1, Elemento_tipo: 1, ID_elemento: 1, Longitud: 12.0, NodoIncio: 0effd11a, NodoFin: 47dc7570, Direccion: Arriba}
I/flutter (20908): TRAMO 2:
I/flutter (20908): {ID_incremental: 2, Elemento_tipo: 1, ID_elemento: 1, Longitud: 5.0, NodoIncio: 47dc7570, NodoFin: 4d9f7a02, Direccion: Izquierda}
I/flutter (20908): {ID_incremental: 3, Elemento_tipo: 1, ID_elemento: 1, Longitud: 8.0, NodoIncio: 47dc7570, NodoFin: 02658be0, Direccion: Atrás}
I/flutter (20908): TRAMO 3:
I/flutter (20908): {ID_incremental: 4, Elemento_tipo: 1, ID_elemento: 1, Longitud: 3.0, NodoIncio: 4d9f7a02, NodoFin: 245ab470, Direccion: Izquierda}
_____________

 print("Tramo actual del for: " + tramos[i].toString());
      //ciclo para recorer cada diametro
      longitud = CalcularLongitudTramo(tramos[i]);
      longEquivalente = longitud * 1.2;
      Material = "Galvanizado";
      if (i == 0) {
        //si es el primer registro
        Qs = CalcularConsumoTotal(tramos, equiposLista);
        //Qs = la suma de todos los consumos de los equipos
        //Pi = troncal - 1.2
      } else {
        // calcular consumo total del tramo
        Qs = CalcularConsumoEnTramo(tramos[i], equiposLista);
      }
      print("consumo: " + Qs.toString());
      print("Longitud total del tramo: " + longitud.toString());
    }






     



  AGREGAR UNA VALVULA ANTES DE CADA EQUI AL INSERTAR EL EQUIPO
TERMINAR EL METODO PARA BUSCAR SI HAY REGULADORES Y DEFINIR LA PRESION PF

REGRESAR LISTA DE NODOS CON LETRA PARA DIBUJAR
METODOD E DIBUJO EN CANVAS DESDE JSON



        nodofinalx
        nodoFinOffset.dx, dy




    print(elementoController.getListaJson());