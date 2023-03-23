# Trigger que restringe el hecho de que puedan haber mas de 4 matrimonios ancestrales
CREATE OR REPLACE TRIGGER ANCESTRALES
BEFORE INSERT OR UPDATE ON MATRIMONIO
FOR EACH ROW
DECLARE 
    numMatrimonios INTEGER;
BEGIN
    SELECT COUNT(*) INTO numMatrimonios FROM MATRIMONIO WHERE TIPO = 'Ancestral';
    IF numMatrimonios >= 4 AND :NEW.TIPO = 'Ancestral'  THEN 
        RAISE_APPLICATION_ERROR(-20099, 'Cannot Insert More Than 4 marriages Ancestrals');
    END IF
END;

# Trigger que restringe el hecho de que una persona que viva en Transnopoli pueda trabajar allí mismo.

CREATE OR REPLACE TRIGGER CIUDAD
BEFORE INSERT OR UPDATE ON TRABAJO
FOR EACH ROW
DECLARE 
    city INTEGER;
BEGIN
    IF :NEW.PERSONA_ID IS NOT NULL THEN
        SELECT CIUDADRESIDENCIA INTO city FROM PERSONA WHERE ID = :NEW.PERSONA_ID;
        IF city = 1 AND :NEW.CIUDAD_ID = 1 THEN
            RAISE_APPLICATION_ERROR(-20099, 'Cannot Insert Because Person Work and Live on Transnopoli'); 
        END IF;
    END IF;
END;

# Trigger que restringe el hecho de que si alguien vive en Transnopoli, al menos uno de sus padres debe de ser de esta ciudad. 

CREATE OR REPLACE TRIGGER RESIDENCIA
BEFORE INSERT OR UPDATE ON PERSONA
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