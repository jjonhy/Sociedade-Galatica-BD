CREATE OR REPLACE PACKAGE PacoteOficial AS
    FUNCTION evolucao_habitantes(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR;
END;
/
CREATE OR REPLACE PACKAGE BODY PacoteOficial AS
-- cada linha de habilitacao gera duas linhas uma para inicio e outra para fim usando uma union, a linha com fim tem a
-- qtd de habitantes negativa, assim qnd gerar o relatorio vai ficar com a qtd de habitantes correta
    FUNCTION evolucao_habitantes(p_oficial lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT *, SUM(QTD_HABITANTES) OVER (ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS HAB_ATUAL FROM (
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
                    SELECT P.ID_ASTRO AS PLANETA, C.ESPECIE, F.NOME AS FACCAO, S.NOME AS SISTEMA, -C.QTD_HABITANTES, H.DATA_INI AS DATA
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
END;


SELECT DATA, SUM(QTD_HABITANTES) OVER (ORDER BY DATA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS HAB_ATUAL FROM (
    SELECT C.QTD_HABITANTES, H.DATA_INI AS DATA
        FROM COMUNIDADE C
        JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
        JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
        JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
        JOIN NACAO N ON D.NACAO = N.NOME
        JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
        JOIN FACCAO F ON NF.FACCAO = F.NOME
        JOIN LIDER L ON F.LIDER = L.CPI
        WHERE L.CPI = '111.111.111-15'
    UNION
    SELECT -C.QTD_HABITANTES, H.DATA_FIM AS DATA
        FROM COMUNIDADE C
        JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
        JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
        JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
        JOIN NACAO N ON D.NACAO = N.NOME
        JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
        JOIN FACCAO F ON NF.FACCAO = F.NOME
        JOIN LIDER L ON F.LIDER = L.CPI
        WHERE L.CPI = '111.111.111-15')
WHERE DATA IS NOT NULL
ORDER BY DATA;
select * from HABITACAO;

SELECT *
        FROM COMUNIDADE C
        JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
        JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
        JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
        JOIN NACAO N ON D.NACAO = N.NOME
        JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
        JOIN FACCAO F ON NF.FACCAO = F.NOME
        JOIN LIDER L ON F.LIDER = L.CPI
        WHERE L.CPI = '111.111.111-15';

INSERT INTO HABITACAO(COMUNIDADE, ESPECIE, PLANETA, DATA_INI, DATA_FIM) VALUES ('COMUNIDADE2', 'Libero magni', 'Quae possimus.', TO_DATE('01/01/2021', 'DD/MM/YYYY'), TO_DATE('01/01/2022', 'DD/MM/YYYY'));
INSERT INTO HABITACAO(COMUNIDADE, ESPECIE, PLANETA, DATA_INI, DATA_FIM) VALUES ('COMUNIDADE2', 'Libero magni', 'Quae possimus.', TO_DATE('01/01/2018', 'DD/MM/YYYY'), TO_DATE('01/01/2020', 'DD/MM/YYYY'));
INSERT INTO HABITACAO(COMUNIDADE, ESPECIE, PLANETA, DATA_INI, DATA_FIM) VALUES ('COMUNIDADE2', 'Libero magni', 'Quae possimus.', TO_DATE('01/01/2010', 'DD/MM/YYYY'), TO_DATE('01/01/2014', 'DD/MM/YYYY'));

INSERT INTO HABITACAO(COMUNIDADE, ESPECIE, PLANETA, DATA_INI, DATA_FIM) VALUES ('COMUNIDADE2', 'Libero magni', 'Quae possimus.', TO_DATE('01/01/2010', 'DD/MM/YYYY'), TO_DATE('01/01/2014', 'DD/MM/YYYY'));

select * from PLANETA P
JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
JOIN NACAO N ON D.NACAO = N.NOME
JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
JOIN FACCAO F ON NF.FACCAO = F.NOME
JOIN LIDER L ON F.LIDER = L.CPI
WHERE L.CPI = '111.111.111-15';

select * from DOMINANCIA