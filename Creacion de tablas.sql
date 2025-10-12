
USE DBTP

CREATE TABLE estadistica (
    est_idEstadistica INT NOT NULL PRIMARY KEY,
    est_descripcion NVARCHAR(50) NOT NULL,
);

CREATE TABLE temporada (
    tem_idTemporada INT NOT NULL PRIMARY KEY,
    tem_descripcion NVARCHAR(50) NOT NULL,
);

CREATE TABLE pais (
    pai_idPais INT NOT NULL PRIMARY KEY,
    pai_nombre NVARCHAR(50) NOT NULL,
);

CREATE TABLE ciudad (
    ciu_idCiudad INT NOT NULL PRIMARY KEY,
    ciu_nombre NVARCHAR(50) NOT NULL,
);

CREATE TABLE conferencia (
    con_idConferencia INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    con_nombre NVARCHAR(50) NOT NULL,
);

CREATE TABLE division (
    div_idDivision INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    div_idConferencia INT NOT NULL,
    div_nombre NVARCHAR(50) NOT NULL,
    FOREIGN KEY (div_idConferencia) REFERENCES conferencia(con_idConferencia)
);

CREATE TABLE equipo (
    equ_idEquipo INT NOT NULL PRIMARY KEY,
    equ_code NVARCHAR(50) NOT NULL,
    equ_nombre NVARCHAR(50) NOT NULL,
    equ_sigla CHAR(3) NOT NULL,
    equ_idCiudad INT NOT NULL,
    equ_idDivision INT NOT NULL,
    FOREIGN KEY (equ_idCiudad) REFERENCES ciudad(ciu_idCiudad),
    FOREIGN KEY (equ_idDivision) REFERENCES division(div_idDivision)
);

CREATE TABLE jugador (
    jug_idJugador INT NOT NULL PRIMARY KEY,
    jug_nombre NVARCHAR(50) NOT NULL,
    jug_apellido NVARCHAR(50) NOT NULL,
    jug_posicion NVARCHAR(5) NOT NULL,
    jug_altura DECIMAL(4,2) NULL,
    jug_peso DECIMAL(5,2) NULL,
    jug_anioDraft INT NULL,
    jug_idPais INT NOT NULL,
    FOREIGN KEY (jug_idPais) REFERENCES pais(pai_idPais)
);

CREATE TABLE partido (
    par_idPartido INT NOT NULL PRIMARY KEY,
    par_idTemporada INT NOT NULL,
    par_fecha DATE NOT NULL,
    par_idLocal INT NOT NULL,
    par_idVisitante INT NOT NULL,
    par_puntosLocal int NOT NULL CHECK (par_puntosLocal >= 0),
    par_puntosVisitante INT NOT NULL CHECK (par_puntosVisitante >= 0),
    FOREIGN KEY (par_idTemporada) REFERENCES temporada(tem_idTemporada),
    FOREIGN KEY (par_idLocal) REFERENCES equipo(equ_idEquipo),
    FOREIGN KEY (par_idVisitante) REFERENCES equipo(equ_idEquipo),
);

CREATE TABLE jugador_equipo(
    je_idJugador INT NOT NULL,
    je_idEquipo INT NOT NULL,
    je_nroCamiseta NVARCHAR(5),
    CONSTRAINT je_idJE PRIMARY KEY (je_idJugador, je_idEquipo),
    FOREIGN KEY (je_idJugador) REFERENCES jugador(jug_idJugador),
    FOREIGN KEY (je_idEquipo) REFERENCES equipo(equ_idEquipo)
);

CREATE TABLE partido_jugador (
    pj_idPartido INT NOT NULL,
    pj_idJugador INT NOT NULL,
    CONSTRAINT pj_idPJ PRIMARY KEY (pj_idPartido, pj_idJugador),
    FOREIGN KEY (pj_idPartido) REFERENCES partido(par_idPartido),
    FOREIGN KEY (pj_idJugador) REFERENCES jugador(jug_idJugador)
);

CREATE TABLE estadistica_jugador_partido (
	ejp_idPartido INT NOT NULL,
    ejp_idJugador INT NOT NULL,
    ejp_idEstadistica INT NOT NULL,
    ejp_valor DECIMAL(9,2) NOT NULL,
    CONSTRAINT ejp_idEJP PRIMARY KEY (ejp_idPartido, ejp_idEstadistica, ejp_idJugador),
    FOREIGN KEY (ejp_idPartido) REFERENCES partido(par_idPartido),
    FOREIGN KEY (ejp_idJugador) REFERENCES jugador(jug_idJugador),
    FOREIGN KEY (ejp_idEstadistica) REFERENCES estadistica(est_idEstadistica)
);