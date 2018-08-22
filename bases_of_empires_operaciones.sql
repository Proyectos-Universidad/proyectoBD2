CREATE OR REPLACE PACKAGE BOE AS 
    PROCEDURE COMPRAR(P_RECURSO RECURSOS.NOMBRE%TYPE, P_CANTIDAD RECURSOS.RESERVA%TYPE, P_REINO REINOS.NOMBRE%TYPE);
    PROCEDURE VENDER(P_RECURSO RECURSOS.NOMBRE%TYPE, P_CANTIDAD RECURSOS.RESERVA%TYPE, P_REINO REINOS.NOMBRE%TYPE);
    PROCEDURE ENTRENAR_EJERCITO(P_TROPA TROPAS.NOMBRE%TYPE, P_CANTIDAD TROPAS_POR_REINOS.CANTIDAD%TYPE, P_REINO REINOS.NOMBRE%TYPE);
    PROCEDURE COMPRAR_DEFENSAS(P_TROPA TROPAS.NOMBRE%TYPE, P_CANTIDAD TROPAS_POR_REINOS.CANTIDAD%TYPE, P_REINO REINOS.NOMBRE%TYPE);
    PROCEDURE MONITOREAR(P_DETALLADO BOOLEAN DEFAULT FALSE);
    PROCEDURE MEJORAR_DEFENSA(P_REINO REINOS.NOMBRE%TYPE);
    PROCEDURE MEJORAR_ATAQUE(P_REINO REINOS.NOMBRE%TYPE);
    PROCEDURE ATACAR_REINO(P_REINO_ATQ REINOS.NOMBRE%TYPE, P_REINO_DEF REINOS.NOMBRE%TYPE);
END BOE; 
/


CREATE OR REPLACE PACKAGE BODY BOE AS 
        FUNCTION OBTENER_VALOR_DE_PORCENTAJE(n NUMBER, p NUMBER) RETURN NUMBER IS BEGIN
            --Retorna el porcentaje(p) de el numero(n)
            -- n = 10|p=50, retorna 5
            RETURN ROUND((p * n)/100, 2);
        END;


        FUNCTION OBTENER_PORCENTAJE_DE_NUM(n1 NUMBER, n2 NUMBER) RETURN NUMBER IS BEGIN
            --Retorna a cuento porcentaje del numero(n2) equivale el numero(n1)
            -- n1 = 35 | n2 = 70, retorna 50
            RETURN ROUND((n1/n2)*100, 2);
        END;

        PROCEDURE TRAMITE_RESERVA (P_RECURSO RECURSOS.NOMBRE%TYPE, P_CANTIDAD RECURSOS.RESERVA%TYPE, P_REINO REINOS.NOMBRE%TYPE, RECALCULAR_PRECIO BOOLEAN DEFAULT TRUE) AS
        
           -- P_CANTIDAD, DEBE DE SER UN NUMERO NEGATIVO, SI SE QUIERE QUITAR RECURSOS A LA RESERVA.
           R_RESPALDO RECURSOS.RESPALDO%TYPE;
           RECURSO_VALOR_ORI RECURSOS.VALOR%TYPE; 
           RECURSO_VALOR RECURSOS.VALOR%TYPE; 
           PROPORCION RECURSOS.VALOR%TYPE; 
           RECURSO_REINO RECURSOS_POR_REINOS.CANTIDAD%TYPE; 
           RECURSO_RESERVA RECURSOS.RESERVA%TYPE;
           EXISTENCIA_RESERVA RECURSOS.EXISTENCIA%TYPE;
           RECURSO_RESERVA_ORI RECURSOS.RESERVA%TYPE;
           BEGIN
           
            SELECT RESERVA, EXISTENCIA, VALOR, RESPALDO INTO RECURSO_RESERVA_ORI, EXISTENCIA_RESERVA, RECURSO_VALOR_ORI, R_RESPALDO FROM RECURSOS WHERE UPPER(NOMBRE) = UPPER(P_RECURSO);
            SELECT CANTIDAD INTO RECURSO_REINO FROM RECURSOS_POR_REINOS WHERE UPPER(NOMBRE_RECURSO) = UPPER(P_RECURSO) AND UPPER(NOMBRE_REINO) = UPPER(P_REINO);
            
            RECURSO_REINO := RECURSO_REINO + (P_CANTIDAD * (-1));
            RECURSO_RESERVA := RECURSO_RESERVA_ORI + P_CANTIDAD;
        
            IF ((RECURSO_REINO < 0) OR (RECURSO_RESERVA < 0) OR (RECURSO_RESERVA > EXISTENCIA_RESERVA)) THEN
                BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REC_FUERA_DE_LIMITES_NUM);
            END IF;
        
            IF (R_RESPALDO IS NULL) OR ( NOT RECALCULAR_PRECIO)THEN
                UPDATE RECURSOS SET RESERVA = RECURSO_RESERVA WHERE UPPER(NOMBRE) = UPPER(P_RECURSO);
            ELSE 
                PROPORCION := OBTENER_PORCENTAJE_DE_NUM(P_CANTIDAD,RECURSO_RESERVA_ORI);
                RECURSO_VALOR := RECURSO_VALOR_ORI - OBTENER_VALOR_DE_PORCENTAJE(RECURSO_VALOR_ORI,PROPORCION);
                UPDATE RECURSOS SET VALOR = RECURSO_VALOR, RESERVA = RECURSO_RESERVA WHERE UPPER(NOMBRE) = UPPER(P_RECURSO);
            END IF;
                UPDATE RECURSOS_POR_REINOS SET CANTIDAD = RECURSO_REINO WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND UPPER(NOMBRE_RECURSO) = UPPER(P_RECURSO);
                
            EXCEPTION
                
                WHEN NO_DATA_FOUND THEN
                    BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REINO_O_RECURSO_NO_ENC_NUM);
        END;


            PROCEDURE INTERCAMBIAR(P_RECURSO RECURSOS.NOMBRE%TYPE, P_CANTIDAD RECURSOS.RESERVA%TYPE, P_REINO REINOS.NOMBRE%TYPE) AS
                RECURSO_VALOR RECURSOS.VALOR%TYPE;
                RECURSO_RESPALDO RECURSOS.RESPALDO%TYPE;
            BEGIN
                SELECT VALOR, RESPALDO INTO RECURSO_VALOR, RECURSO_RESPALDO FROM RECURSOS WHERE UPPER(NOMBRE) = UPPER(P_RECURSO);
                TRAMITE_RESERVA (P_RECURSO,-P_CANTIDAD,P_REINO);
                TRAMITE_RESERVA (RECURSO_RESPALDO,(P_CANTIDAD * RECURSO_VALOR), P_REINO);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REINO_O_RECURSO_NO_ENC_NUM);
            END;


            PROCEDURE AGREGAR_ENTRADA_BITACORA ( P_NOMBRE_REINO BITACORAS.NOMBRE_REINO%TYPE , P_TRANSACCION BITACORAS.TRANSACCION%TYPE) AS
                /*
                TODO
                Se puede agregar una exception definida por si se quiere probar el tipo de bitacora.[OPCIONAL]
                */
                P_RECURSOS BITACORAS.RECURSOS%TYPE := '';
                P_CORONAS REINOS.CANT_CORONAS%TYPE;
                CURSOR CUR_RECURSOS(P_NOM RECURSOS_POR_REINOS.NOMBRE_REINO%TYPE) IS SELECT NOMBRE_RECURSO, CANTIDAD FROM RECURSOS_POR_REINOS WHERE NOMBRE_REINO = P_NOM;
               BEGIN
                SELECT CANT_CORONAS INTO P_CORONAS FROM REINOS WHERE NOMBRE = P_NOMBRE_REINO; 
            
                FOR regis IN CUR_RECURSOS(P_NOMBRE_REINO) LOOP
                    P_RECURSOS := P_RECURSOS || regis.NOMBRE_RECURSO || ':' || regis.CANTIDAD  || ' ' ;
                END LOOP;
                INSERT INTO BITACORAS(NOMBRE_REINO, RECURSOS, CORONAS, TRANSACCION) VALUES (P_NOMBRE_REINO, P_RECURSOS, P_CORONAS, P_TRANSACCION);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REINO_O_RECURSO_NO_ENC_NUM);
            END;
            
            PROCEDURE AGREGAR_CORONAS ( P_NOMBRE_REINO REINOS.NOMBRE%TYPE , P_CANTIDAD REINOS.CANT_CORONAS%TYPE) AS BEGIN
                UPDATE REINOS SET CANT_CORONAS = CANT_CORONAS + P_CANTIDAD WHERE UPPER(NOMBRE) = UPPER(P_NOMBRE_REINO);
            END;
            
            PROCEDURE ADQUIRIR_TROPAS(P_TROPA TROPAS.NOMBRE%TYPE, P_CANTIDAD TROPAS_POR_REINOS.CANTIDAD%TYPE, P_REINO REINOS.NOMBRE%TYPE, P_RECALCULAR BOOLEAN) AS
                REG_TROPA TROPAS%ROWTYPE;
                TEMP_CANT_REC RECURSOS_POR_REINOS.CANTIDAD%TYPE;
                CURSOR CUR_REC_TROPA IS SELECT NOMBRE_TROPA, NOMBRE_RECURSO, CANTIDAD FROM VALORES_POR_TROPAS WHERE UPPER(NOMBRE_TROPA) = UPPER(P_TROPA);
                BEGIN
                    SELECT NOMBRE, PUNTOS, TIPO, CORONAS INTO REG_TROPA FROM TROPAS WHERE UPPER(NOMBRE) = UPPER(P_TROPA);
                    
                    FOR rec_tropa IN CUR_REC_TROPA LOOP
                        SELECT CANTIDAD INTO TEMP_CANT_REC FROM RECURSOS_POR_REINOS WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND UPPER(NOMBRE_RECURSO) = UPPER(rec_tropa.NOMBRE_RECURSO);
                        IF (rec_tropa.CANTIDAD * P_CANTIDAD) > (TEMP_CANT_REC) THEN
                           BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.FALTA_RECURSOS_PARA_TROPA_NUM);
                        END IF;
                        
                        TRAMITE_RESERVA(rec_tropa.NOMBRE_RECURSO, (rec_tropa.CANTIDAD * P_CANTIDAD),P_REINO, P_RECALCULAR);
                        
                    END LOOP;
                    
                    AGREGAR_CORONAS(P_REINO, (REG_TROPA.CORONAS * P_CANTIDAD));
                    UPDATE TROPAS_POR_REINOS SET CANTIDAD = P_CANTIDAD WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND UPPER(NOMBRE_TROPA) = UPPER(P_TROPA);
                END;
            
            PROCEDURE IMPRIMIR_DIVISOR(P_TITULO VARCHAR2, P_LONGITUD NUMBER) AS 
                DIVISOR VARCHAR2(2000);
                LONGITUD NUMBER;
            BEGIN    
                LONGITUD := P_LONGITUD - LENGTH(P_TITULO);
                FOR i IN 1..LONGITUD LOOP
                   IF i = ROUND((LONGITUD / 2)) THEN
                        DIVISOR := DIVISOR || P_TITULO;
                   END IF;
                   DIVISOR := DIVISOR || '-';
                END LOOP;
                DBMS_OUTPUT.PUT_LINE(DIVISOR);
            END;
            
            FUNCTION NEW_LINE RETURN CHAR IS BEGIN
                RETURN chr(13)||chr(10);
            END;

           PROCEDURE SUBIR_PUNTOS_DEFENSA(P_REINO REINOS.NOMBRE%TYPE)
            AS 
                pts_def_ori REINOS.PTS_DEF%TYPE;
                pts_def_nue REINOS.PTS_DEF%TYPE;
            BEGIN
                SELECT
                    PTS_DEF
                INTO
                    pts_def_ori
                FROM
                    REINOS
                WHERE
                    UPPER(NOMBRE) = UPPER(P_REINO);
                    
                    pts_def_nue := pts_def_ori + ((pts_def_ori/100)*10) + 500;
                
                UPDATE 
                    REINOS 
                SET 
                    PTS_DEF = pts_def_nue 
                WHERE 
                    UPPER(NOMBRE) = UPPER(P_REINO); 
            END; 

	    procedure SUBIR_PUNTOS_ATAQUE(P_REINO REINOS.NOMBRE%TYPE)
	    AS 
    		pts_atq_ori REINOS.PTS_ATQ%TYPE;
    		pts_atq_nue REINOS.PTS_ATQ%TYPE;
	    BEGIN
    		SELECT
        		PTS_ATQ
    		INTO
        		pts_atq_ori
    		FROM
        		REINOS
    		WHERE
        		UPPER(NOMBRE) = UPPER(P_REINO);
        
        		pts_atq_nue := pts_atq_ori + ((pts_atq_ori/100)*10) + 300;
    
    		UPDATE 
        		REINOS 
    		SET 
			PTS_ATQ = pts_atq_nue 
		WHERE 
			UPPER(NOMBRE) = UPPER(P_REINO); 
		END;
            
	    PROCEDURE REINO_ATACADO(P_REINO_DEF REINOS.NOMBRE%TYPE)
            
            AS	
                TRP_CAN TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_TOR TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_PIQ TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_ARQ TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_CAB TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_MAG TROPAS_POR_REINOS.CANTIDAD%TYPE;
                PNS_DEF REINOS.PTS_DEF%TYPE; 	
                CURSOR CUR_TROPAS_D (P_NOM TROPAS_POR_REINOS.NOMBRE_REINO%TYPE) IS
                    SELECT NOMBRE_TROPA,
                        CANTIDAD
                    FROM TROPAS_POR_REINOS
                    WHERE NOMBRE_REINO = P_NOM;	
            BEGIN
            
                SELECT PTS_DEF
                INTO PNS_DEF
                FROM REINOS
                WHERE UPPER(NOMBRE) = UPPER(P_REINO_DEF); 
            
                PNS_DEF := PNS_DEF - (PNS_DEF*0.1);
                
                UPDATE REINOS SET PTS_DEF = PNS_DEF WHERE UPPER(NOMBRE) = UPPER(P_REINO_DEF);
            
                FOR REGIS IN CUR_TROPAS_D(P_REINO_DEF) loop
                    IF(regis.nombre_tropa = 'CANON') THEN
                            TRP_CAN := regis.cantidad - round((regis.cantidad*0.25),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_CAN
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_TROPA) = 'CANON';
            
                    ELSIF(regis.nombre_tropa = 'TORRE') THEN
                        TRP_TOR := regis.cantidad - round((regis.cantidad*0.25),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_TOR
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_TROPA) = 'TORRE';
                    ELSIF(regis.nombre_tropa = 'ARQUERA') THEN
                            TRP_ARQ := regis.cantidad - round((regis.cantidad*0.2),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_ARQ
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_TROPA) = 'ARQUERA';
            
                    ELSIF(regis.nombre_tropa = 'PIQUERO') THEN
                        TRP_PIQ := regis.cantidad - round((regis.cantidad*0.2),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_PIQ
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_TROPA) = 'PIQUERO';
            
                    ELSIF(regis.nombre_tropa = 'CABALLERO') THEN
                        TRP_CAB := regis.cantidad - round((regis.cantidad*0.2),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_CAB
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_TROPA) = 'CABALLERO';
            
                    ELSIF(regis.nombre_tropa = 'MAGO') THEN
                        TRP_MAG := regis.cantidad - round((regis.cantidad*0.2),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_MAG
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_TROPA) = 'MAGO';		
                    END IF;	 
                END LOOP;
                
            END;
            
            PROCEDURE ATAQUE_EXITOSO(P_REINO_ATQ REINOS.NOMBRE%TYPE,
                P_REINO_DEF REINOS.NOMBRE%TYPE)
            AS	
                PNS_ATQ REINOS.PTS_DEF%TYPE;
                TRP_PIQ TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_ARQ TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_CAB TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_MAG TROPAS_POR_REINOS.CANTIDAD%TYPE;
                CANT_ORO RECURSOS_POR_REINOS.CANTIDAD%TYPE;
                CANT_MAD RECURSOS_POR_REINOS.CANTIDAD%TYPE;
                CANT_HIE RECURSOS_POR_REINOS.CANTIDAD%TYPE;
            
                CURSOR CUR_TROPAS_A (P_NOM TROPAS_POR_REINOS.NOMBRE_REINO%TYPE) IS
                    SELECT NOMBRE_TROPA,
                        CANTIDAD
                    FROM TROPAS_POR_REINOS
                    WHERE NOMBRE_REINO = P_NOM;
                CURSOR CUR_RECUR_REINO (P_NOM RECURSOS_POR_REINOS.NOMBRE_REINO%TYPE) IS
                    SELECT NOMBRE_RECURSO,
                        CANTIDAD
                    FROM RECURSOS_POR_REINOS
                    WHERE NOMBRE_REINO = P_NOM;
            
            BEGIN
                REINO_ATACADO(P_REINO_DEF);
            
                SELECT PTS_ATQ
                INTO PNS_ATQ 
                FROM REINOS
                WHERE UPPER(NOMBRE) = UPPER(P_REINO_ATQ); 
            
                PNS_ATQ := PNS_ATQ - (PNS_ATQ *0.5);	
            
                UPDATE REINOS 
                SET PTS_ATQ = PNS_ATQ 
                WHERE UPPER(NOMBRE) = UPPER(P_REINO_ATQ);
            
                FOR REGIS IN CUR_TROPAS_A(P_REINO_ATQ) loop
                    IF(regis.nombre_tropa = 'ARQUERA') THEN
                            TRP_ARQ := regis.cantidad - round((regis.cantidad*0.3),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_ARQ
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_TROPA) = 'ARQUERA';
            
                    ELSIF(regis.nombre_tropa = 'PIQUERO') THEN
                        TRP_PIQ := regis.cantidad - round((regis.cantidad*0.3),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_PIQ
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_TROPA) = 'PIQUERO';
            
                    ELSIF(regis.nombre_tropa = 'CABALLERO') THEN
                        TRP_CAB := regis.cantidad - round((regis.cantidad*0.3),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_CAB
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_TROPA) = 'CABALLERO';
            
                    ELSIF(regis.nombre_tropa = 'MAGO') THEN
                        TRP_MAG := regis.cantidad - round((regis.cantidad*0.3),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_MAG
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_TROPA) = 'MAGO';
                    END IF;	 
                END LOOP;
            
                FOR REGIS IN CUR_RECUR_REINO(P_REINO_DEF) loop
                    IF(REGIS.NOMBRE_RECURSO = 'ORO') THEN
                            CANT_ORO := round((regis.cantidad*0.65),2);
            
                         UPDATE RECURSOS_POR_REINOS
                             SET CANTIDAD = (regis.cantidad - round((regis.cantidad*0.65),2))
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_RECURSO) = 'ORO';
            
                    ELSIF(REGIS.NOMBRE_RECURSO = 'MADERA') THEN
                            CANT_MAD := round((regis.cantidad*0.65),2);
            
                         UPDATE RECURSOS_POR_REINOS
                             SET CANTIDAD = (regis.cantidad - round((regis.cantidad*0.65),2))
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_RECURSO) = 'MADERA';
            
                    ELSIF(REGIS.NOMBRE_RECURSO = 'HIERRO') THEN
                            CANT_HIE := round((regis.cantidad*0.65),2);
            
                         UPDATE RECURSOS_POR_REINOS
                             SET CANTIDAD = (regis.cantidad - round((regis.cantidad*0.65),2))
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND 
                                     UPPER(NOMBRE_RECURSO) = 'HIERRO';
                    END IF;	 
                END LOOP;
            
                FOR REGIS IN CUR_RECUR_REINO(P_REINO_ATQ) loop
                    IF(REGIS.NOMBRE_RECURSO = 'ORO') THEN
            
                         UPDATE RECURSOS_POR_REINOS
                             SET CANTIDAD = (regis.cantidad + CANT_ORO)
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_RECURSO) = 'ORO';
            
                    ELSIF(REGIS.NOMBRE_RECURSO = 'MADERA') THEN
            
                         UPDATE RECURSOS_POR_REINOS
                             SET CANTIDAD = (regis.cantidad + CANT_MAD)
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_RECURSO) = 'MADERA';
            
                    ELSIF(REGIS.NOMBRE_RECURSO = 'HIERRO') THEN
            
                         UPDATE RECURSOS_POR_REINOS
                             SET CANTIDAD = (regis.cantidad + CANT_HIE)
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_RECURSO) = 'HIERRO';
                    END IF;	 
                END LOOP;
            
            END;
            
            PROCEDURE ATAQUE_FALLIDO(P_REINO_ATQ REINOS.NOMBRE%TYPE,
                P_REINO_DEF REINOS.NOMBRE%TYPE)
            AS	
                TRP_PIQ TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_ARQ TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_CAB TROPAS_POR_REINOS.CANTIDAD%TYPE;
                TRP_MAG TROPAS_POR_REINOS.CANTIDAD%TYPE;
                PNS_ATQ REINOS.PTS_DEF%TYPE;
                CANT_ORO  RECURSOS_POR_REINOS.CANTIDAD%TYPE; 
                CURSOR CUR_TROPAS_A (P_NOM TROPAS_POR_REINOS.NOMBRE_REINO%TYPE) IS
                    SELECT NOMBRE_TROPA,
                        CANTIDAD
                    FROM TROPAS_POR_REINOS
                    WHERE NOMBRE_REINO = P_NOM;	
            
            BEGIN	
                REINO_ATACADO(P_REINO_DEF);
            
                SELECT PTS_ATQ
                INTO PNS_ATQ 
                FROM REINOS
                WHERE UPPER(NOMBRE) = UPPER(P_REINO_ATQ); 
            
                SELECT CANTIDAD
                INTO CANT_ORO
                FROM RECURSOS_POR_REINOS
                WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND UPPER(NOMBRE_RECURSO) = 'ORO'; 
            
                PNS_ATQ := PNS_ATQ - (PNS_ATQ *0.2);
                CANT_ORO := (CANT_ORO*0.3);	
            
                UPDATE REINOS 
                SET PTS_ATQ = PNS_ATQ 
                WHERE UPPER(NOMBRE) = UPPER(P_REINO_ATQ);
            
                UPDATE RECURSOS_POR_REINOS
                SET CANTIDAD = (CANTIDAD - CANT_ORO)
                WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND UPPER(NOMBRE_RECURSO) = 'ORO';
            
                UPDATE RECURSOS_POR_REINOS
                SET CANTIDAD = (CANTIDAD + CANT_ORO)
                WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_DEF) AND UPPER(NOMBRE_RECURSO) = 'ORO';	
            
                FOR REGIS IN CUR_TROPAS_A(P_REINO_ATQ) loop
                    IF(regis.nombre_tropa = 'ARQUERA') THEN
                            TRP_ARQ := regis.cantidad - round((regis.cantidad*0.4),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_ARQ
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_TROPA) = 'ARQUERA';
            
                    ELSIF(regis.nombre_tropa = 'PIQUERO') THEN
                        TRP_PIQ := regis.cantidad - round((regis.cantidad*0.4),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_PIQ
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_TROPA) = 'PIQUERO';
            
                    ELSIF(regis.nombre_tropa = 'CABALLERO') THEN
                        TRP_CAB := regis.cantidad - round((regis.cantidad*0.4),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_CAB
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_TROPA) = 'CABALLERO';
            
                    ELSIF(regis.nombre_tropa = 'MAGO') THEN
                        TRP_MAG := regis.cantidad - round((regis.cantidad*0.4),2);
            
                         UPDATE TROPAS_POR_REINOS
                             SET CANTIDAD = TRP_MAG
                             WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO_ATQ) AND 
                                     UPPER(NOMBRE_TROPA) = 'MAGO';
                    END IF;	 
                END LOOP;	 
            END;

            PROCEDURE COMPRAR(P_RECURSO RECURSOS.NOMBRE%TYPE, P_CANTIDAD RECURSOS.RESERVA%TYPE, P_REINO REINOS.NOMBRE%TYPE) AS BEGIN
                INTERCAMBIAR(P_RECURSO, P_CANTIDAD, P_REINO);
                AGREGAR_CORONAS(P_REINO,5);
                AGREGAR_ENTRADA_BITACORA (P_REINO,'CMP');
            END;
        
            PROCEDURE VENDER(P_RECURSO RECURSOS.NOMBRE%TYPE, P_CANTIDAD RECURSOS.RESERVA%TYPE, P_REINO REINOS.NOMBRE%TYPE) AS BEGIN
                INTERCAMBIAR(P_RECURSO, -P_CANTIDAD, P_REINO);
                AGREGAR_CORONAS(P_REINO,10);
                AGREGAR_ENTRADA_BITACORA (P_REINO,'VTA');
            END;
          
        
            PROCEDURE ENTRENAR_EJERCITO(P_TROPA TROPAS.NOMBRE%TYPE, P_CANTIDAD TROPAS_POR_REINOS.CANTIDAD%TYPE, P_REINO REINOS.NOMBRE%TYPE) AS
                TIPO_TROPA TROPAS.TIPO%TYPE;
                BEGIN
                    SELECT TIPO INTO TIPO_TROPA FROM TROPAS WHERE UPPER(NOMBRE) = UPPER(P_TROPA);
                    IF NOT(UPPER(TIPO_TROPA) = 'ATQ') THEN
                        BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.TROPA_INVALIDA_NUM);
                    END IF;
                    ADQUIRIR_TROPAS(P_TROPA, P_CANTIDAD,P_REINO, TRUE);
                    AGREGAR_ENTRADA_BITACORA (P_REINO,'TRP');
                END;
                
            PROCEDURE COMPRAR_DEFENSAS(P_TROPA TROPAS.NOMBRE%TYPE, P_CANTIDAD TROPAS_POR_REINOS.CANTIDAD%TYPE, P_REINO REINOS.NOMBRE%TYPE) AS
                TIPO_TROPA TROPAS.TIPO%TYPE;
                BEGIN
                    SELECT TIPO INTO TIPO_TROPA FROM TROPAS WHERE UPPER(NOMBRE) = UPPER(P_TROPA);
                    IF NOT(UPPER(TIPO_TROPA) = 'DEF') THEN
                        BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.TROPA_INVALIDA_NUM);
                    END IF;
                    ADQUIRIR_TROPAS(P_TROPA, P_CANTIDAD,P_REINO, TRUE);
                    AGREGAR_ENTRADA_BITACORA (P_REINO,'DEF');
                END;
                
                PROCEDURE MONITOREAR(P_DETALLADO BOOLEAN DEFAULT FALSE) AS
                --Este procedimiento ocupa que se corra SET SERVEROUTPUT ON antes de llamarlo para que funcione.
                CURSOR CUR_RECURSOS IS SELECT * FROM RECURSOS;
                CURSOR CUR_BITACORAS IS SELECT * FROM BITACORAS;
                CURSOR CUR_RECURSOS_REINOS(REI REINOS.NOMBRE%TYPE) IS SELECT * FROM RECURSOS_POR_REINOS RPR WHERE NOMBRE_REINO = REI;
                CURSOR CUR_TROPAS_POR_REINO(REI REINOS.NOMBRE%TYPE) IS SELECT NOMBRE_TROPA, CANTIDAD FROM TROPAS_POR_REINOS WHERE NOMBRE_REINO = REI;

                CURSOR CUR_RANK IS SELECT NOMBRE, O.ORO, TRP.ORO_TROPAS, REC.ORO_RECURSOS, PTS_DEF, PTS_ATQ, CANT_CORONAS, (TRP.ORO_TROPAS + REC.ORO_RECURSOS + O.ORO + PTS_DEF + PTS_ATQ + (CANT_CORONAS * 10)) AS RANK FROM REINOS R
                     
                    INNER JOIN (SELECT NOMBRE_REINO,SUM(ROUND((150 * VPT.CANTIDAD)/100, 2) * TPR.CANTIDAD) AS ORO_TROPAS FROM TROPAS_POR_REINOS TPR 
                    INNER JOIN VALORES_POR_TROPAS VPT ON VPT.NOMBRE_TROPA = TPR.NOMBRE_TROPA 
                    INNER JOIN TROPAS T ON TPR.NOMBRE_TROPA = T.NOMBRE 
                    INNER JOIN RECURSOS R ON VPT.NOMBRE_RECURSO = R.NOMBRE
                    WHERE T.TIPO = 'ATQ' AND (R.RESPALDO IS NULL) GROUP BY NOMBRE_REINO) TRP ON TRP.NOMBRE_REINO = R.NOMBRE
                    
                    INNER JOIN(SELECT NOMBRE_REINO,SUM(((VALOR / 2) * CANTIDAD)) AS ORO_RECURSOS FROM RECURSOS_POR_REINOS RPR 
                    INNER JOIN RECURSOS R ON RPR.NOMBRE_RECURSO = R.NOMBRE 
                    WHERE (RESPALDO IS NOT NULL) GROUP BY NOMBRE_REINO) REC ON REC.NOMBRE_REINO = R.NOMBRE
                    
                    INNER JOIN (SELECT NOMBRE_REINO,SUM(CANTIDAD) AS ORO FROM RECURSOS_POR_REINOS RPR 
                    INNER JOIN RECURSOS R ON RPR.NOMBRE_RECURSO = R.NOMBRE 
                    WHERE (RESPALDO IS NULL) GROUP BY NOMBRE_REINO) O ON O.NOMBRE_REINO = R.NOMBRE
                    
                    ORDER BY RANK DESC;
                CONT_BIT NUMBER := 1;
                CONT_RANK NUMBER := 1;
                BEGIN
 
                    
                    FOR reg_recurso IN CUR_RECURSOS LOOP
                        IMPRIMIR_DIVISOR(reg_recurso.NOMBRE,30);
                        DBMS_OUTPUT.PUT_LINE('Reserva: ' || reg_recurso.RESERVA);
                        DBMS_OUTPUT.PUT_LINE('Precio   ' || reg_recurso.VALOR);
                    END LOOP;
                     
                    IMPRIMIR_DIVISOR('RANKING',60);
                    FOR reg_reino IN CUR_RANK LOOP
                        IMPRIMIR_DIVISOR(CONT_RANK,60);
                        DBMS_OUTPUT.PUT_LINE('Reino:             ' ||reg_reino.NOMBRE);
                        DBMS_OUTPUT.PUT_LINE('Oro:               ' ||reg_reino.ORO);
                        DBMS_OUTPUT.PUT_LINE('Oro tropas:        ' ||reg_reino.ORO_TROPAS);
                        IF P_DETALLADO THEN 
                            IMPRIMIR_DIVISOR('Tropas',40);
                            FOR reg_tropa IN CUR_TROPAS_POR_REINO(reg_reino.NOMBRE) LOOP
                                DBMS_OUTPUT.PUT_LINE(reg_tropa.NOMBRE_TROPA||'   '||reg_tropa.CANTIDAD);
                            END LOOP;
                            IMPRIMIR_DIVISOR('Tropas',40);

                        END IF;
                        DBMS_OUTPUT.PUT_LINE('Oro recursos:      ' ||reg_reino.ORO_RECURSOS);
                        IF P_DETALLADO THEN 
                            IMPRIMIR_DIVISOR('Recursos',40);
                            FOR reg_rec IN CUR_RECURSOS_REINOS(reg_reino.NOMBRE) LOOP
                                DBMS_OUTPUT.PUT_LINE(reg_rec.NOMBRE_RECURSO||'   '||reg_rec.CANTIDAD);
                            END LOOP;
                            IMPRIMIR_DIVISOR('Recursos',40);
                        END IF;
                        DBMS_OUTPUT.PUT_LINE('Oro PTS ataque:    ' ||reg_reino.PTS_ATQ);
                        DBMS_OUTPUT.PUT_LINE('Oro PTS defensa:   ' ||reg_reino.PTS_DEF);
                        DBMS_OUTPUT.PUT_LINE('Oro coronas:       ' ||(reg_reino.CANT_CORONAS * 10));
                        DBMS_OUTPUT.PUT_LINE('Total:             ' ||reg_reino.RANK);
                        CONT_RANK := CONT_RANK + 1;
                    END LOOP;
                    
                    IMPRIMIR_DIVISOR('BITACORA',60);
                    FOR reg_bitacora IN CUR_BITACORAS LOOP
                        IMPRIMIR_DIVISOR(CONT_BIT,60);
                        DBMS_OUTPUT.PUT_LINE('Reino:        ' ||reg_bitacora.NOMBRE_REINO);
                        DBMS_OUTPUT.PUT_LINE('Fecha y hora: ' ||TO_CHAR(reg_bitacora.FECHA_Y_HORA, 'yyyy-mm-dd hh:MI'));
                        DBMS_OUTPUT.PUT_LINE('Recursos:     ' ||reg_bitacora.RECURSOS);
                        DBMS_OUTPUT.PUT_LINE('Coronas:      ' ||reg_bitacora.CORONAS);
                        DBMS_OUTPUT.PUT_LINE('Transaccion:  ' ||reg_bitacora.TRANSACCION);
                        CONT_BIT := CONT_BIT + 1;
                    END LOOP;
                END;

		PROCEDURE MEJORAR_DEFENSA(P_REINO REINOS.NOMBRE%TYPE) 
                AS 
                    ORO_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'ORO';
                    MADERA_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'MADERA';
                    HIERRO_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'HIERRO';
                    CANT_ORO  RECURSOS_POR_REINOS.CANTIDAD%TYPE;
                    CANT_MAD  RECURSOS_POR_REINOS.CANTIDAD%TYPE;
                    CANT_HIE  RECURSOS_POR_REINOS.CANTIDAD%TYPE;
                BEGIN
                    SELECT CANTIDAD
                    INTO CANT_ORO
                    FROM RECURSOS_POR_REINOS
                    WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND NOMBRE_RECURSO = ORO_REINO;
                    
                    SELECT CANTIDAD
                    INTO CANT_HIE
                    FROM RECURSOS_POR_REINOS
                    WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND NOMBRE_RECURSO = HIERRO_REINO;
                    
                    SELECT CANTIDAD
                    INTO CANT_MAD
                    FROM RECURSOS_POR_REINOS
                    WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND NOMBRE_RECURSO = MADERA_REINO;
                    
                    IF(CANT_ORO < 2000 OR CANT_MAD < 100 OR CANT_HIE < 150) THEN
                        BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REC_INSUF_TRANSC_NUM);    
                    END IF;
                    
                    tramite_reserva(ORO_REINO, 2000, P_REINO);
                    tramite_reserva(MADERA_REINO, 100, P_REINO);
                    tramite_reserva(HIERRO_REINO, 150, P_REINO);
                    subir_puntos_defensa(P_REINO);
                    AGREGAR_CORONAS(P_REINO,40);
                    AGREGAR_ENTRADA_BITACORA (P_REINO,'M+D');
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REINO_O_RECURSO_NO_ENC_NUM);
                END;
                
                PROCEDURE MEJORAR_ATAQUE(P_REINO REINOS.NOMBRE%TYPE) 
                AS 
                    ORO_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'ORO';
                    MADERA_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'MADERA';
                    HIERRO_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'HIERRO';
                    CANT_ORO  RECURSOS_POR_REINOS.CANTIDAD%TYPE;
                    CANT_MAD  RECURSOS_POR_REINOS.CANTIDAD%TYPE;
                    CANT_HIE  RECURSOS_POR_REINOS.CANTIDAD%TYPE; 
                BEGIN
                    SELECT CANTIDAD
                    INTO CANT_ORO
                    FROM RECURSOS_POR_REINOS
                    WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND NOMBRE_RECURSO = ORO_REINO;
                    
                    SELECT CANTIDAD
                    INTO CANT_HIE
                    FROM RECURSOS_POR_REINOS
                    WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND NOMBRE_RECURSO = HIERRO_REINO;
                    
                    SELECT CANTIDAD
                    INTO CANT_MAD
                    FROM RECURSOS_POR_REINOS
                    WHERE UPPER(NOMBRE_REINO) = UPPER(P_REINO) AND NOMBRE_RECURSO = MADERA_REINO;
                    
                    IF(CANT_ORO < 1500 OR CANT_MAD < 300 OR CANT_HIE < 250) THEN
                        BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REC_INSUF_TRANSC_NUM);    
                    END IF;                
                
                    tramite_reserva(ORO_REINO, 1500, P_REINO);
                    tramite_reserva(MADERA_REINO, 300, P_REINO);
                    tramite_reserva(HIERRO_REINO, 200, P_REINO);
                    SUBIR_PUNTOS_ATAQUE(P_REINO);
                    AGREGAR_CORONAS(P_REINO,5);
                    AGREGAR_ENTRADA_BITACORA (P_REINO,'M+A');

                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REINO_O_RECURSO_NO_ENC_NUM);
                    
                END;

		PROCEDURE ATACAR_REINO (
            P_REINO_ATQ REINOS.NOMBRE%TYPE,
            P_REINO_DEF REINOS.NOMBRE%TYPE)
        AS
            ORO_REINO RECURSOS_POR_REINOS.NOMBRE_RECURSO%TYPE := 'ORO';
            CANT_ORO  RECURSOS_POR_REINOS.CANTIDAD%TYPE;
            PTS_TRP_A TROPAS.PUNTOS%TYPE := 0;
            PTS_TRP_D TROPAS.PUNTOS%TYPE := 0;
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
                BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REC_INSUF_PARA_ATQ_NUM);
            END IF;
        
            TRAMITE_RESERVA(ORO_REINO, 1000, P_REINO_ATQ, FALSE);
        
            FOR REGIS IN CUR_TROPAS_A(P_REINO_ATQ) loop
                IF(regis.nombre_tropa = 'ARQUERA') THEN
                    PTS_TRP_A := PTS_TRP_A + round((regis.cantidad*20*0.8),2);
                ELSIF(regis.nombre_tropa = 'PIQUERO') THEN
                    PTS_TRP_A := PTS_TRP_A + round((regis.cantidad*30*0.8),2);
                ELSIF(regis.nombre_tropa = 'CABALLERO') THEN
                    PTS_TRP_A := PTS_TRP_A + round((regis.cantidad*50*0.8),2);
                ELSIF(regis.nombre_tropa = 'MAGO') THEN
                    PTS_TRP_A := PTS_TRP_A + round((regis.cantidad*40*0.8),2);
                END IF;	 
            end loop;
	
            PNS_ATQ := ROUND((PNS_ATQ*0.6),2) + PTS_TRP_A;	
            
            FOR REGIS IN CUR_TROPAS_D(P_REINO_DEF) loop
                IF(regis.nombre_tropa = 'CANON') THEN
                        PTS_TRP_D := PTS_TRP_D + round((regis.cantidad*450),2);
                ELSIF(regis.nombre_tropa = 'TORRE') THEN
                    PTS_TRP_D := PTS_TRP_D + round((regis.cantidad*650),2);
                END IF;	 
            end loop;		
            
            PNS_DEF := ROUND((PNS_DEF*0.7),2) + PTS_TRP_D;
            DBMS_OUTPUT.PUT_LINE('Puntos de ataque: '||PNS_ATQ||' vs. '||'Puntos de defensa: '||PNS_DEF);
            IF (PNS_ATQ > PNS_DEF) THEN
                ATAQUE_EXITOSO(P_REINO_ATQ, P_REINO_DEF);
                DBMS_OUTPUT.PUT_LINE(P_REINO_ATQ||' ha ganado el ataque');
            ELSE
                ATAQUE_FALLIDO(P_REINO_ATQ, P_REINO_DEF);
                DBMS_OUTPUT.PUT_LINE(P_REINO_ATQ||' ha perdido el ataque');
            END IF;
            
            AGREGAR_CORONAS(P_REINO_ATQ,2);
            AGREGAR_ENTRADA_BITACORA (P_REINO_ATQ,'ATK');
	    
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    BOE_ERRORS.RAISE_BOE_ERR(BOE_ERRORS.REINO_O_RECURSO_NO_ENC_NUM);          		
        END;
END BOE; 
/