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