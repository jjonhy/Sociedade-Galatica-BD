CREATE OR REPLACE PACKAGE PacoteLider AS
    e_naoPermitido EXCEPTION;
    e_naoEncontrado EXCEPTION;

    PROCEDURE alterar_nome_faccao(p_lider lider.cpi%TYPE, p_novo_nome faccao.nome%TYPE);
    PROCEDURE indicar_novo_lider_faccao(p_lider_atual lider.cpi%TYPE, p_lider_novo lider.cpi%TYPE);
    PROCEDURE credenciar_comunidades(p_lider lider.cpi%TYPE);
    PROCEDURE remove_faccao_da_nacao(p_nacao nacao_faccao.nacao%TYPE, p_faccao nacao_faccao.faccao%TYPE, p_lider lider.cpi%TYPE);
    FUNCTION comunidades_faccao(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR;
    FUNCTION comunidades_faccao_por_nacao(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR;
    FUNCTION comunidades_faccao_por_especie(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR;
    FUNCTION comunidades_faccao_por_planeta(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR;
    FUNCTION comunidades_faccao_por_sistema(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR;
END PacoteLider;
/
CREATE OR REPLACE PACKAGE BODY PacoteLider AS
    PROCEDURE alterar_nome_faccao(p_lider lider.cpi%TYPE, p_novo_nome faccao.nome%TYPE) AS
        v_nomefaccao FACCAO.nome%type;
        v_num_faccao_nova number;

        v_nacoes sys_refcursor;
        v_comunidades sys_refcursor;

        v_nacao_nome nacao_faccao.nacao%type;
        v_comunidade_nome PARTICIPA.COMUNIDADE%type;
        v_especie PARTICIPA.ESPECIE%type;
        BEGIN
            SELECT nome
            INTO v_nomefaccao
            FROM faccao
            WHERE lider = p_lider;

            SELECT COUNT(*)
            INTO v_num_faccao_nova
            FROM faccao
            WHERE nome = p_novo_nome;

            IF (v_num_faccao_nova > 0) THEN
                RAISE e_naoPermitido;
            END IF;

            SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

                OPEN v_nacoes FOR
                    SELECT NACAO
                    FROM NACAO_FACCAO
                    WHERE FACCAO = v_nomefaccao;

                OPEN v_comunidades FOR
                    SELECT COMUNIDADE, ESPECIE
                    FROM PARTICIPA
                    WHERE FACCAO = v_nomefaccao;

                DELETE
                FROM NACAO_FACCAO
                WHERE FACCAO = v_nomefaccao;

                DELETE
                FROM PARTICIPA
                WHERE FACCAO = v_nomefaccao;

                UPDATE faccao SET nome = p_novo_nome WHERE lider = p_lider;

                LOOP FETCH v_nacoes INTO v_nacao_nome;
                    EXIT WHEN v_nacoes%NOTFOUND;
                    INSERT INTO NACAO_FACCAO(NACAO, FACCAO) VALUES (v_nacao_nome, p_novo_nome);
                END LOOP;

                LOOP FETCH v_comunidades INTO v_comunidade_nome, v_especie;
                    EXIT WHEN v_comunidades%NOTFOUND;
                    INSERT INTO PARTICIPA(COMUNIDADE, ESPECIE, FACCAO) VALUES (v_comunidade_nome, v_especie, p_novo_nome);
                END LOOP;

                CLOSE v_nacoes;
                CLOSE v_comunidades;

            COMMIT;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002, 'Lider nao possui faccao');
            WHEN e_naoEncontrado THEN RAISE_APPLICATION_ERROR(-20001, 'Faccao nao associada a lider');
            WHEN E_NAOPERMITIDO THEN RAISE_APPLICATION_ERROR(-20003, 'Ja existe uma faccao com esse nome');
        END alterar_nome_faccao;

    PROCEDURE remove_faccao_da_nacao(p_nacao nacao_faccao.nacao%TYPE, p_faccao nacao_faccao.faccao%TYPE, p_lider lider.cpi%TYPE) AS
        v_ehLiderFaccao number;
        BEGIN
            SELECT COUNT(*)
            INTO v_ehLiderFaccao
            FROM faccao
            WHERE nome = p_faccao AND lider = p_lider;

            IF (v_ehLiderFaccao = 0) THEN
                RAISE e_naoPermitido;
            END IF;

            DELETE FROM nacao_faccao WHERE nacao = p_nacao AND faccao = p_faccao;
            IF SQL%NOTFOUND THEN
                RAISE e_naoEncontrado;
            END IF;

        EXCEPTION
            WHEN e_naoEncontrado THEN RAISE_APPLICATION_ERROR(-20001, 'Faccao nao associada a nacao');
            WHEN e_naoPermitido THEN RAISE_APPLICATION_ERROR(-20002, 'Lider nao eh lider da faccao');
    END remove_faccao_da_nacao;

    PROCEDURE indicar_novo_lider_faccao(p_lider_atual lider.cpi%TYPE, p_lider_novo lider.cpi%TYPE) AS
        v_ehLiderFaccao number;
        BEGIN
            SELECT COUNT(*)
            INTO v_ehLiderFaccao
            FROM faccao
            WHERE lider = p_lider_atual;

            IF (v_ehLiderFaccao = 0) THEN
                RAISE e_naoPermitido;
            END IF;

            UPDATE faccao SET lider = p_lider_novo WHERE lider = p_lider_atual;
            IF SQL%NOTFOUND THEN
                RAISE e_naoEncontrado;
            END IF;

        EXCEPTION
            WHEN e_naoEncontrado THEN RAISE_APPLICATION_ERROR(-20001, 'Faccao nao associada a lider');
            WHEN e_naoPermitido THEN RAISE_APPLICATION_ERROR(-20002, 'Lider nao eh lider da faccao');
    END indicar_novo_lider_faccao;

    PROCEDURE credenciar_comunidades(p_lider lider.cpi%TYPE) AS
        BEGIN
            INSERT INTO PARTICIPA (COMUNIDADE, ESPECIE, FACCAO)
            SELECT C.NOME, C.ESPECIE, F.NOME
            FROM COMUNIDADE C
            JOIN HABITACAO H ON C.NOME = H.COMUNIDADE AND C.ESPECIE = H.ESPECIE
            JOIN PLANETA P ON H.PLANETA = P.ID_ASTRO
            JOIN DOMINANCIA D ON P.ID_ASTRO = D.PLANETA
            JOIN NACAO N ON D.NACAO = N.NOME
            JOIN NACAO_FACCAO NF ON N.NOME = NF.NACAO
            JOIN FACCAO F ON NF.FACCAO = F.NOME
            LEFT JOIN PARTICIPA P2 ON C.NOME = P2.COMUNIDADE AND C.ESPECIE = P2.ESPECIE AND F.NOME = P2.FACCAO
            WHERE F.LIDER = p_lider AND P2.COMUNIDADE IS NULL AND P2.ESPECIE IS NULL AND P2.FACCAO IS NULL;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001, 'Erro ao credenciar comunidades');
    END credenciar_comunidades;

    FUNCTION comunidades_faccao(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT C.NOME AS COMUNIDADE, C.ESPECIE, C.QTD_HABITANTES, P2.ID_ASTRO AS PLANETA, d.NACAO, S.NOME SISTEMA
                FROM COMUNIDADE C
                JOIN PARTICIPA P ON P.COMUNIDADE = C.NOME AND P.ESPECIE = C.ESPECIE
                JOIN FACCAO F ON F.NOME = P.FACCAO
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE
                LEFT JOIN PLANETA P2 on H.PLANETA = P2.ID_ASTRO
                LEFT JOIN DOMINANCIA D on P2.ID_ASTRO = D.PLANETA
                LEFT JOIN ORBITA_PLANETA OP on P2.ID_ASTRO = OP.PLANETA
                LEFT JOIN ESTRELA E on OP.ESTRELA = E.ID_ESTRELA
                LEFT JOIN SISTEMA S on E.ID_ESTRELA = S.ESTRELA
                WHERE H.DATA_FIM IS NULL AND F.LIDER = p_lider;
            RETURN c_return;
    END comunidades_faccao;

    FUNCTION comunidades_faccao_por_sistema(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT S.NOME SISTEMA, COUNT(DISTINCT C.NOME || C.ESPECIE) QTD_COMUNIDADES, SUM(C.QTD_HABITANTES) QTD_HABITANTES
                FROM COMUNIDADE C
                JOIN PARTICIPA P ON P.COMUNIDADE = C.NOME AND P.ESPECIE = C.ESPECIE
                JOIN FACCAO F ON F.NOME = P.FACCAO
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE
                LEFT JOIN PLANETA P2 on H.PLANETA = P2.ID_ASTRO
                LEFT JOIN DOMINANCIA D on P2.ID_ASTRO = D.PLANETA
                LEFT JOIN ORBITA_PLANETA OP on P2.ID_ASTRO = OP.PLANETA
                LEFT JOIN ESTRELA E on OP.ESTRELA = E.ID_ESTRELA
                LEFT JOIN SISTEMA S on E.ID_ESTRELA = S.ESTRELA
                WHERE H.DATA_FIM IS NULL AND F.LIDER = p_lider
                GROUP BY S.NOME;
            RETURN c_return;
    END comunidades_faccao_por_sistema;

    FUNCTION comunidades_faccao_por_especie(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT C.ESPECIE, COUNT(DISTINCT C.NOME || C.ESPECIE), SUM(C.QTD_HABITANTES)
                FROM COMUNIDADE C
                JOIN PARTICIPA P ON P.COMUNIDADE = C.NOME AND P.ESPECIE = C.ESPECIE
                JOIN FACCAO F ON F.NOME = P.FACCAO
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE
                LEFT JOIN PLANETA P2 on H.PLANETA = P2.ID_ASTRO
                LEFT JOIN DOMINANCIA D on P2.ID_ASTRO = D.PLANETA
                LEFT JOIN ORBITA_PLANETA OP on P2.ID_ASTRO = OP.PLANETA
                LEFT JOIN ESTRELA E on OP.ESTRELA = E.ID_ESTRELA
                LEFT JOIN SISTEMA S on E.ID_ESTRELA = S.ESTRELA
                WHERE H.DATA_FIM IS NULL AND F.LIDER = p_lider
                GROUP BY C.ESPECIE;
            RETURN c_return;
    END comunidades_faccao_por_especie;

    FUNCTION comunidades_faccao_por_planeta(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT P2.ID_ASTRO, COUNT(DISTINCT C.NOME || C.ESPECIE), SUM(C.QTD_HABITANTES)
                FROM COMUNIDADE C
                JOIN PARTICIPA P ON P.COMUNIDADE = C.NOME AND P.ESPECIE = C.ESPECIE
                JOIN FACCAO F ON F.NOME = P.FACCAO
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE
                LEFT JOIN PLANETA P2 on H.PLANETA = P2.ID_ASTRO
                LEFT JOIN DOMINANCIA D on P2.ID_ASTRO = D.PLANETA
                LEFT JOIN ORBITA_PLANETA OP on P2.ID_ASTRO = OP.PLANETA
                LEFT JOIN ESTRELA E on OP.ESTRELA = E.ID_ESTRELA
                LEFT JOIN SISTEMA S on E.ID_ESTRELA = S.ESTRELA
                WHERE H.DATA_FIM IS NULL AND F.LIDER = p_lider
                GROUP BY P2.ID_ASTRO;
            RETURN c_return;
    END comunidades_faccao_por_planeta;

    FUNCTION comunidades_faccao_por_nacao(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR
                SELECT D.NACAO, COUNT(DISTINCT C.NOME || C.ESPECIE), SUM(C.QTD_HABITANTES)
                FROM COMUNIDADE C
                JOIN PARTICIPA P ON P.COMUNIDADE = C.NOME AND P.ESPECIE = C.ESPECIE
                JOIN FACCAO F ON F.NOME = P.FACCAO
                left join HABITACAO H on C.ESPECIE = H.ESPECIE and C.NOME = H.COMUNIDADE
                LEFT JOIN PLANETA P2 on H.PLANETA = P2.ID_ASTRO
                LEFT JOIN DOMINANCIA D on P2.ID_ASTRO = D.PLANETA
                LEFT JOIN ORBITA_PLANETA OP on P2.ID_ASTRO = OP.PLANETA
                LEFT JOIN ESTRELA E on OP.ESTRELA = E.ID_ESTRELA
                LEFT JOIN SISTEMA S on E.ID_ESTRELA = S.ESTRELA
                WHERE H.DATA_FIM IS NULL AND F.LIDER = p_lider
                GROUP BY D.NACAO;
            RETURN c_return;
    END comunidades_faccao_por_nacao;
END PacoteLider;


select * from COMUNIDADE;
select * from lider;
select * from faccao;

SELECT * FROM COMUNIDADE C
                JOIN PARTICIPA P ON P.COMUNIDADE = C.NOME AND P.ESPECIE = C.ESPECIE
                JOIN FACCAO F ON F.NOME = P.FACCAO
                WHERE F.LIDER = '123.123.123-12';

DECLARE
    p_lider lider.cpi%TYPE := '123.123.123-12';
    p_novo_nome faccao.nome%TYPE := 'FACCAO1 NOVo';
BEGIN
    PacoteLider.alterar_nome_faccao(p_lider, p_novo_nome);
END;

SELECT * FROM FACCAO WHERE NOME = 'FACCAO1 NOVo';
select * from NACAO_FACCAO WHERE FACCAO = 'FACCAO1 NOVo';
select * from PARTICIPA WHERE FACCAO = 'FACCAO1 NOVo';


select * from lider;
select * from faccao right join A11796472.LIDER L on L.CPI = faccao.LIDER;
-- insert into LIDER values ('111.111.111-15', 'LIDER 15', 'OFICIAL', 'Magni error.','Libero magni');

-- Test for indicar_novo_lider_faccao procedure
DECLARE
    p_lider_atual lider.cpi%TYPE := '123.123.123-12';
    p_lider_novo lider.cpi%TYPE := '111.111.111-15';
BEGIN
    PacoteLider.indicar_novo_lider_faccao(p_lider_atual, p_lider_novo);
END;
SELECT * FROM FACCAO WHERE LIDER = '111.111.111-15';
SELECT * FROM FACCAO WHERE LIDER = '123.123.123-12';


DECLARE
    p_lider lider.cpi%TYPE := '123.123.123-12';
BEGIN
    PacoteLider.credenciar_comunidades(p_lider);
END;

update HABITACAO set DATA_FIM = null where COMUNIDADE = 'COMUNIDADE3';

select * from COMUNIDADE;
select * from PARTICIPA;

DECLARE
    p_lider lider.cpi%TYPE := '111.111.111-15';
    l_cursor SYS_REFCURSOR;
    v_comunidade COMUNIDADE.nome%type;
    v_especie COMUNIDADE.especie%type;
    v_qtd_habitantes COMUNIDADE.qtd_habitantes%type;
    v_planeta PLANETA.id_astro%type;
    v_nacao DOMINANCIA.nacao%type;
    v_sistema SISTEMA.nome%type;
BEGIN
    l_cursor := PacoteLider.comunidades_faccao(p_lider);

    LOOP FETCH l_cursor INTO v_comunidade, v_especie, v_qtd_habitantes, v_planeta, v_nacao, v_sistema;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_comunidade || ', ' || v_especie || ', ' || v_qtd_habitantes || ', ' || v_planeta || ', ' || v_nacao || ', ' || v_sistema);
    END LOOP;
END;

-- Test for comunidades_faccao_por_sistema function
DECLARE
    p_lider lider.cpi%TYPE := '111.111.111-15';
    l_cursor SYS_REFCURSOR;
    v_sistema SISTEMA.nome%type;
    v_qtd_comunidades number;
    v_qtd_habitantes number;
BEGIN
    l_cursor := PacoteLider.comunidades_faccao_por_sistema(p_lider);

    LOOP FETCH l_cursor INTO v_sistema, v_qtd_comunidades, v_qtd_habitantes;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_sistema || v_qtd_comunidades || v_qtd_habitantes);
    END LOOP;
END;

-- Test for comunidades_faccao_por_especie function
DECLARE
    p_lider lider.cpi%TYPE := '111.111.111-15';
    l_cursor SYS_REFCURSOR;
    v_especie COMUNIDADE.especie%type;
    v_qtd_comunidades number;
    v_qtd_habitantes number;
BEGIN
    l_cursor := PacoteLider.comunidades_faccao_por_especie(p_lider);

    LOOP FETCH l_cursor INTO v_especie, v_qtd_comunidades, v_qtd_habitantes;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_especie || v_qtd_comunidades || v_qtd_habitantes);
    END LOOP;
END;

-- Test for comunidades_faccao_por_planeta function
DECLARE
    p_lider lider.cpi%TYPE := '111.111.111-15';
    l_cursor SYS_REFCURSOR;
    v_planeta PLANETA.id_astro%type;
    v_qtd_comunidades number;
    v_qtd_habitantes number;
BEGIN
    l_cursor := PacoteLider.comunidades_faccao_por_planeta(p_lider);

    LOOP FETCH l_cursor INTO v_planeta, v_qtd_comunidades, v_qtd_habitantes;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_planeta || v_qtd_comunidades || v_qtd_habitantes);
    END LOOP;
END;

-- Test for comunidades_faccao_por_nacao function
DECLARE
    p_lider lider.cpi%TYPE := '111.111.111-15';
    l_cursor SYS_REFCURSOR;
    v_nacao DOMINANCIA.nacao%type;
    v_qtd_comunidades number;
    v_qtd_habitantes number;
BEGIN
    l_cursor := PacoteLider.comunidades_faccao_por_nacao(p_lider);

    LOOP FETCH l_cursor INTO v_nacao, v_qtd_comunidades, v_qtd_habitantes;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_nacao || v_qtd_comunidades || v_qtd_habitantes);
    END LOOP;
END;