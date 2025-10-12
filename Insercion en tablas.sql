USE DBTP;

-- BEGIN TRAN
-- COMMIT
-- ROLLBACK

/* Carga de catálogos base */

-- Estadísticas disponibles
WITH estadisticas_base AS (
    SELECT
        TRY_CAST(v.stat_id AS INT) AS est_id,
        LTRIM(RTRIM(v.stat_nombre)) AS est_descripcion
    FROM migra AS m
    CROSS APPLY (VALUES
        (m.stat_asistencias_id, m.stat_asistencias_nombre),
        (m.stat_blocks_id, m.stat_blocks_nombre),
        (m.stat_defrebs_id, m.stat_defrebs_nombre),
        (m.stat_fga_id, m.stat_fga_nombre),
        (m.stat_fgm_id, m.stat_fgm_nombre),
        (m.stat_fouls_id, m.stat_fouls_nombre),
        (m.stat_fta_id, m.stat_fta_nombre),
        (m.stat_ftm_id, m.stat_ftm_nombre),
        (m.stat_mins_id, m.stat_mins_nombre),
        (m.stat_offrebs_id, m.stat_offrebs_nombre),
        (m.stat_points_id, m.stat_points_nombre),
        (m.stat_secs_id, m.stat_secs_nombre),
        (m.stat_steals_id, m.stat_steals_nombre),
        (m.stat_tpa_id, m.stat_tpa_nombre),
        (m.stat_tpm_id, m.stat_tpm_nombre),
        (m.stat_turnovers_id, m.stat_turnovers_nombre)
    ) AS v(stat_id, stat_nombre)
    WHERE v.stat_id IS NOT NULL
        AND TRY_CAST(v.stat_id AS INT) IS NOT NULL
), estadisticas_src AS (
    SELECT est_id,
           est_descripcion,
           ROW_NUMBER() OVER (PARTITION BY est_id ORDER BY est_descripcion) AS rn
    FROM estadisticas_base
)
INSERT INTO estadistica (est_idEstadistica, est_descripcion)
SELECT es.est_id, es.est_descripcion
FROM estadisticas_src AS es
LEFT JOIN estadistica AS e
    ON e.est_idEstadistica = es.est_id
WHERE es.rn = 1
  AND e.est_idEstadistica IS NULL;

-- Temporadas de la liga
WITH temporadas_base AS (
    SELECT
        TRY_CAST(m.seasonId AS INT) AS tem_id,
        LTRIM(RTRIM(m.yearDisplay)) AS tem_descripcion
    FROM migra AS m
    WHERE m.seasonId IS NOT NULL
        AND TRY_CAST(m.seasonId AS INT) IS NOT NULL
), temporadas_src AS (
    SELECT tem_id,
           tem_descripcion,
           ROW_NUMBER() OVER (PARTITION BY tem_id ORDER BY tem_descripcion) AS rn
    FROM temporadas_base
)
INSERT INTO temporada (tem_idTemporada, tem_descripcion)
SELECT ts.tem_id, ts.tem_descripcion
FROM temporadas_src AS ts
LEFT JOIN temporada AS t
    ON t.tem_idTemporada = ts.tem_id
WHERE ts.rn = 1
  AND t.tem_idTemporada IS NULL;

-- Países de los jugadores
WITH pais_base AS (
    SELECT
        TRY_CAST(m.idPais AS INT) AS pai_id,
        LTRIM(RTRIM(m.country)) AS pai_nombre
    FROM migra AS m
    WHERE m.idPais IS NOT NULL
        AND TRY_CAST(m.idPais AS INT) IS NOT NULL
), pais_src AS (
    SELECT pai_id,
           pai_nombre,
           ROW_NUMBER() OVER (PARTITION BY pai_id ORDER BY pai_nombre) AS rn
    FROM pais_base
)
INSERT INTO pais (pai_idPais, pai_nombre)
SELECT ps.pai_id, ps.pai_nombre
FROM pais_src AS ps
LEFT JOIN pais AS p
    ON p.pai_idPais = ps.pai_id
WHERE ps.rn = 1
  AND p.pai_idPais IS NULL;

-- Ciudades de franquicias
WITH ciudades_base AS (
    SELECT
        TRY_CAST(m.idCity AS INT) AS ciu_id,
        LTRIM(RTRIM(m.city)) AS ciu_nombre
    FROM migra AS m
    WHERE m.idCity IS NOT NULL
        AND TRY_CAST(m.idCity AS INT) IS NOT NULL
    UNION ALL
    SELECT
        TRY_CAST(m.OPidCity AS INT) AS ciu_id,
        LTRIM(RTRIM(m.OPcity)) AS ciu_nombre
    FROM migra AS m
    WHERE m.OPidCity IS NOT NULL
        AND TRY_CAST(m.OPidCity AS INT) IS NOT NULL
), ciudades_src AS (
    SELECT ciu_id,
           ciu_nombre,
           ROW_NUMBER() OVER (PARTITION BY ciu_id ORDER BY ciu_nombre) AS rn
    FROM ciudades_base
)
INSERT INTO ciudad (ciu_idCiudad, ciu_nombre)
SELECT cs.ciu_id, cs.ciu_nombre
FROM ciudades_src AS cs
LEFT JOIN ciudad AS c
    ON c.ciu_idCiudad = cs.ciu_id
WHERE cs.rn = 1
  AND c.ciu_idCiudad IS NULL;

-- Conferencias
WITH conferencias_base AS (
    SELECT LTRIM(RTRIM(m.Conference)) AS con_nombre
    FROM migra AS m
    WHERE m.Conference IS NOT NULL
    UNION ALL
    SELECT LTRIM(RTRIM(m.OPConference))
    FROM migra AS m
    WHERE m.OPConference IS NOT NULL
), conferencias_src AS (
    SELECT con_nombre,
           ROW_NUMBER() OVER (PARTITION BY con_nombre ORDER BY con_nombre) AS rn
    FROM conferencias_base
)
INSERT INTO conferencia (con_nombre)
SELECT cs.con_nombre
FROM conferencias_src AS cs
LEFT JOIN conferencia AS c
    ON c.con_nombre = cs.con_nombre
WHERE cs.rn = 1
  AND c.con_idConferencia IS NULL;

-- Divisiones por conferencia
WITH divisiones_base AS (
    SELECT
        LTRIM(RTRIM(m.division)) AS div_nombre,
        LTRIM(RTRIM(m.Conference)) AS con_nombre
    FROM migra AS m
    WHERE m.division IS NOT NULL
      AND m.Conference IS NOT NULL
    UNION ALL
    SELECT
        LTRIM(RTRIM(m.OPdivision)) AS div_nombre,
        LTRIM(RTRIM(m.OPConference)) AS con_nombre
    FROM migra AS m
    WHERE m.OPdivision IS NOT NULL
      AND m.OPConference IS NOT NULL
), divisiones_src AS (
    SELECT div_nombre,
           con_nombre,
           ROW_NUMBER() OVER (
               PARTITION BY div_nombre, con_nombre
               ORDER BY div_nombre
           ) AS rn
    FROM divisiones_base
)
INSERT INTO division (div_idConferencia, div_nombre)
SELECT c.con_idConferencia, ds.div_nombre
FROM divisiones_src AS ds
INNER JOIN conferencia AS c ON c.con_nombre = ds.con_nombre
LEFT JOIN division AS d
    ON d.div_nombre = ds.div_nombre
   AND d.div_idConferencia = c.con_idConferencia
WHERE ds.rn = 1
  AND ds.con_nombre IS NOT NULL
  AND d.div_idDivision IS NULL;

/* Carga de entidades dependientes */

-- Equipos de la liga y rivales
WITH equipos_base AS (
    SELECT
        TRY_CAST(m.teamid AS INT) AS equ_id,
        LTRIM(RTRIM(m.teamCode)) AS equ_code,
        LTRIM(RTRIM(m.[name])) AS equ_nombre,
        UPPER(LTRIM(RTRIM(m.sigla))) AS equ_sigla,
        TRY_CAST(m.idCity AS INT) AS equ_idCiudad,
        LTRIM(RTRIM(m.division)) AS div_nombre,
        LTRIM(RTRIM(m.Conference)) AS con_nombre
    FROM migra AS m
    WHERE m.teamid IS NOT NULL
        AND TRY_CAST(m.teamid AS INT) IS NOT NULL
    UNION ALL
    SELECT
        TRY_CAST(m.OPid AS INT) AS equ_id,
        LTRIM(RTRIM(m.OPcode)) AS equ_code,
        LTRIM(RTRIM(m.OPname)) AS equ_nombre,
        UPPER(LTRIM(RTRIM(m.OPsigla))) AS equ_sigla,
        TRY_CAST(m.OPidCity AS INT) AS equ_idCiudad,
        LTRIM(RTRIM(m.OPdivision)) AS div_nombre,
        LTRIM(RTRIM(m.OPConference)) AS con_nombre
    FROM migra AS m
    WHERE m.OPid IS NOT NULL
        AND TRY_CAST(m.OPid AS INT) IS NOT NULL
), equipos_src AS (
    SELECT equ_id,
           equ_code,
           equ_nombre,
           equ_sigla,
           equ_idCiudad,
           div_nombre,
           con_nombre,
           ROW_NUMBER() OVER (
               PARTITION BY equ_id
               ORDER BY equ_nombre, equ_code
           ) AS rn
    FROM equipos_base
    WHERE equ_id IS NOT NULL
      AND equ_idCiudad IS NOT NULL
      AND div_nombre IS NOT NULL
      AND con_nombre IS NOT NULL
), equipos_normalizados AS (
    SELECT es.*, c.con_idConferencia
    FROM equipos_src AS es
    INNER JOIN conferencia AS c
        ON c.con_nombre = es.con_nombre
    WHERE es.rn = 1
      AND es.con_nombre IS NOT NULL
)
INSERT INTO equipo (equ_idEquipo, equ_code, equ_nombre, equ_sigla, equ_idCiudad, equ_idDivision)
SELECT en.equ_id,
       en.equ_code,
       en.equ_nombre,
       en.equ_sigla,
       en.equ_idCiudad,
       d.div_idDivision
FROM equipos_normalizados AS en
INNER JOIN division AS d
    ON d.div_nombre = en.div_nombre
   AND d.div_idConferencia = en.con_idConferencia
LEFT JOIN equipo AS e
    ON e.equ_idEquipo = en.equ_id
WHERE e.equ_idEquipo IS NULL;

-- Jugadores
WITH jugadores_base AS (
    SELECT
        TRY_CAST(m.playerId AS INT) AS jug_id,
        LTRIM(RTRIM(m.firstName)) AS jug_nombre,
        LTRIM(RTRIM(m.lastName)) AS jug_apellido,
        LTRIM(RTRIM(m.position)) AS jug_posicion,
        CASE
            WHEN m.height LIKE '%-%' THEN TRY_CAST(
                TRY_CAST(LEFT(m.height, CHARINDEX('-', m.height) - 1) AS DECIMAL(4,2)) +
                TRY_CAST(SUBSTRING(m.height, CHARINDEX('-', m.height) + 1, LEN(m.height)) AS DECIMAL(4,2)) / 12.0
            AS DECIMAL(4,2))
            ELSE TRY_CAST(REPLACE(m.height, ',', '.') AS DECIMAL(4,2))
        END AS jug_altura,
        TRY_CAST(REPLACE(REPLACE(REPLACE(m.[weight], 'libras', ''), 'lbs', ''), ' ', '') AS DECIMAL(5,2)) AS jug_peso,
        TRY_CAST(NULLIF(LTRIM(RTRIM(m.draftYear)), '') AS INT) AS jug_anioDraft,
        TRY_CAST(m.idPais AS INT) AS jug_idPais
    FROM migra AS m
    WHERE m.playerId IS NOT NULL
        AND TRY_CAST(m.playerId AS INT) IS NOT NULL
), jugadores_src AS (
    SELECT jug_id,
           jug_nombre,
           jug_apellido,
           jug_posicion,
           jug_altura,
           jug_peso,
           jug_anioDraft,
           jug_idPais,
           ROW_NUMBER() OVER (PARTITION BY jug_id ORDER BY jug_apellido, jug_nombre) AS rn
    FROM jugadores_base
    WHERE jug_idPais IS NOT NULL
)
INSERT INTO jugador (jug_idJugador, jug_nombre, jug_apellido, jug_posicion, jug_altura, jug_peso, jug_anioDraft, jug_idPais)
SELECT js.jug_id,
       js.jug_nombre,
       js.jug_apellido,
       js.jug_posicion,
       js.jug_altura,
       js.jug_peso,
       js.jug_anioDraft,
       js.jug_idPais
FROM jugadores_src AS js
LEFT JOIN jugador AS j
    ON j.jug_idJugador = js.jug_id
WHERE js.rn = 1
  AND j.jug_idJugador IS NULL;

-- Relación jugador-equipo
WITH jugador_equipo_base AS (
    SELECT
        TRY_CAST(m.playerId AS INT) AS jug_id,
        TRY_CAST(m.teamid AS INT) AS equ_id,
        NULLIF(LTRIM(RTRIM(m.jerseyNo)), '') AS nro_camiseta
    FROM migra AS m
    WHERE m.playerId IS NOT NULL
        AND TRY_CAST(m.playerId AS INT) IS NOT NULL
        AND m.teamid IS NOT NULL
        AND TRY_CAST(m.teamid AS INT) IS NOT NULL
), jugador_equipo_src AS (
    SELECT jug_id,
           equ_id,
           nro_camiseta,
           ROW_NUMBER() OVER (
               PARTITION BY jug_id, equ_id
               ORDER BY CASE WHEN nro_camiseta IS NULL THEN 1 ELSE 0 END,
                        nro_camiseta
           ) AS rn
    FROM jugador_equipo_base
)
INSERT INTO jugador_equipo (je_idJugador, je_idEquipo, je_nroCamiseta)
SELECT jes.jug_id,
       jes.equ_id,
       jes.nro_camiseta
FROM jugador_equipo_src AS jes
LEFT JOIN jugador_equipo AS je
    ON je.je_idJugador = jes.jug_id
   AND je.je_idEquipo = jes.equ_id
WHERE jes.rn = 1
  AND je.je_idJugador IS NULL;

-- Partidos
WITH partidos_base AS (
    SELECT
        TRY_CAST(m.gameId AS INT) AS par_id,
        TRY_CONVERT(DATE, NULLIF(m.fecha, ''), 112) AS par_fecha,
        TRY_CAST(m.seasonId AS INT) AS tem_id,
        TRY_CAST(m.teamid AS INT) AS equipo_id,
        TRY_CAST(m.OPid AS INT) AS rival_id,
        TRY_CAST(m.teamScore AS INT) AS equipo_score,
        TRY_CAST(m.oppTeamScore AS INT) AS rival_score,
        CASE WHEN UPPER(LTRIM(RTRIM(m.isHome))) = 'TRUE' THEN 1 ELSE 0 END AS es_local
    FROM migra AS m
    WHERE m.gameId IS NOT NULL
        AND TRY_CAST(m.gameId AS INT) IS NOT NULL
), partidos_src AS (
    SELECT pb.par_id,
           pb.tem_id,
           pb.par_fecha,
           CASE WHEN pb.es_local = 1 THEN pb.equipo_id ELSE pb.rival_id END AS equ_local,
           CASE WHEN pb.es_local = 1 THEN pb.rival_id ELSE pb.equipo_id END AS equ_visitante,
           CASE WHEN pb.es_local = 1 THEN pb.equipo_score ELSE pb.rival_score END AS puntos_local,
           CASE WHEN pb.es_local = 1 THEN pb.rival_score ELSE pb.equipo_score END AS puntos_visitante,
           ROW_NUMBER() OVER (
               PARTITION BY pb.par_id
               ORDER BY pb.es_local DESC, pb.par_fecha DESC
           ) AS rn
    FROM partidos_base AS pb
    WHERE pb.par_id IS NOT NULL
        AND pb.tem_id IS NOT NULL
        AND pb.par_fecha IS NOT NULL
        AND pb.equipo_id IS NOT NULL
        AND pb.rival_id IS NOT NULL
)
INSERT INTO partido (
    par_idPartido,
    par_idTemporada,
    par_fecha,
    par_idLocal,
    par_idVisitante,
    par_puntosLocal,
    par_puntosVisitante
)
SELECT ps.par_id,
       ps.tem_id,
       ps.par_fecha,
       ps.equ_local,
       ps.equ_visitante,
       ps.puntos_local,
       ps.puntos_visitante
FROM partidos_src AS ps
LEFT JOIN partido AS p
    ON p.par_idPartido = ps.par_id
WHERE ps.rn = 1
  AND p.par_idPartido IS NULL;

-- Participaciones de jugadores en cada partido
WITH partido_jugador_base AS (
    SELECT
        TRY_CAST(m.gameId AS INT) AS par_id,
        TRY_CAST(m.playerId AS INT) AS jug_id
    FROM migra AS m
    WHERE m.gameId IS NOT NULL
        AND TRY_CAST(m.gameId AS INT) IS NOT NULL
        AND m.playerId IS NOT NULL
        AND TRY_CAST(m.playerId AS INT) IS NOT NULL
), partido_jugador_src AS (
    SELECT par_id,
           jug_id,
           ROW_NUMBER() OVER (
               PARTITION BY par_id, jug_id
               ORDER BY par_id
           ) AS rn
    FROM partido_jugador_base
)
INSERT INTO partido_jugador (pj_idPartido, pj_idJugador)
SELECT pjs.par_id,
       pjs.jug_id
FROM partido_jugador_src AS pjs
LEFT JOIN partido_jugador AS pj
    ON pj.pj_idPartido = pjs.par_id
   AND pj.pj_idJugador = pjs.jug_id
WHERE pjs.rn = 1
  AND pj.pj_idPartido IS NULL;

-- Métricas por jugador y partido
WITH estadisticas_jugador_base AS (
    SELECT
        TRY_CAST(m.gameId AS INT) AS par_id,
        TRY_CAST(m.playerId AS INT) AS jug_id,
        TRY_CAST(v.stat_id AS INT) AS est_id,
        TRY_CAST(REPLACE(NULLIF(v.stat_valor, ''), ',', '.') AS DECIMAL(9,2)) AS valor
    FROM migra AS m
    CROSS APPLY (VALUES
        (m.stat_asistencias_id, m.stat_asistencias_valor),
        (m.stat_blocks_id, m.stat_blocks_valor),
        (m.stat_defrebs_id, m.stat_defrebs_valor),
        (m.stat_fga_id, m.stat_fga_valor),
        (m.stat_fgm_id, m.stat_fgm_valor),
        (m.stat_fouls_id, m.stat_fouls_valor),
        (m.stat_fta_id, m.stat_fta_valor),
        (m.stat_ftm_id, m.stat_ftm_valor),
        (m.stat_mins_id, m.stat_mins_valor),
        (m.stat_offrebs_id, m.stat_offrebs_valor),
        (m.stat_points_id, m.stat_points_valor),
        (m.stat_secs_id, m.stat_secs_valor),
        (m.stat_steals_id, m.stat_steals_valor),
        (m.stat_tpa_id, m.stat_tpa_valor),
        (m.stat_tpm_id, m.stat_tpm_valor),
        (m.stat_turnovers_id, m.stat_turnovers_valor)
    ) AS v(stat_id, stat_valor)
    WHERE m.gameId IS NOT NULL
        AND TRY_CAST(m.gameId AS INT) IS NOT NULL
        AND m.playerId IS NOT NULL
        AND TRY_CAST(m.playerId AS INT) IS NOT NULL
        AND v.stat_id IS NOT NULL
        AND TRY_CAST(v.stat_id AS INT) IS NOT NULL
), estadisticas_jugador AS (
    SELECT par_id,
           jug_id,
           est_id,
           valor,
           ROW_NUMBER() OVER (
               PARTITION BY par_id, jug_id, est_id
               ORDER BY CASE WHEN valor IS NULL THEN 1 ELSE 0 END
           ) AS rn
    FROM estadisticas_jugador_base
)
INSERT INTO estadistica_jugador_partido (ejp_idPartido, ejp_idJugador, ejp_idEstadistica, ejp_valor)
SELECT ej.par_id,
       ej.jug_id,
       ej.est_id,
       ej.valor
FROM estadisticas_jugador AS ej
LEFT JOIN estadistica_jugador_partido AS e
    ON e.ejp_idPartido = ej.par_id
   AND e.ejp_idJugador = ej.jug_id
   AND e.ejp_idEstadistica = ej.est_id
WHERE ej.rn = 1
  AND ej.valor IS NOT NULL
  AND e.ejp_idPartido IS NULL;

 --SELECT * FROM jugador (para probar como quedaron las tablas)