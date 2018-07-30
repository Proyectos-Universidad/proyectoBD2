PROCEDURE ATACAR_REINO (
	P_REINO_ATQ REINOS.NOMBRE%TYPE,
	P_REINO_DEF REINOS.NOMBRE%TYPE)
AS
	ORO_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'ORO';
	CANT_ORO  RECURSOS_POR_REINOS.CANTIDAD%TYPE;
	PTS_ATQ REINOS.PTS_ATQ%TYPE;
	PTS_DEF REINOS.PTS_DEF%TYPE;

BEGIN
	SELECT CANTIDAD
	INTO CANT_ORO
	FROM RECURSOS_POR_REINOS
	WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND NOMBRE_RECURSO = ORO_REINO;	

	IF(CANT_ORO < 1000) THEN
		BOE_ERROES.RAISE_BOE_ERR(BOE_ERRORS.RECURSOS_INSUFICIENTES_PARA_ATACAR);
	END IF;

	TRAMITE_RESERVA(ORO_REINO, 1000, P_REINO_ATQ, FALSE);
	AGREGAR_ENTRADA_BITACORA (P_REINO_ATQ,'ATQ');


