CREATE OR REPLACE PACKAGE PacoteOficial AS
    -- Retorna a quantidade de habitantes em cada momento que o a quantidade muda (habitacao comeca ou acaba)
    -- Retorno: PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, HAB_ATUAL
    FUNCTION evolucao_habitantes(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR;
    -- Retorna a quantidade de habitantes em cada planeta em cada momento que o a quantidade muda (habitacao comeca ou acaba)
    -- Retorno: PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, HAB_ATUAL
    FUNCTION evolucao_habitantes_por_planeta(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR;
    -- Retorna a quantidade de habitantes de cada especie em cada momento que o a quantidade muda (habitacao comeca ou acaba)
    -- Retorno: PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, HAB_ATUAL
    FUNCTION evolucao_habitantes_por_especie(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR;
    -- Retorna a quantidade de habitantes em cada faccao em cada momento que o a quantidade muda (habitacao comeca ou acaba)
    -- Retorno: PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, HAB_ATUAL
    FUNCTION evolucao_habitantes_por_faccao(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR;
    -- Retorna a quantidade de habitantes em cada sistema em cada momento que o a quantidade muda (habitacao comeca ou acaba)
    -- Retorno: PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, HAB_ATUAL
    FUNCTION evolucao_habitantes_por_sistema(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR;
END;
/
CREATE OR REPLACE PACKAGE BODY PacoteOficial AS
-- cada linha de habilitacao gera duas linhas uma para inicio e outra para fim usando uma union, a linha com fim tem a
-- qtd de habitantes negativa, assim qnd gerar o relatorio vai ficar com a qtd de habitantes correta
    FUNCTION evolucao_habitantes(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, SUM(QTD_HABITANTES) OVER (ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS HAB_ATUAL
                    FROM (
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, C.QTD_HABITANTES, H.DATA_INI AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial
                        UNION
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial)
                    WHERE DATA IS NOT NULL
                    ORDER BY DATA;
            RETURN c_return;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001, 'Erro ao buscar habitantes');
    END evolucao_habitantes;

    FUNCTION evolucao_habitantes_por_planeta(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, SUM(QTD_HABITANTES) OVER (PARTITION BY PLANETA ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS HAB_ATUAL
                    FROM (
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, C.QTD_HABITANTES, H.DATA_INI AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial
                        UNION
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial)
                    WHERE DATA IS NOT NULL
                    ORDER BY DATA;

            RETURN c_return;

        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001, 'Erro ao buscar habitantes');
    END evolucao_habitantes_por_planeta;

    FUNCTION evolucao_habitantes_por_especie(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, SUM(QTD_HABITANTES) OVER (PARTITION BY ESPECIE ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS HAB_ATUAL
                    FROM (
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, C.QTD_HABITANTES, H.DATA_INI AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial
                        UNION
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial)
                    WHERE DATA IS NOT NULL
                    ORDER BY DATA;

            RETURN c_return;

        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001, 'Erro ao buscar habitantes');
    END evolucao_habitantes_por_especie;

    FUNCTION evolucao_habitantes_por_faccao(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, SUM(QTD_HABITANTES) OVER (PARTITION BY faccao ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS HAB_ATUAL
                    FROM (
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, C.QTD_HABITANTES, H.DATA_INI AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial
                        UNION
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial)
                    WHERE DATA IS NOT NULL
                    ORDER BY DATA;

            RETURN c_return;

        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001, 'Erro ao buscar habitantes');
    END evolucao_habitantes_por_faccao;

    FUNCTION evolucao_habitantes_por_sistema(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT PLANETA, ESPECIE, FACCAO, SISTEMA, DATA, SUM(QTD_HABITANTES) OVER (PARTITION BY sistema ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS HAB_ATUAL
                    FROM (
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, C.QTD_HABITANTES, H.DATA_INI AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial
                        UNION
                        SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
                            FROM COMUNIDADE C
                            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
                            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
                            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
                            JOIN NACAO N ON D.NACAO = N.NOME
                            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
                            JOIN FACCAO F ON NF.FACCAO = F.NOME
                            JOIN LIDER L ON F.LIDER = L.CPI
                            LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
                            LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
                            LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
                            WHERE L.CPI = p_oficial)
                    WHERE DATA IS NOT NULL
                    ORDER BY DATA;

            RETURN c_return;

        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001, 'Erro ao buscar habitantes');
    END evolucao_habitantes_por_sistema;
END;


SELECT PLANETA, ESPECIE, FACCAO, SISTEMA, SUM(QTD_HABITANTES) OVER (ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS HAB_ATUAL
FROM (
    SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, C.QTD_HABITANTES, H.DATA_INI AS DATA
        FROM COMUNIDADE C
        JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
        JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
        JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
        JOIN NACAO N ON D.NACAO = N.NOME
        JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
        JOIN FACCAO F ON NF.FACCAO = F.NOME
        JOIN LIDER L ON F.LIDER = L.CPI
        LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
        LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
        LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
        WHERE L.CPI = '111.111.111-15'
    UNION
    SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, -C.QTD_HABITANTES, H.DATA_FIM AS DATA
        FROM COMUNIDADE C
        JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
        JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
        JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
        JOIN NACAO N ON D.NACAO = N.NOME
        JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
        JOIN FACCAO F ON NF.FACCAO = F.NOME
        JOIN LIDER L ON F.LIDER = L.CPI
        LEFT JOIN ORBITA_PLANETA OP ON P.ID_ASTRO = OP.PLANETA
        LEFT JOIN ESTRELA E ON OP.ESTRELA = E.ID_ESTRELA
        LEFT JOIN SISTEMA S ON E.ID_ESTRELA = S.NOME
        WHERE L.CPI = '111.111.111-15')
WHERE DATA IS NOT NULL
ORDER BY DATA;


INSERT INTO HABITACAO(COMUNIDADE, ESPECIE, PLANETA, DATA_INI, DATA_FIM) VALUES ('COMUNIDADE2', 'Libero magni', 'Quae possimus.', TO_DATE('01/01/2021', 'DD/MM/YYYY'), TO_DATE('01/01/2022', 'DD/MM/YYYY'));
INSERT INTO HABITACAO(COMUNIDADE, ESPECIE, PLANETA, DATA_INI, DATA_FIM) VALUES ('COMUNIDADE2', 'Libero magni', 'Quae possimus.', TO_DATE('01/01/2018', 'DD/MM/YYYY'), TO_DATE('01/01/2020', 'DD/MM/YYYY'));
INSERT INTO HABITACAO(COMUNIDADE, ESPECIE, PLANETA, DATA_INI, DATA_FIM) VALUES ('COMUNIDADE2', 'Libero magni', 'Quae possimus.', TO_DATE('01/01/2010', 'DD/MM/YYYY'), TO_DATE('01/01/2014', 'DD/MM/YYYY'));

INSERT INTO HABITACAO(COMUNIDADE, ESPECIE, PLANETA, DATA_INI, DATA_FIM) VALUES ('COMUNIDADE2', 'Libero magni', 'Quae possimus.', TO_DATE('01/01/2010', 'DD/MM/YYYY'), TO_DATE('01/01/2014', 'DD/MM/YYYY'));


-- teste evolucao_habitantes('111.111.111-15');
DECLARE
    p_cursor SYS_REFCURSOR;
    v_planeta PLANETA.ID_ASTRO%TYPE;
    v_especie COMUNIDADE.ESPECIE%TYPE;
    v_facco FACCAO.NOME%TYPE;
    v_sistema SISTEMA.NOME%TYPE;
    v_data HABITACAO.DATA_INI%TYPE;
    v_hab_atual integer;
BEGIN
    p_cursor := PacoteOficial.evolucao_habitantes_por_planeta('111.111.111-15');
    LOOP
        FETCH p_cursor INTO v_planeta, v_especie, v_facco, v_sistema, v_data, v_hab_atual;
        EXIT WHEN p_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Planeta: ' || v_planeta || ' Especie: ' || v_especie || ' Faccao: ' || v_facco || ' Sistema: ' || v_sistema || ' Data: ' || v_data || ' Habitantes: ' || v_hab_atual);
    END LOOP;
    CLOSE p_cursor;
END;
