execute BOE.COMPRAR('Madera', 20000, 'Acuario');
--Error: no dispone de los recursos para hacer la compra
execute BOE.COMPRAR('Hierro', 30000, 'Acuario');
--
execute BOE.COMPRAR('Madera', 12000, 'Capricornio');
--Error: no dispone de los recursos para hacer la compra
execute BOE.COMPRAR('Hierro', 10000, 'Capricornio');
--
execute BOE.ENTRENAR_EJERCITO('Caballero',10,'Sagitario');
execute BOE.COMPRAR('Madera', 15000, 'Sagitario');
--
execute BOE.ENTRENAR_EJERCITO('Arquera',40,'Escorpio');
execute BOE.ENTRENAR_EJERCITO('Mago',30,'Escorpio');
--
execute BOE.ENTRENAR_EJERCITO('Piquero',50,'Libra');
execute BOE.COMPRAR_DEFENSAS('Torre',4,'Libra');
--
execute BOE.COMPRAR('Hierro', 6000, 'Virgo');
execute BOE.COMPRAR_DEFENSAS('CAÑON',6,'Virgo');
--execute BOE.COMPRAR_DEFENSAS('CA╤ON',6,'Virgo');
--
execute BOE.ENTRENAR_EJERCITO('Caballero',60,'Leo');
execute BOE.ENTRENAR_EJERCITO('Mago',40,'Leo');
--
execute BOE.VENDER('Hierro', 4000, 'Cancer');
--Error: no dispone de los recursos para hacer la compra
execute BOE.COMPRAR_DEFENSAS('Torre',30,'Cancer');
--
execute BOE.ENTRENAR_EJERCITO('Arquera',50,'Geminis');
execute BOE.ENTRENAR_EJERCITO('Piquero',50,'Geminis');
--
--Error: no dispone de los recursos para hacer la compra
execute BOE.COMPRAR_DEFENSAS('Cañon',15,'Tauro');
--execute BOE.COMPRAR_DEFENSAS('CA╤ON',15,'Tauro');
execute BOE.MEJORAR_DEFENSA('Tauro');
--
execute BOE.ENTRENAR_EJERCITO('Piquero',60,'Aries');
execute BOE.MEJORAR_ATAQUE('Aries');
--
execute BOE.ENTRENAR_EJERCITO('Arquera',50,'Piscis');
execute BOE.ENTRENAR_EJERCITO('Piquero',50,'Piscis');

--**********************ACCION II****************************--
execute BOE.MONITOREAR;
--
--
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('CAÑON',10,'Acuario');
--execute BOE.COMPRAR_DEFENSAS('CA╤ON',10,'Acuario');
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('TORRE',10,'Acuario');
--
execute BOE.ENTRENAR_EJERCITO('Arquera',60,'Capricornio');
execute BOE.ENTRENAR_EJERCITO('Caballero',40,'Capricornio');
--
execute BOE.ENTRENAR_EJERCITO('Mago',10,'Sagitario');
execute BOE.MEJORAR_ATAQUE('Sagitario');
--
execute BOE.MEJORAR_ATAQUE('Escorpio');
execute BOE.MEJORAR_ATAQUE('Escorpio');
--
execute BOE.ENTRENAR_EJERCITO('Mago',20,'Libra');
execute BOE.MEJORAR_DEFENSA('Libra');
--
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('Cañon',20,'Virgo');
--execute BOE.COMPRAR_DEFENSAS('CA╤ON',20,'Virgo');
execute BOE.MEJORAR_DEFENSA('Virgo');
--
execute BOE.ENTRENAR_EJERCITO('Piquero',40,'Leo');
execute BOE.MEJORAR_ATAQUE('Leo');
--
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('Cañon',25,'Cancer');
--execute BOE.COMPRAR_DEFENSAS('CA╤ON',25,'Cancer');
execute BOE.MEJORAR_DEFENSA('Cancer');
--
execute BOE.ENTRENAR_EJERCITO('Mago',20,'Geminis');
execute BOE.ENTRENAR_EJERCITO('Caballero',30,'Geminis');
--
--Error: ORA-20003: La cantidad de algun recurso en reserva o de algun reino esta fuera de limites. Esta en un numero menor a 0 o mayor a la existencia de ese recurso.
execute BOE.VENDER('Hierro', 50000, 'Tauro');
--Error: ORA-20003: La cantidad de algun recurso en reserva o de algun reino esta fuera de limites. Esta en un numero menor a 0 o mayor a la existencia de ese recurso.
execute BOE.VENDER('Madera', 50000, 'Tauro');
--
execute BOE.ENTRENAR_EJERCITO('Arquera',60,'Aries');
execute BOE.ENTRENAR_EJERCITO('Mago',30,'Aries');
--
execute BOE.MEJORAR_ATAQUE('Piscis');
execute BOE.ENTRENAR_EJERCITO('Caballero',35,'Piscis');
--
--**********************ACCION III****************************--
execute BOE.MONITOREAR;
--
--Error: ORA-20007: El reino no dispone de los recursos suficientes para la transacción
execute BOE.MEJORAR_DEFENSA('Acuario');
--Error: ORA-20007: El reino no dispone de los recursos suficientes para la transacción
execute BOE.MEJORAR_DEFENSA('Acuario');
--
execute BOE.MEJORAR_ATAQUE('Capricornio');
--Capricornio gana el ataque
execute BOE.ATACAR_REINO('Capricornio', 'Leo');
--
execute BOE.MEJORAR_ATAQUE('Sagitario');
--Sagitario gana el ataque
execute BOE.ATACAR_REINO('Sagitario', 'Escorpio');
--
execute BOE.ENTRENAR_EJERCITO('Mago',30,'Escorpio');
--Escorpio gana el ataque
execute BOE.ATACAR_REINO('Escorpio', 'Cancer');
--
--Libra gana el ataque
execute BOE.ATACAR_REINO('Libra', 'Sagitario');
execute BOE.MEJORAR_DEFENSA('Libra');
--
execute BOE.MEJORAR_DEFENSA('Virgo');
execute BOE.VENDER('Hierro', 2000, 'Virgo');
--
--Leo gana el ataque en las dos ocaciones
execute BOE.ATACAR_REINO('Leo', 'Acuario');
execute BOE.ATACAR_REINO('Leo', 'Geminis');
--
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('Torre',10,'Cancer');
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('Cañon',10,'Cancer');
--execute BOE.COMPRAR_DEFENSAS('CA╤ON',10,'Cancer');
--
execute BOE.MEJORAR_ATAQUE('Geminis');
--Geminis pierde el ataque
execute BOE.ATACAR_REINO('Geminis', 'Libra');
--
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir
execute BOE.COMPRAR_DEFENSAS('Torre',20,'Tauro');
execute BOE.MEJORAR_DEFENSA('Tauro');
--
--Aries pierde los dos ataques
execute BOE.ATACAR_REINO('Aries', 'Virgo');
execute BOE.ATACAR_REINO('Aries', 'Virgo');
--
execute BOE.MEJORAR_ATAQUE('Piscis');
--Piscis gana el ataque
execute BOE.ATACAR_REINO('Piscis', 'Cancer');
--
--**********************ACCION IV****************************--
execute BOE.MONITOREAR;
--
--Error:ORA-20007: El reino no dispone de los recursos suficientes para la transacción
execute BOE.MEJORAR_DEFENSA('Acuario');
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('Torre',20,'Acuario');
--
execute BOE.ENTRENAR_EJERCITO('Mago',30,'Capricornio');
--Capriconio gana la pelea
execute BOE.ATACAR_REINO('Capricornio', 'Leo');
--
execute BOE.ENTRENAR_EJERCITO('Caballero',25,'Sagitario');
--Sagitario gana el ataque
execute BOE.ATACAR_REINO('Sagitario', 'Capricornio');
--
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta
intentando adquirir.
execute BOE.ENTRENAR_EJERCITO('Mago',20,'Escorpio');
--Escorpio pierde el ataque
execute BOE.ATACAR_REINO('Escorpio', 'Libra');
--
execute BOE.ENTRENAR_EJERCITO('Mago',20,'Libra');
--Libra gana el ataque
execute BOE.ATACAR_REINO('Libra', 'Escorpio');
--
execute BOE.COMPRAR('Madera',5000,'Virgo');
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('Torre',15,'Virgo');
--
execute BOE.ENTRENAR_EJERCITO('Caballero',20,'Leo');
--Leo gana el ataque
execute BOE.ATACAR_REINO('Leo', 'Geminis');
--
execute BOE.MEJORAR_DEFENSA('Cancer');
--Cancer pierde el ataque
execute BOE.ATACAR_REINO('Cancer', 'Libra');
--
execute BOE.MEJORAR_ATAQUE('Geminis');
--Error: ORA-20006: El reino no dispone de oro suficiente para atacar
execute BOE.ATACAR_REINO('Geminis', 'Leo');
--
--Error: ORA-20004: No tiene suficientes recursos para adquirir las tropas que esta intentando adquirir.
execute BOE.COMPRAR_DEFENSAS('Cañon',12,'Tauro');
--execute BOE.COMPRAR_DEFENSAS('CA╤ON',12,'Tauro');
execute BOE.COMPRAR_DEFENSAS('Torre',8,'Tauro');
--
--Aries gana el ataque
execute BOE.ATACAR_REINO('Aries', 'Geminis');
--Aries pierde el ataque
execute BOE.ATACAR_REINO('Aries', 'Tauro');
--
--Piscis gana el ataque
execute BOE.ATACAR_REINO('Piscis', 'Aries');
--Piscis pierde el ataque
execute BOE.ATACAR_REINO('Piscis', 'Virgo');

execute BOE.MONITOREAR;

//LIBRA ES EL GANADOR