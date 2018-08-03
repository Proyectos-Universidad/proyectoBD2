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
execute BOE.COMPRAR_DEFENSAS('Cañon',6,'Virgo');
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
execute BOE.MEJORAR_DEFENSA('Tauro');
--
execute BOE.ENTRENAR_EJERCITO('Piquero',60,'Aries');
execute BOE.MEJORAR_ATAQUE('Aries');
--
execute BOE.ENTRENAR_EJERCITO('Arquera',50,'Piscis');
execute BOE.ENTRENAR_EJERCITO('Piquero',50,'Piscis');

execute BOE.MONITOREAR;
