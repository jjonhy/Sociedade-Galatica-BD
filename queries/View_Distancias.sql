-- Funcao que, dado o id de duas estrelas, calcula a distancia entre elas

CREATE OR REPLACE FUNCTION Distancia_Estrela (
        v_estrela1 ESTRELA.ID_ESTRELA%TYPE,
        v_estrela2 ESTRELA.ID_ESTRELA%TYPE
    )
    RETURN NUMBER IS

    v_distancia NUMBER;

    x_estrela1 ESTRELA.X%TYPE;
    y_estrela1 ESTRELA.Y%TYPE;
    z_estrela1 ESTRELA.Z%TYPE;

    x_estrela2 ESTRELA.X%TYPE;
    y_estrela2 ESTRELA.Y%TYPE;
    z_estrela2 ESTRELA.Z%TYPE;

BEGIN

    SELECT ESTRELA.X,ESTRELA.Y,ESTRELA.Z INTO x_estrela1,y_estrela1,z_estrela1 FROM ESTRELA
        WHERE ESTRELA.ID_ESTRELA = v_estrela1;
    SELECT ESTRELA.X,ESTRELA.Y,ESTRELA.Z INTO x_estrela2,y_estrela2,z_estrela2 FROM ESTRELA
        WHERE ESTRELA.ID_ESTRELA = v_estrela2;

    v_distancia := SQRT(POWER((x_estrela1-x_estrela2),2) + POWER((y_estrela1-y_estrela2),2) + POWER((z_estrela1-z_estrela2),2));

    RETURN v_distancia;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20010, 'Estrela(s) inexistente(s).'); -- Caso nao encontre as estrelas nas consultas SELECT

END Distancia_Estrela;

-- c. Bonus: Implemente uma solucao que otimize o calculo de distancias entre estrelas.

-- Foi implementado uma Materialized View que consegue transportar

CREATE MATERIALIZED VIEW ESTRELAS_DISTANCIAS
    BUILD IMMEDIATE
    REFRESH FORCE ON DEMAND
    AS SELECT E1.ID_ESTRELA AS Estrela1, E2.ID_ESTRELA AS Estrela2,
        Distancia_Estrela(E1.ID_ESTRELA,E2.ID_ESTRELA) AS Distance
    
    FROM ESTRELA E1 CROSS JOIN ESTRELA E2
    WHERE E1.ID_ESTRELA < E2.ID_ESTRELA;
-- Ok
-- 3444 segundos para criar

-- TESTES:

SELECT count(*) FROM ESTRELAS_DISTANCIAS;
-- 21704166 linhas de distancia

explain plan for
SELECT * FROM ESTRELAS_DISTANCIAS WHERE Estrela1 = '1' AND Estrela2 = '9';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*
--------------------------------------------------------------------------------------------
| Id  | Operation            | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |                     |     1 |    39 | 36783   (2)| 00:00:02 |
|*  1 |  MAT_VIEW ACCESS FULL| ESTRELAS_DISTANCIAS |     1 |    39 | 36783   (2)| 00:00:02 |
--------------------------------------------------------------------------------------------
*/

-- Nao foi criado ainda (demora MUITO)
CREATE INDEX IDX_ESTRELAS_DISTANCIAS_1 ON ESTRELAS_DISTANCIAS(Estrela1, Estrela2);

CREATE INDEX IDX_ESTRELAS_DISTANCIAS_2 ON ESTRELAS_DISTANCIAS(Estrela2, Estrela1);

explain plan for
SELECT * FROM ESTRELAS_DISTANCIAS WHERE Estrela1 = '1' AND Estrela2 = '9';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*
--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                              | Name                      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                       |                           |     1 |    39 |     4   (0)| 00:00:01 |
|   1 |  MAT_VIEW ACCESS BY INDEX ROWID BATCHED| ESTRELAS_DISTANCIAS       |     1 |    39 |     4   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                     | IDX_ESTRELAS_DISTANCIAS_2 |     1 |       |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------
*/

-- FIM_TESTES