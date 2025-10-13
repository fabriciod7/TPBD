USE DBTP;

--1. Cantidad de equipos que jugaron de local el 1 de diciembre.
	SELECT COUNT(DISTINCT par_idLocal) AS CantEquipos FROM partido
		WHERE DAY(par_fecha) = 1 AND MONTH(par_fecha) = 12

--2. Cantidad de partidos jugados en noviembre de 2022.
	SELECT COUNT(par_idPartido) AS CantPartidos FROM partido
		WHERE MONTH(par_fecha) = 11 AND YEAR(par_fecha) = 2022

--3. Cantidad de jugadores que jugaron para los Bulls.
	SELECT COUNT(DISTINCT je_idJugador) AS CantJugadores FROM jugador_equipo
		JOIN equipo ON (je_idEquipo = equ_idEquipo)
			WHERE equ_code = 'bulls' 

--4. Listado de partidos que se jugaron en noviembre indicando id de partido, fecha, equipo
--local, equipo visitante y los puntos obtenidos por cada uno.
	SELECT par_idPartido, par_fecha, el.equ_nombre AS Local, par_puntosLocal, ev.equ_nombre as Visitante, par_puntosVisitante FROM partido
		JOIN equipo AS el ON (par_idLocal = el.equ_idEquipo) 
		JOIN equipo AS ev ON (par_idVisitante = ev.equ_idEquipo)
			WHERE MONTH(par_fecha) = 11

--5. Cantidad de partidos que perdieron los Bucks jugando como local.
	SELECT COUNT(par_idLocal) AS CantPartidos FROM partido
		JOIN equipo ON (par_idLocal = equ_idEquipo)
			WHERE equ_code = 'bucks' AND par_puntosLocal < par_puntosVisitante

--6. Listar los 5 equipos con mayor promedio de rebotes por partido.
	SELECT TOP 5 equ_nombre, AVG(RebotesTotales) AS PromRebotes FROM (
		SELECT je_idEquipo, ejp_idPartido, SUM(ejp_valor) AS RebotesTotales FROM estadistica_jugador_partido
			JOIN jugador_equipo ON ejp_idJugador = je_idJugador
				WHERE ejp_idEstadistica IN (3, 10) -- id rebotes defensivos y ofensivos
				GROUP BY je_idEquipo, ejp_idPartido
		) AS sub
			JOIN equipo ON sub.je_idEquipo = equ_idEquipo
				GROUP BY equ_nombre
				ORDER BY PromRebotes DESC;

--7. Promedio de puntos por partido de los jugadores agrupados por conferencia.
	SELECT con_nombre, AVG(PromedioJugador) AS PromPuntosxPartido FROM (
		SELECT jug_idJugador, je_idEquipo, AVG(ejp_valor) AS PromedioJugador FROM estadistica_jugador_partido
			JOIN jugador_equipo ON ejp_idJugador = je_idJugador
				JOIN jugador ON ejp_idJugador = jug_idJugador
					WHERE ejp_idEstadistica = 11   -- id puntos
					GROUP BY jug_idJugador, je_idEquipo
		) AS sub
			JOIN equipo ON sub.je_idEquipo = equ_idEquipo
				JOIN division ON equ_idDivision = div_idDivision
					JOIN conferencia ON div_idConferencia = con_idConferencia
						GROUP BY con_nombre

--8. Promedio de asistencias por partido de los equipos agrupados por división.
	SELECT div_nombre, AVG(AsistenciasTotales) AS PromAsistencias FROM (
		SELECT je_idEquipo, ejp_idPartido, SUM(ejp_valor) AS AsistenciasTotales FROM estadistica_jugador_partido
			JOIN jugador_equipo ON ejp_idJugador = je_idJugador
				WHERE ejp_idEstadistica = 1 -- id asistencias
				GROUP BY je_idEquipo, ejp_idPartido
		) AS sub
				JOIN equipo ON sub.je_idEquipo = equ_idEquipo
					JOIN division ON equ_idDivision = div_idDivision
							GROUP BY div_nombre
				
--9. Indicar nombre del país y cantidad de jugadores, del país con más jugadores en el torneo
--(excluyendo Estados Unidos).
	SELECT TOP 1 pai_nombre, COUNT(jug_idJugador) as CantJugadores FROM pais
		JOIN jugador ON (jug_idPais = pai_idPais)
			WHERE jug_idPais <> '3' -- id Estados Unidos
			GROUP BY pai_nombre
			ORDER BY CantJugadores DESC

--10. Promedio de minutos jugados por cada jugador, de los originarios del país del punto
--anterior. Se considera partido jugado si jugó al menos 1 minuto en el partido.
	SELECT 
		jug_idJugador, jug_nombre, jug_apellido, AVG(sub.MinutosTotales) AS PromMinutos FROM (
			SELECT ejp_idJugador, ejp_idPartido, SUM(ejp_valor) AS MinutosTotales FROM estadistica_jugador_partido
				WHERE ejp_idEstadistica = 9 -- id minutos
				GROUP BY ejp_idJugador, ejp_idPartido
			) AS sub
				JOIN jugador ON sub.ejp_idJugador = jug_idJugador
					WHERE jug_idPais = (
						SELECT TOP 1 pai_idPais FROM pais
							JOIN jugador AS j2 ON j2.jug_idPais = pai_idPais
								WHERE pai_idPais <> 3 -- id Estados Unidos
								GROUP BY pai_idPais, pai_nombre
								ORDER BY COUNT(j2.jug_idJugador) DESC
							)
					AND sub.MinutosTotales > 0 -- al menos 1 minuto en el partido
					GROUP BY jug_idJugador, jug_nombre, jug_apellido

--11. Cantidad de jugadores con más de 15 años de carrera.
	SELECT COUNT(jug_idJugador) AS CantJugadores FROM jugador
		WHERE (YEAR(GETDATE()) - jug_anioDraft) > 15

--12. Cantidad de partidos en que los que al menos un jugador de los Suns obtuvo más de 18 puntos.
	SELECT COUNT(DISTINCT par_idPartido) AS CantPartidos FROM estadistica_jugador_partido AS ejp
		JOIN jugador ON ejp.ejp_idJugador = jug_idJugador
		JOIN jugador_equipo ON jug_idJugador = je_idJugador
		JOIN equipo ON je_idEquipo = equ_idEquipo
		JOIN partido ON ejp.ejp_idPartido = par_idPartido
			WHERE ejp.ejp_idEstadistica = 11 -- id puntos
			AND ejp.ejp_valor > 18
			AND equ_code = 'suns'
			AND (par_idLocal = equ_idEquipo OR par_idVisitante = equ_idEquipo)
			AND ejp.ejp_idJugador = (
				SELECT TOP 1 ejp2.ejp_idJugador FROM estadistica_jugador_partido AS ejp2
					JOIN jugador_equipo AS je2 ON ejp2.ejp_idJugador = je2.je_idJugador
					JOIN equipo AS e2 ON je2.je_idEquipo = e2.equ_idEquipo
						WHERE ejp2.ejp_idPartido = ejp.ejp_idPartido
						AND ejp2.ejp_idEstadistica = 11
						AND ejp2.ejp_valor > 18
						AND e2.equ_code = 'suns')

--13. Listado con ID de partido, fecha, sigla y puntos realizados del equipo local y visitante, del
--partido en que el equipo de Matt Ryan ganó por mayor diferencia de puntos en la temporada.
	SELECT TOP 1 par_idPartido, par_fecha, el.equ_sigla AS SiglaLocal, par_puntosLocal,
		ev.equ_sigla AS SiglaVisitante, par_puntosVisitante, ABS(par_puntosLocal - par_puntosVisitante) AS Diferencia
		FROM partido
			JOIN equipo AS el ON par_idLocal = el.equ_idEquipo
			JOIN equipo AS ev ON par_idVisitante = ev.equ_idEquipo
			JOIN jugador_equipo ON (je_idEquipo = el.equ_idEquipo OR je_idEquipo = ev.equ_idEquipo)
			JOIN jugador ON jug_idJugador = je_idJugador
		WHERE jug_nombre = 'Matt' AND jug_apellido = 'Ryan' AND (
			(je_idEquipo = par_idLocal AND par_puntosLocal > par_puntosVisitante) OR -- si su equipo es local y gana
			(je_idEquipo = par_idVisitante AND par_puntosVisitante > par_puntosLocal) -- si su equipo es visitante y gana
		)
	ORDER BY Diferencia DESC;

--14. Listado con el Top 10 de goleadores, indicando nombre del jugador, cantidad de puntos,
--cantidad de partidos jugados, y promedio de puntos por partidos, ordenando por este
--último criterio para determinar los goleadores.
	SELECT TOP 10 jug_idJugador, jug_nombre, jug_apellido, AVG(ejp_valor) AS PromedioJugador, SUM(ejp_valor) as TotalPuntos FROM estadistica_jugador_partido
		JOIN jugador_equipo ON ejp_idJugador = je_idJugador
			JOIN jugador ON ejp_idJugador = jug_idJugador
				WHERE ejp_idEstadistica = 11   -- id puntos
				GROUP BY jug_idJugador, jug_nombre, jug_apellido
				ORDER BY PromedioJugador DESC
		
--15. Tabla de posiciones finales de los equipos de la conferencia Oeste, indicando nombre del
--equipo, código, cantidad partidos ganamos, cantidad partidos perdidos, puntos a favor,
--puntos en contra y diferencia de puntos. Ordenando de mayor a menor por cantidad de
--partidos ganados y diferencia de puntos.
	SELECT equ_nombre, equ_code,
		SUM(CASE 
				WHEN (par_idLocal = equ_idEquipo AND par_puntosLocal > par_puntosVisitante) 
				  OR (par_idVisitante = equ_idEquipo AND par_puntosVisitante > par_puntosLocal)
				THEN 1 ELSE 0 END) AS PG,
		SUM(CASE 
				WHEN (par_idLocal = equ_idEquipo AND par_puntosLocal < par_puntosVisitante) 
				  OR (par_idVisitante = equ_idEquipo AND par_puntosVisitante < par_puntosLocal)
				THEN 1 ELSE 0 END) AS PP,
		SUM(CASE 
				WHEN par_idLocal = equ_idEquipo THEN par_puntosLocal
				ELSE par_puntosVisitante END) AS PF,
		SUM(CASE 
				WHEN par_idLocal = equ_idEquipo THEN par_puntosVisitante
				ELSE par_puntosLocal END) AS PC,
		SUM(CASE 
				WHEN par_idLocal = equ_idEquipo THEN par_puntosLocal - par_puntosVisitante
				ELSE par_puntosVisitante - par_puntosLocal END) AS DP
			FROM partido
				JOIN equipo ON equ_idEquipo IN (par_idLocal, par_idVisitante)
				JOIN division ON equ_idDivision = div_idDivision
				JOIN conferencia ON div_idConferencia = con_idConferencia
	WHERE con_nombre = 'Oeste'
	GROUP BY equ_nombre, equ_code
	ORDER BY PG DESC, DP DESC