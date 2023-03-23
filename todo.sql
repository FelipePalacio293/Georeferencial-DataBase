# Creacion
CREATE TABLE ciudad (
    id     INTEGER NOT NULL,
    nombre VARCHAR2(30)
);

ALTER TABLE ciudad ADD CONSTRAINT ciudad_pk PRIMARY KEY ( id );

CREATE TABLE georeferencia (
    id         INTEGER NOT NULL,
    latitud    NUMBER,
    longitud   NUMBER,
    persona_id INTEGER NOT NULL
);

ALTER TABLE georeferencia ADD CONSTRAINT georeferencia_pk PRIMARY KEY ( id );

CREATE TABLE matrimonio (
    id           INTEGER NOT NULL,
    fecha        DATE,
    tipo         VARCHAR2(30),
    persona_id_2 INTEGER NOT NULL,
    persona_id_1 INTEGER NOT NULL
);

ALTER TABLE matrimonio ADD CONSTRAINT matrimonio_pk PRIMARY KEY ( id );

CREATE TABLE persona (
    id               INTEGER NOT NULL,
    nombre           VARCHAR2(30),
    apellido         VARCHAR2(30),
    direccion        VARCHAR2(30),
    padre_1          INTEGER,
    padre_2          INTEGER,
    ciudadresidencia INTEGER NOT NULL,
    ciudadnacimiento INTEGER NOT NULL
);

ALTER TABLE persona ADD CONSTRAINT persona_pk PRIMARY KEY ( id );

CREATE TABLE trabajo (
    id            INTEGER NOT NULL,
    direccion     VARCHAR2(30),
    nombreempresa VARCHAR2(30),
    persona_id    INTEGER NOT NULL,
    ciudad_id     INTEGER NOT NULL
);

ALTER TABLE trabajo ADD CONSTRAINT trabajo_pk PRIMARY KEY ( id );

ALTER TABLE georeferencia
    ADD CONSTRAINT georeferencia_persona_fk FOREIGN KEY ( persona_id )
        REFERENCES persona ( id );

ALTER TABLE matrimonio
    ADD CONSTRAINT matrimonio_persona_fk FOREIGN KEY ( persona_id_1 )
        REFERENCES persona ( id );

ALTER TABLE matrimonio
    ADD CONSTRAINT matrimonio_persona_fkv2 FOREIGN KEY ( persona_id_2 )
        REFERENCES persona ( id );

ALTER TABLE persona
    ADD CONSTRAINT persona_ciudad_fk FOREIGN KEY ( ciudadresidencia )
        REFERENCES ciudad ( id );

ALTER TABLE persona
    ADD CONSTRAINT persona_ciudad_fkv2 FOREIGN KEY ( ciudadnacimiento )
        REFERENCES ciudad ( id );

ALTER TABLE persona
    ADD CONSTRAINT persona_persona_fk FOREIGN KEY ( padre_1 )
        REFERENCES persona ( id );

ALTER TABLE persona
    ADD CONSTRAINT persona_persona_fkv2 FOREIGN KEY ( padre_2 )
        REFERENCES persona ( id );

ALTER TABLE trabajo
    ADD CONSTRAINT trabajo_ciudad_fk FOREIGN KEY ( ciudad_id )
        REFERENCES ciudad ( id );

ALTER TABLE trabajo
    ADD CONSTRAINT trabajo_persona_fk FOREIGN KEY ( persona_id )
        REFERENCES persona ( id );

# Restricciones

# Trigger que restringe el hecho de que puedan haber mas de 4 matrimonios ancestrales
CREATE OR REPLACE TRIGGER ANCESTRALES
BEFORE INSERT ON MATRIMONIO
FOR EACH ROW
DECLARE 
    numMatrimonios INTEGER;
BEGIN
    SELECT COUNT(*) INTO numMatrimonios FROM MATRIMONIO WHERE TIPO = 'Ancestral';
    IF numMatrimonios >= 4 AND :NEW.TIPO = 'Ancestral'  THEN 
        RAISE_APPLICATION_ERROR(-20099, 'Cannot Insert More Than 4 marriages Ancestrals');
    END IF;
END;

# Trigger que restringe el hecho de que una persona que viva en Transnopoli pueda trabajar allí mismo.

CREATE OR REPLACE TRIGGER CIUDAD
BEFORE INSERT ON TRABAJO
FOR EACH ROW
DECLARE 
    city INTEGER;
BEGIN
    SELECT CIUDADRESIDENCIA INTO city FROM PERSONA WHERE ID = :NEW.PERSONA_ID;
    IF city = 1 AND :NEW.CIUDAD_ID = 1 THEN
        RAISE_APPLICATION_ERROR(-20099, 'Cannot Insert Because Person Work and Live on Transnopoli'); 
    END IF;
END;

# Trigger que restringe el hecho de que si alguien vive en Transnopoli, al menos uno de sus padres debe de ser de esta ciudad. 

CREATE OR REPLACE TRIGGER RESIDENCIA
BEFORE INSERT ON PERSONA
FOR EACH ROW
DECLARE 
    bandera INTEGER;
    origen INTEGER;
BEGIN
    bandera := 0;
    IF :NEW.CIUDADRESIDENCIA = 1 THEN
        IF :NEW.PADRE_1 IS NULL AND :NEW.PADRE_2 IS NULL THEN
            RAISE_APPLICATION_ERROR(-20099, 'Cannot Insert Because Parents Person Doesnt Born On Transnopoli'); 
        END IF;
        IF :NEW.PADRE_1 IS NOT NULL THEN
            SELECT CIUDADNACIMIENTO INTO origen FROM PERSONA WHERE ID = :NEW.PADRE_1;
            IF origen = 1 THEN
                bandera := 1;
            END IF;
        END IF;
        IF :NEW.PADRE_2 IS NOT NULL AND bandera = 0 THEN
            SELECT CIUDADNACIMIENTO INTO origen FROM PERSONA WHERE ID = :NEW.PADRE_2;
            IF origen = 1 THEN
                bandera := 1;
            END IF;
        END IF;
        IF bandera = 0 THEN
            RAISE_APPLICATION_ERROR(-20099, 'Cannot Insert Because Parents Person Doesnt Born On Transnopoli'); 
        END IF;
    END IF;
END;

# Consultas 

# Consulta que permite ver los matrimonios y personas iniciales. 

SELECT * FROM PERSONA INNER JOIN MATRIMONIO ON persona.id = matrimonio.persona_id_1 OR persona.id = matrimonio.persona_id_2 WHERE TIPO = 'Ancestral';

# Consulta que genera el arbol genealógico de la persona. En este caso la consulta solo funciona para uno de los padres y no para ambos.
# Algo a mejorar sería el hecho de poder elegir la persona que quisiéramos.

SELECT Nombre "Nombre", Apellido "Apellido", CONNECT_BY_ROOT id "id",
LEVEL "Nivel en el arbol", SYS_CONNECT_BY_PATH(Apellido, '/') "Padres"
FROM PERSONA
WHERE LEVEL > -1
START WITH id = 1
CONNECT BY NOCYCLE PRIOR ID = PADRE_1 or ID = PADRE_2;

# Funciones

# Usando pitágoras obtenemos la distancia entre dos coordenadas.

CREATE OR REPLACE FUNCTION DISTANCIA(c INT, x INT)
RETURN FLOAT
AS
distance FLOAT;
latuno FLOAT;
latdos FLOAT;
lattres FLOAT;
latcuatro FLOAT;
BEGIN
    SELECT Latitud, Longitud INTO latuno, latdos FROM GEOREFERENCIA WHERE PERSONA_ID = c;
    SELECT Latitud, Longitud INTO lattres, latcuatro FROM GEOREFERENCIA WHERE PERSONA_ID = x;
    distance := SQRT(POWER((latdos - latuno), 2) + POWER((lattres - latcuatro), 2));
    RETURN distance;
END;

SELECT DISTANCIA(1, 2) FROM DUAL;

# Sin embargo, esto no es suficiente dado que necesitamos la distancia de las dos coordenadas en un planeta esférico

# Se define la función auxiliar degrees que transforma de grados a radianes.
CREATE OR REPLACE
FUNCTION degrees (p_radians NUMBER) RETURN NUMBER IS
   l_result NUMBER ;
BEGIN
   l_result := p_radians * (3.114159265359 / 180) ;
   RETURN l_result ;
END;

# Se define la función distancia que recibe la georreferencia de una persona a y b, y cálcula la distancia en km entre ellos. 

CREATE OR REPLACE FUNCTION DISTANCIA(c INT, x INT)
RETURN FLOAT
AS
distance FLOAT;
lonuno FLOAT;
latuno FLOAT;
latdos FLOAT;
londos FLOAT;
totalLon FLOAT;
totalLat FLOAT;
distanceA FLOAT;
distanceC FLOAT;
BEGIN
    SELECT Latitud, Longitud INTO latuno, lonuno FROM GEOREFERENCIA WHERE PERSONA_ID = c;
    SELECT Latitud, Longitud INTO latdos, londos FROM GEOREFERENCIA WHERE PERSONA_ID = x;
    latuno := degrees( latuno );
    latdos := degrees( latdos );
    lonuno := degrees( lonuno );
    londos := degrees( londos );
    totalLat := latuno - latdos;
    totalLon := lonuno - londos;
    distanceA := POWER(SIN(totalLat / 2), 2) + COS(latuno) * COS(latdos) * POWER(SIN(totalLon / 2), 2);
    distanceC := 2 * ASIN(SQRT(distanceA));
    distance := distanceC * 6371;
    RETURN distance;
END;

SELECT DISTANCIA(1, 2) FROM DUAL;