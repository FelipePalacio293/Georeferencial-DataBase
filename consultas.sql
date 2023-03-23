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