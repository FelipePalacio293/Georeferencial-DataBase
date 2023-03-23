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