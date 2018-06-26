# Bases Of Empires:Simulador de batallas en la BD

Proyecto final de curso de programacion con bases de datos. 
Cenfotec, segundo cuatrimestre 2018.

## Equipo

<pre>                                          88             88  
                                          ""             ""                     
 ,adPPYb,d8  ,adPPYba, 88,dPYba,,adPYba,  88 8b,dPPYba,  88 ,adPPYba, 
a8"    `Y88 a8P_____88 88P'   "88"    "8a 88 88P'   `"8a 88 I8[    ""  
8b       88 8PP""""""" 88      88      88 88 88       88 88 `"Y8ba,  
"8a,   ,d88 "8b,   ,aa 88      88      88 88 88       88 88 aa    ]8I   
 `"YbbdP"Y8  `"Ybbd8"' 88      88      88 88 88       88 88 `"YbbdP"'  
 aa,    ,88                                                  
  "Y8bbdP"    
</pre>

## Objetivos

TODO
Pasar el curso?

## Descripción del Juego

TODO

## Reglas de mercado

TODO

## Diseño de la BD

[Diagrama de tablas](https://app.sqldbm.com/SQLServer/Share/vaPWDBZM5myciITitZQc_kGFrngIE8md_DYjF4jNYw0)

## Descripción de cada tabla

### REINOS

| Columna | Tipo de dato | Longitud | Nulo |  Descripción |
| :---         |     :---:      |     :---:      |     :---:      | :---         |
| PTS_ATQ |NUMBER |22 |No | Puntos de ataque del reino |
| PTS_DEF |NUMBER |22 |No | Puntos de defensa del reino |
| CANT_CORONAS |NUMBER |22 |No | Coronas del reino |
| MES |CHAR |3 |No | Mes representativo |
| LOGOTIPO |VARCHAR2 |2000 |No | Logotipo del reino |
| NOMBRE |VARCHAR2 |20 |No | Nombre del reino |

### BITACORAS

| Columna | Tipo de dato | Longitud | Nulo |  Descripción |
| :---         |     :---:      |     :---:      |     :---:      | :---         |
| TRANSACCION |CHAR |3 |No | Tipo de transaccion |
| CORONAS |NUMBER |22 |No | Cantidad de coronas que tenia el reino cuando se hizo la transaccion |
| RECURSOS |VARCHAR2 |2000 |No | Desglose de los recursos y cantidad de cada uno que tiene el reino cuando se hizo la transaccion |
| FECHA_Y_HORA |DATE |7 |No | Fecha y hora en la que se hizo la transaccion |
| NOMBRE_REINO |VARCHAR2 |20 |No | Nombre del reino que hizo la transaccion |

### TROPAS

| Columna | Tipo de dato | Longitud | Nulo |  Descripción |
| :---         |     :---:      |     :---:      |     :---:      | :---         |
| CORONAS |NUMBER |22 |No | Cantidad de coronas que otorga una unidad a el reino que la adquiere |
| TIPO |CHAR |3 |No | Tipo de tropa (ATQ/DEF) |
| PUNTOS |NUMBER |22 |No | Puntos de ataque o defensa que otorga una unidad a el reino que la adquiere |
| NOMBRE |VARCHAR2 |20 |No | Nombre de el tipo de tropa |

### RECURSOS

| Columna | Tipo de dato | Longitud | Nulo |  Descripción |
| :---         |     :---:      |     :---:      |     :---:      | :---         |
| RESPALDO |VARCHAR2 |20 |Si | Recurso que respalda el valor de este recurso |
| VALOR |NUMBER |22 |No |  Valor por unidad en el recurso de respaldo |
| RESERVA |NUMBER |22 |No | Cantidad de este recurso que esta en la reserva central |
| EXISTENCIA |NUMBER |22 |No | Cantidad de este recurso que existe en el juego |
| NOMBRE |VARCHAR2 |20 |No | Nombre de este recurso |

### TROPAS_POR_REINOS

| Columna | Tipo de dato | Longitud | Nulo |  Descripción |
| :---         |     :---:      |     :---:      |     :---:      | :---         |
| CANTIDAD |NUMBER |22 |No | Cantidad de tropas de algun tipo que tiene un reino |
| NOMBRE_REINO |VARCHAR2 |20 |No | Nombre de reino |
| NOMBRE_TROPA |VARCHAR2 |20 |No | Nombre de tipo de tropa |

### VALORES_POR_TROPAS

| Columna | Tipo de dato | Longitud | Nulo |  Descripción |
| :---         |     :---:      |     :---:      |     :---:     | :---         |
| CANTIDAD |NUMBER |22 |No | Cantidad necesaria de un recurso para poder adquirir una unidad de esta tropa |
| NOMBRE_RECURSO |VARCHAR2 |20 |No | Nombre de recurso |
| NOMBRE_TROPA |VARCHAR2 |20 |No | Nombre de tipo de tropa |

### RECURSOS_POR_REINOS

| Columna | Tipo de dato | Longitud | Nulo |  Descripción |
| :---         |     :---:      |     :---:      |     :---:      | :---         |
| CANTIDAD |NUMBER |22 |No | Cantidad de un recurso que tiene un reino|
| NOMBRE_RECURSO |VARCHAR2 |20 |No | Nombre de recurso |
| NOMBRE_REINO |VARCHAR2 |20 |No | Nombre de reino |

## Descripción de los Programas para las operaciones

Los procedimientos almacenados descritos en esta sección se encuentran dentro de el paquete 'BOE'.

### Inicializar
#### Parametros
N/A
#### Descripcion
**Tipo**:N/A\
**Firma**:N/A\
La incializacion de las tablas ocurre cuando se ejecuta el script en el archivo bases_of_empires_inserts.sql, en ese momento se ingresan los recursos, valores en oro, tropas, puntos, cantidades de recursos por reino, entre otros.

### Comprar recursos
#### Parametros
| Nombre | Tipo de dato | Tipo |  Descripción |
| :---         |     :---:     |     :---:     | :---         |
| P_RECURSO |VARCHAR2 |IN | Recurso que se desea comprar |
| P_CANTIDAD |NUMBER |IN | Cantidad que se desea comprar |
| P_REINO |VARCHAR2 |IN | Reino que desea comprar el recurso |

#### Descripción
**Tipo**:Procedure\
**Firma**:COMPRAR(P_RECURSO RECURSOS.NOMBRE%TYPE, P_CANTIDAD RECURSOS.RESERVA%TYPE, P_REINO REINOS.NOMBRE%TYPE)\
Este procedimiento va a intentar adquirir la cantidad P_CANTIDAD de un recurso P_RECURSO, para un reino P_REINO, es posible adquirir la cantidad de el recurso especificado si el reino cuenta con suficiente oro para intercambiar por esa cantidad de ese recurso, la cantidad de oro necesaria es calculada apartir de el precio actual del recurso. El precio de el recurso comprado es recalculado después de la adquisición, además se genera una transacción de tipo 'CMP'.
Si no se puede adquirir la esa cantidad de ese recurso, el nombre del reino no es valido o el nombre de el recurso no es valido lanza una excepcion.

### Vender recursos
#### Parametros
| Nombre | Tipo de dato | Tipo |  Descripción |
| :---         |     :---:     |     :---:     | :---         |
| P_RECURSO |VARCHAR2 |IN | Recurso que se desea vender |
| P_CANTIDAD |NUMBER |IN | Cantidad que se desea vender |
| P_REINO |VARCHAR2 |IN | Reino que desea vender el recurso |
#### Descripción
**Tipo**:Procedure\
**Firma**:VENDER(P_RECURSO RECURSOS.NOMBRE%TYPE, P_CANTIDAD RECURSOS.RESERVA%TYPE, P_REINO REINOS.NOMBRE%TYPE)

Este procedimiento va a intentar adquirir la cantidad de oro correspondiente a la cantidad P_CANTIDAD de el recurso P_RECURSO para el reino P_REINO es posible adquirir la cantidad de oro si la reserva de oro cuenta con suficiente oro. La cantidad de oro necesaria es calculada apartir de el precio actual del recurso. El precio de el recurso vendido es recalculado después de la adquisición, además se genera una transacción de tipo 'VTA'
Si no se puede adquirir esa cantidad de oro, el nombre del reino no es valido o el nombre de el recurso no es valido lanza una excepcion.

### Entrenar Ejércitos
#### Parametros
| Nombre | Tipo de dato | Tipo |  Descripción |
| :---         |     :---:     |     :---:     | :---         |
| P_TROPA |VARCHAR2 |IN | Nombre de la tropa de tipo ATQ que se desea adquirir |
| P_CANTIDAD |NUMBER |IN | Cantiada de tropas que se desea adquirir |
| P_REINO |VARCHAR2 |IN | Reino que desea adquirir las tropas |
#### Descripción
**Tipo**:Procedure\
**Firma**:ENTRENAR_EJERCITO(P_TROPA TROPAS.NOMBRE%TYPE, P_CANTIDAD TROPAS_POR_REINOS.CANTIDAD%TYPE, P_REINO REINOS.NOMBRE%TYPE)

Este procedimiento va a intentar adquirir la cantidad de P_CANTIDAD de el tipo de tropa P_TROPA para el reino P_REINO, para esto el reino debe de contar con la cantidad necesaria de los recursos necesarios para adquirir la cantidad de dicha tropa. Este procedimiento solo funciona para tropas de tipo ATQ, cualquier otro tipo de tropa es considerado invalido. El precio de los recursos necesarios es recalculado después de la adquisición, además se genera una transacción de tipo 'TRP'.
Si no se puede adquirir esa cantidad de tropas, el nombre del reino no es valido o el nombre de la tropa no es valido lanza una excepcion.

### Comprar defensas
#### Parametros
| Nombre | Tipo de dato | Tipo |  Descripción |
| :---         |     :---:     |     :---:     | :---         |
| P_TROPA |VARCHAR2 |IN | Nombre de la tropa de tipo DEF que se desea adquirir |
| P_CANTIDAD |NUMBER |IN | Cantiada de tropas que se desea adquirir |
| P_REINO |VARCHAR2 |IN | Reino que desea adquirir las tropas |
#### Descripción
**Tipo**:Procedure\
**Firma**:COMPRAR_DEFENSAS(P_TROPA TROPAS.NOMBRE%TYPE, P_CANTIDAD TROPAS_POR_REINOS.CANTIDAD%TYPE, P_REINO REINOS.NOMBRE%TYPE)


Este procedimiento va a intentar adquirir la cantidad de P_CANTIDAD de el tipo de tropa P_TROPA para el reino P_REINO, para esto el reino debe de contar con la cantidad necesaria de los recursos necesarios para adquirir la cantidad de dicha tropa. Este procedimiento solo funciona para tropas de tipo DEF, cualquier otro tipo de tropa es considerado invalido. Se genera una transacción de tipo 'DEF'.
Si no se puede adquirir esa cantidad de tropas, el nombre del reino no es valido o el nombre de la tropa no es valido lanza una excepcion.

### Mejorar(Defensa/Ataque)
TODO
#### Parametros
| Nombre | Tipo de dato | Tipo |  Descripción |
| :---         |     :---:     |     :---:     | :---         |
#### Descripción
**Tipo**:

**Firma**:


### Atacar
TODO
#### Parametros
| Nombre | Tipo de dato | Tipo |  Descripción |
| :---         |     :---:     |     :---:     | :---         |
#### Descripción
**Tipo**:\
**Firma**:

### Monitorear
#### Parametros
| Nombre | Tipo de dato | Tipo |  Descripción |
| :---         |     :---:     |     :---:     | :---         |
| P_DETALLADO |PL/SQL BOOLEAN |IN |Este parametro dicta si el reporte impreso es tiene mas detalle. Por defecto es FALSE|
#### Descripción
**Tipo**:Procedure\
**Firma**:MONITOREAR(P_DETALLADO BOOLEAN DEFAULT FALSE)

**Nota**
Enter text here Es necesario que se ejecute el commando de SQL\*Plus 'SET SERVEROUTPUT ON' antes de llamar este procedimiento 

Este procedimiento imprime un reporte que contiene:
* Cantidad de cada recurso en reserva
* Precios de cada recurso
* Ranking de los reinos
* Bitácora
	* Reino
	* Fecha y hora 
	* Cantidad de cada recurso 
	* Coronas
	* Cantiad de coronas

## Requisitos

Debe de tener una instalacion de Oracle Database Express Edition 11g Release 2 o mayor en el sistema.

## Preparación

Es necesario que se ejecuten los siguientes scripts en el siguiente orden:

1. bases_of_empires_setup.sql
	* Requiere de permisos de creacion de usuarios, tablespaces y datafile.
	* Debe de proporcionar una contraseña para el nuevo usuario en la base de datos.
	* Después de este paso deberá utilizar el usuario recién creado para ejecutar los siguientes pasos.
1. bases_of_empires_tbls.sql
1. bases_of_empires_inserts.sql
1. bases_of_empires_errors.sql
1. bases_of_empires_operaciones.sql

### Nota
Si se desea eliminar bases of empires de su base de datos, es necesario ejecutar bases_of_empires_teardown.sql con el usuario SYSTEM.

## Autores

* **Persona** - *Que hizo* - [Usuario de github](https://github.com)

## Agradecimientos

* Yo Mama

