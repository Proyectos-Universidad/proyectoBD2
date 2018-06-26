--Correr con usuario: SYSTEM
ACCEPT clave CHAR PROMPT 'Ingrese la clave para el usuario war_master en su base de datos.';

CREATE TABLESPACE war_data DATAFILE 'war.dbf' SIZE 5M;
CREATE USER war_master IDENTIFIED BY &clave DEFAULT TABLESPACE war_data;
ALTER USER war_master QUOTA 5M ON war_data;
GRANT CREATE SESSION TO war_master;
GRANT CREATE PROCEDURE to war_master;
GRANT CREATE TABLE to war_master;
