CREATE DATABASE DBTP
USE DBTP

CREATE TABLE migra (
    OPcity NVARCHAR(255) NULL,
    OPcode NVARCHAR(255) NULL,
    OPsigla NVARCHAR(255) NULL,
    OPConference NVARCHAR(255) NULL,
    OPdivision NVARCHAR(255) NULL,
    OPid NVARCHAR(255) NULL,
    OPname NVARCHAR(255) NULL,
    stat_asistencias_id NVARCHAR(255) NULL,
    stat_asistencias_nombre NVARCHAR(255) NULL,
    stat_asistencias_valor NVARCHAR(255) NULL,
    stat_blocks_id NVARCHAR(255) NULL,
    stat_blocks_nombre NVARCHAR(255) NULL,
    stat_blocks_valor NVARCHAR(255) NULL,
    city NVARCHAR(255) NULL,
    codeJug NVARCHAR(255) NULL,
    country NVARCHAR(255) NULL,
    stat_defrebs_id NVARCHAR(255) NULL,
    stat_defrebs_nombre NVARCHAR(255) NULL,
    stat_defrebs_valor NVARCHAR(255) NULL,
    sigla NVARCHAR(255) NULL,
    Conference NVARCHAR(255) NULL,
    NamePlayer NVARCHAR(255) NULL,
    division NVARCHAR(255) NULL,
    draftYear NVARCHAR(255) NULL,
    fecha NVARCHAR(255) NULL,
    stat_fga_id NVARCHAR(255) NULL,
    stat_fga_nombre NVARCHAR(255) NULL,
    stat_fga_valor NVARCHAR(255) NULL,
    stat_fgm_id NVARCHAR(255) NULL,
    stat_fgm_nombre NVARCHAR(255) NULL,
    stat_fgm_valor NVARCHAR(255) NULL,
    fgpct NVARCHAR(255) NULL,
    firstName NVARCHAR(255) NULL,
    stat_fouls_id NVARCHAR(255) NULL,
    stat_fouls_nombre NVARCHAR(255) NULL,
    stat_fouls_valor NVARCHAR(255) NULL,
    stat_fta_id NVARCHAR(255) NULL,
    stat_fta_nombre NVARCHAR(255) NULL,
    stat_fta_valor NVARCHAR(255) NULL,
    stat_ftm_id NVARCHAR(255) NULL,
    stat_ftm_nombre NVARCHAR(255) NULL,
    stat_ftm_valor NVARCHAR(255) NULL,
    ftpct NVARCHAR(255) NULL,
    gameId NVARCHAR(255) NULL,
    height NVARCHAR(255) NULL,
    isHome NVARCHAR(255) NULL,
    jerseyNo NVARCHAR(255) NULL,
    lastName NVARCHAR(255) NULL,
    stat_mins_id NVARCHAR(255) NULL,
    stat_mins_nombre NVARCHAR(255) NULL,
    stat_mins_valor NVARCHAR(255) NULL,
    [name] NVARCHAR(255) NULL,
    stat_offrebs_id NVARCHAR(255) NULL,
    stat_offrebs_nombre NVARCHAR(255) NULL,
    stat_offrebs_valor NVARCHAR(255) NULL,
    oppTeamScore NVARCHAR(255) NULL,
    playerId NVARCHAR(255) NULL,
    stat_points_id NVARCHAR(255) NULL,
    stat_points_nombre NVARCHAR(255) NULL,
    stat_points_valor NVARCHAR(255) NULL,
    position NVARCHAR(255) NULL,
    rebs NVARCHAR(255) NULL,
    seasonId NVARCHAR(255) NULL,
    stat_secs_id NVARCHAR(255) NULL,
    stat_secs_nombre NVARCHAR(255) NULL,
    stat_secs_valor NVARCHAR(255) NULL,
    stat_steals_id NVARCHAR(255) NULL,
    stat_steals_nombre NVARCHAR(255) NULL,
    stat_steals_valor NVARCHAR(255) NULL,
    teamCode NVARCHAR(255) NULL,
    teamScore NVARCHAR(255) NULL,
    teamid NVARCHAR(255) NULL,
    stat_tpa_id NVARCHAR(255) NULL,
    stat_tpa_nombre NVARCHAR(255) NULL,
    stat_tpa_valor NVARCHAR(255) NULL,
    stat_tpm_id NVARCHAR(255) NULL,
    stat_tpm_nombre NVARCHAR(255) NULL,
    stat_tpm_valor NVARCHAR(255) NULL,
    tppct NVARCHAR(255) NULL,
    stat_turnovers_id NVARCHAR(255) NULL,
    stat_turnovers_nombre NVARCHAR(255) NULL,
    stat_turnovers_valor NVARCHAR(255) NULL,
    [weight] NVARCHAR(255) NULL,
    winOrLoss NVARCHAR(255) NULL,
    yearDisplay NVARCHAR(255) NULL,
    idPais NVARCHAR(255) NULL,
    idCity NVARCHAR(255) NULL,
    OPidCity NVARCHAR(255) NULL
);

BULK INSERT migra
FROM 'C:\Users\fabri\OneDrive\Desktop\datos_grupo15.csv'
WITH (
    DATAFILETYPE = 'char', -- Indica que el origen es texto plano.
    CODEPAGE = '65001', -- UTF-8
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', -- El CSV utiliza comas como separador de columnas.
    ROWTERMINATOR = '\n',
    TABLOCK -- Bloquea la tabla durante la carga para acelerar inserciones masivas.
);

-- SELECT * FROM migra

-- BEGIN TRANSACTION
-- COMMIT
-- ROLLBACK

-- DROP TABLE migra

-- Los datos fueron saneados previamente mediante Excel, se buscaron las tabulaciones y se reemplazaron por espacios simples, y ademas se busco la ñ y cada vocal tildada,
-- reemplazandolas por n (en el caso de España se la renombro Spain) y vocales simples.

-- Consulta de apoyo para detectar valores con espacios a la izquierda o derecha, ia friendly :)

SELECT
    fila = ROW_NUMBER() OVER (ORDER BY (SELECT 0)),
    columna,
    valor_original
FROM migra AS s
CROSS APPLY (VALUES
    ('OPcity', s.OPcity),
    ('OPcode', s.OPcode),
    ('OPsigla', s.OPsigla),
    ('OPConference', s.OPConference),
    ('OPdivision', s.OPdivision),
    ('OPid', s.OPid),
    ('OPname', s.OPname),
    ('stat_asistencias_id', s.stat_asistencias_id),
    ('stat_asistencias_nombre', s.stat_asistencias_nombre),
    ('stat_asistencias_valor', s.stat_asistencias_valor),
    ('stat_blocks_id', s.stat_blocks_id),
    ('stat_blocks_nombre', s.stat_blocks_nombre),
    ('stat_blocks_valor', s.stat_blocks_valor),
    ('city', s.city),
    ('codeJug', s.codeJug),
    ('country', s.country),
    ('stat_defrebs_id', s.stat_defrebs_id),
    ('stat_defrebs_nombre', s.stat_defrebs_nombre),
    ('stat_defrebs_valor', s.stat_defrebs_valor),
    ('sigla', s.sigla),
    ('Conference', s.Conference),
    ('NamePlayer', s.NamePlayer),
    ('division', s.division),
    ('draftYear', s.draftYear),
    ('fecha', s.fecha),
    ('stat_fga_id', s.stat_fga_id),
    ('stat_fga_nombre', s.stat_fga_nombre),
    ('stat_fga_valor', s.stat_fga_valor),
    ('stat_fgm_id', s.stat_fgm_id),
    ('stat_fgm_nombre', s.stat_fgm_nombre),
    ('stat_fgm_valor', s.stat_fgm_valor),
    ('fgpct', s.fgpct),
    ('firstName', s.firstName),
    ('stat_fouls_id', s.stat_fouls_id),
    ('stat_fouls_nombre', s.stat_fouls_nombre),
    ('stat_fouls_valor', s.stat_fouls_valor),
    ('stat_fta_id', s.stat_fta_id),
    ('stat_fta_nombre', s.stat_fta_nombre),
    ('stat_fta_valor', s.stat_fta_valor),
    ('stat_ftm_id', s.stat_ftm_id),
    ('stat_ftm_nombre', s.stat_ftm_nombre),
    ('stat_ftm_valor', s.stat_ftm_valor),
    ('ftpct', s.ftpct),
    ('gameId', s.gameId),
    ('height', s.height),
    ('isHome', s.isHome),
    ('jerseyNo', s.jerseyNo),
    ('lastName', s.lastName),
    ('stat_mins_id', s.stat_mins_id),
    ('stat_mins_nombre', s.stat_mins_nombre),
    ('stat_mins_valor', s.stat_mins_valor),
    ('name', s.name),
    ('stat_offrebs_id', s.stat_offrebs_id),
    ('stat_offrebs_nombre', s.stat_offrebs_nombre),
    ('stat_offrebs_valor', s.stat_offrebs_valor),
    ('oppTeamScore', s.oppTeamScore),
    ('playerId', s.playerId),
    ('stat_points_id', s.stat_points_id),
    ('stat_points_nombre', s.stat_points_nombre),
    ('stat_points_valor', s.stat_points_valor),
    ('position', s.position),
    ('rebs', s.rebs),
    ('seasonId', s.seasonId),
    ('stat_secs_id', s.stat_secs_id),
    ('stat_secs_nombre', s.stat_secs_nombre),
    ('stat_secs_valor', s.stat_secs_valor),
    ('stat_steals_id', s.stat_steals_id),
    ('stat_steals_nombre', s.stat_steals_nombre),
    ('stat_steals_valor', s.stat_steals_valor),
    ('teamCode', s.teamCode),
    ('teamScore', s.teamScore),
    ('teamid', s.teamid),
    ('stat_tpa_id', s.stat_tpa_id),
    ('stat_tpa_nombre', s.stat_tpa_nombre),
    ('stat_tpa_valor', s.stat_tpa_valor),
    ('stat_tpm_id', s.stat_tpm_id),
    ('stat_tpm_nombre', s.stat_tpm_nombre),
    ('stat_tpm_valor', s.stat_tpm_valor),
    ('tppct', s.tppct),
    ('stat_turnovers_id', s.stat_turnovers_id),
    ('stat_turnovers_nombre', s.stat_turnovers_nombre),
    ('stat_turnovers_valor', s.stat_turnovers_valor),
    ('weight', s.weight),
    ('winOrLoss', s.winOrLoss),
    ('yearDisplay', s.yearDisplay),
    ('idPais', s.idPais),
    ('idCity', s.idCity),
    ('OPidCity', s.OPidCity)
) AS v(columna, valor_original)
WHERE valor_original LIKE ' %' -- espacio a la izquierda
   OR valor_original LIKE '% ' -- espacio a la derecha
;

-- BEGIN TRAN
-- ROLLBACK
-- COMMIT
-- SELECT weight FROM migra
-- SELECT height FROM migra

-- Eliminar la palabra kilogramos

UPDATE migra
	SET weight = LEFT(weight, LEN(weight) - 11)
	WHERE weight LIKE '%kilogramos';

-- Convertir libras a kilogramos y eliminar la palabra

UPDATE migra
SET height = CASE 
        -- Si tiene un guion, formato pies-pulgadas
        WHEN height LIKE '%-%' THEN
            CAST(
                ROUND((
                        CAST(PARSENAME(REPLACE(height, '-', '.'), 2) AS FLOAT)  -- pies
                        + CAST(PARSENAME(REPLACE(height, '-', '.'), 1) AS FLOAT) / 12.0  -- pulgadas
                    ) * 0.3048, 2  -- conversion a metros
                ) AS VARCHAR(20))
        ELSE
            height  -- ya esta en metros, no se toca
    END;