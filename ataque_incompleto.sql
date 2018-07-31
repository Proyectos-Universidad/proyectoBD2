PROCEDURE ATACAR_REINO (
	P_REINO_ATQ REINOS.NOMBRE%TYPE,
	P_REINO_DEF REINOS.NOMBRE%TYPE)
AS
	ORO_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'ORO';
	CANT_ORO  RECURSOS_POR_REINOS.CANTIDAD%TYPE;
	PTS_TRP_A TROPAS.PUNTOS%TYPE;
	PTS_TRP_D TROPAS.PUNTOS%TYPE;
	PNS_ATQ REINOS.PTS_ATQ%TYPE;
	PNS_DEF REINOS.PTS_DEF%TYPE;
	CURSOR CUR_TROPAS_A (P_NOM TROPAS_POR_REINOS.NOMBRE_REINO%TYPE) IS
		SELECT NOMBRE_TROPA,
			CANTIDAD
		FROM TROPAS_POR_REINOS
		WHERE NOMBRE_REINO = P_NOM;
	CURSOR CUR_TROPAS_D (P_NOM TROPAS_POR_REINOS.NOMBRE_REINO%TYPE) IS
		SELECT NOMBRE_TROPA,
			CANTIDAD
		FROM TROPAS_POR_REINOS
		WHERE NOMBRE_REINO = P_NOM;
BEGIN
	SELECT CANTIDAD
	INTO CANT_ORO
	FROM RECURSOS_POR_REINOS
	WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND NOMBRE_RECURSO = ORO_REINO;	
	
	SELECT PTS_ATQ
	INTO PNS_ATQ
	FROM REINOS
	WHERE UPPER(NOMBRE) = UPPER(P_REINO_ATQ);

	SELECT PTS_DEF
	INTO PNS_DEF
	FROM REINOS
	WHERE UPPER(NOMBRE) = UPPER(P_REINO_DEF);

	IF(CANT_ORO < 1000) THEN
		BOE_ERROES.RAISE_BOE_ERR(BOE_ERRORS.RECURSOS_INSUFICIENTES_PARA_ATACAR);
	END IF;

	TRAMITE_RESERVA(ORO_REINO, 1000, P_REINO_ATQ, FALSE);
	AGREGAR_ENTRADA_BITACORA (P_REINO_ATQ,'ATK');

	FOR REGIS IN CUR_TROPAS_A(P_REINO_ATQ) loop
		IF(regis.nombre_tropa = 'ARQUERA') THEN
    			PTS_TRP_A := round((regis.cantidad*20*0.8),2);
		ELSIF(regis.nombre_tropa = 'PIQUERO') THEN
			PTS_TRP_A := round((regis.cantidad*30*0.8),2);
		ELSIF(regis.nombre_tropa = 'CABALLERO') THEN
			PTS_TRP_A := round((regis.cantidad*50*0.8),2);
		ELSIF(regis.nombre_tropa = 'MAGO') THEN
			PTS_TRP_A := round((regis.cantidad*40*0.8),2);
		END IF;	 
   	end loop;
	
	PNS_ATQ := ROUND((PNS_ATQ*0.6),2) + PTS_TRP_A;	
	
	FOR REGIS IN CUR_TROPAS_D(P_REINO_DEF) loop
		IF(regis.nombre_tropa = 'CA�ON') THEN
    			PTS_TRP_D := round((regis.cantidad*450),2);
		ELSIF(regis.nombre_tropa = 'TORRE') THEN
			PTS_TRP_D := round((regis.cantidad*650),2);
		END IF;	 
   	end loop;	
	
	PNS_DEF := ROUND((PNS_DEF*0.7),2) + PTS_TRP_D;

	IF (PNS_ATQ > PNS_DEF) THEN
		ATAQUE_EXITOSO(P_REINO_ATQ, P_REINO_DEF);
	ELSE
		ATAQUE_FALLIDO(P_REINO_ATQ, P_REINO_DEF)
	END IF;
END;

PROCEDURE ATAQUE_EXITOSO(P_REINO_ATQ REINOS.NOMBRE%TYPE,
	P_REINO_DEF REINOS.NOMBRE%TYPE)
AS	
	PNS_DEF REINOS.PTS_DEF%TYPE; 
BEGIN
	SELECT PTS_DEF
	INTO PNS_DEF
	FROM REINOS
	WHERE UPPER(NOMBRE) = UPPER(P_REINO_DEF); 

	PNS_DEF := PNS_DEF - (PNS_DEF*0.1);

	UPDATE REINOS 
	SET PTS_DEF = PNS_DEF 
	WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF);
		 
END;	
