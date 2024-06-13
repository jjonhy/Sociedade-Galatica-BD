-- Comandante

-- Gerenciamento

-- a) Gerenciar (CRUD) estrelas

-- Relatorio

/*
    a. Informacoes de Estrelas, Planetas e Sistemas: o cientista esta interessado
    principalmente em catalogar corpos celestes. Assim, ele deve ter acesso a relatorios
    de estrelas, planetas e sistemas, que sirvam de apoio a atividades como possivel
    ampliacao do catalogo existente e preenchimento de valores faltantes no sistema.
*/

CREATE OR REPLACE PACKAGE PacoteCientista AS
    e_naoEncontrado EXCEPTION;
    e_dadosNulos EXCEPTION;
    e_idDuplicado EXCEPTION;
    e_coordenadasDuplicadas EXCEPTION;

    PROCEDURE cria_estrela(p_id_estrela estrela.id_estrela%type, p_x estrela.X%TYPE, p_y estrela.Y%TYPE, p_z estrela.Z%TYPE, p_nome estrela.nome%TYPE DEFAULT NULL, p_classificacao estrela.classificacao%TYPE DEFAULT NULL, p_massa estrela.massa%TYPE DEFAULT NULL);
    FUNCTION busca_estrela(p_id_estrela estrela.id_estrela%type) RETURN estrela%rowtype;
    PROCEDURE edita_estrela(p_id_estrela estrela.id_estrela%type, p_id_estrela_novo estrela.id_estrela%type, p_x estrela.X%TYPE, p_y estrela.Y%TYPE, p_z estrela.Z%TYPE, p_nome estrela.nome%TYPE, p_classificacao estrela.classificacao%TYPE, p_massa estrela.massa%TYPE);
    PROCEDURE deleta_estrela(p_id_estrela estrela.id_estrela%type);

    FUNCTION relatorio_estrela(p_limite int) RETURN SYS_REFCURSOR;
    FUNCTION relatorio_planeta(p_limite int) RETURN SYS_REFCURSOR;
    FUNCTION relatorio_sistema(p_limite int) RETURN SYS_REFCURSOR;
END PacoteCientista;
/
CREATE OR REPLACE PACKAGE BODY PacoteCientista AS
    PROCEDURE cria_estrela(p_id_estrela estrela.id_estrela%type, p_x estrela.X%TYPE, p_y estrela.Y%TYPE, p_z estrela.Z%TYPE, p_nome estrela.nome%TYPE DEFAULT NULL, p_classificacao estrela.classificacao%TYPE DEFAULT NULL, p_massa estrela.massa%TYPE DEFAULT NULL) IS
        v_count number;
        BEGIN
            IF (p_id_estrela IS NULL OR p_x IS NULL OR p_y IS NULL OR p_z IS NULL) THEN
                RAISE e_dadosNulos;
            END IF;

            SELECT COUNT(*) INTO v_count FROM ESTRELA WHERE ID_ESTRELA = p_id_estrela;
            IF v_count > 0 THEN
                RAISE e_idDuplicado;
            end if;

            SELECT COUNT(*) INTO v_count FROM ESTRELA WHERE X = p_x and Y = p_y and Z = p_z;
            IF v_count > 0 THEN
                RAISE e_coordenadasDuplicadas;
            end if;

            INSERT INTO estrela values (p_id_estrela, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);
        EXCEPTION
            WHEN e_idDuplicado THEN
                RAISE_APPLICATION_ERROR(-20003, 'Id duplicado');
            WHEN e_coordenadasDuplicadas THEN
                RAISE_APPLICATION_ERROR(-20004, 'Coordenadas duplicadas');
            WHEN e_dadosNulos THEN
                RAISE_APPLICATION_ERROR(-20005, 'Dados nulos');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');

        END cria_estrela;

    FUNCTION busca_estrela(p_id_estrela estrela.id_estrela%type)
        RETURN estrela%rowtype IS
            v_estrela_retorno estrela%rowtype;
        BEGIN
            select * into v_estrela_retorno from ESTRELA where ID_ESTRELA = p_id_estrela;
            return v_estrela_retorno;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20006, 'Nenhuma estrela encontrada');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');
        END busca_estrela;

    PROCEDURE edita_estrela(p_id_estrela estrela.id_estrela%type, p_id_estrela_novo estrela.id_estrela%type, p_x estrela.X%TYPE, p_y estrela.Y%TYPE, p_z estrela.Z%TYPE, p_nome estrela.nome%TYPE, p_classificacao estrela.classificacao%TYPE, p_massa estrela.massa%TYPE) IS
        v_count number;
        BEGIN
            IF (p_id_estrela IS NULL OR p_x IS NULL OR p_y IS NULL OR p_z IS NULL) THEN
                RAISE e_dadosNulos;
            END IF;

            SELECT COUNT(*) INTO v_count FROM ESTRELA WHERE ID_ESTRELA = p_id_estrela_novo AND ID_ESTRELA <> p_id_estrela;
            IF v_count > 0 THEN
                RAISE e_idDuplicado;
            end if;

            SELECT COUNT(*) INTO v_count FROM ESTRELA WHERE ID_ESTRELA = p_id_estrela;
            IF v_count = 0 THEN
                RAISE e_naoEncontrado;
            end if;

            SELECT COUNT(*) INTO v_count FROM ESTRELA WHERE X = p_x and Y = p_y and Z = p_z AND ID_ESTRELA <> p_id_estrela;
            IF v_count > 0 THEN
                RAISE e_coordenadasDuplicadas;
            end if;

            UPDATE ESTRELA
                SET ID_ESTRELA = p_id_estrela_novo,
                    NOME = p_nome,
                    CLASSIFICACAO = p_classificacao,
                    MASSA = p_massa,
                    X = p_x,
                    Y = p_y,
                    Z = p_z
                WHERE ID_ESTRELA = p_id_estrela;
        EXCEPTION
            WHEN e_idDuplicado THEN
                RAISE_APPLICATION_ERROR(-20003, 'Id duplicado');
            WHEN e_coordenadasDuplicadas THEN
                RAISE_APPLICATION_ERROR(-20004, 'Coordenadas duplicadas');
            WHEN e_dadosNulos THEN
                RAISE_APPLICATION_ERROR(-20005, 'Dados nulos');
            WHEN e_naoEncontrado THEN
                RAISE_APPLICATION_ERROR(-20006, 'Nenhuma estrela encontrada');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');
        END edita_estrela;

    PROCEDURE deleta_estrela(p_id_estrela estrela.id_estrela%type) IS
        BEGIN
            DELETE FROM ESTRELA WHERE ID_ESTRELA = p_id_estrela;
            IF SQL%NOTFOUND THEN
                RAISE e_naoEncontrado;
            END IF;
        EXCEPTION
            WHEN e_naoEncontrado THEN
                RAISE_APPLICATION_ERROR(-20006, 'Nenhuma estrela encontrada');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');
        END deleta_estrela;

    FUNCTION relatorio_estrela(p_limite int) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR SELECT * FROM ESTRELA FETCH FIRST p_limite ROWS ONLY;
            RETURN c_return;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');
        END relatorio_estrela;

    FUNCTION relatorio_planeta(p_limite int) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR SELECT * FROM planeta FETCH FIRST p_limite ROWS ONLY;
            RETURN c_return;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');
        END relatorio_planeta;

    FUNCTION relatorio_sistema(p_limite int) RETURN SYS_REFCURSOR IS
        c_return SYS_REFCURSOR;
        BEGIN
            OPEN c_return FOR SELECT * FROM SISTEMA FETCH FIRST p_limite ROWS ONLY;
            RETURN c_return;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');
        END relatorio_sistema;


END PacoteCientista;

/*
    b. Bonus (1.5): Eh tambem de interesse para o cientista a capacidade de analisar
    grupos de sistemas proximos e/ou densamente compactados, assim como
    informacoes como a prevalencia ou correlacao de caracteristicas especificas de
    estrelas/planetas em regioes particulares da galaxia. Em outras palavras, quando
    um cientista seleciona um sistema/estrela e um intervalo de distancias, o relatorio
    deve fornecer metricas relevantes para todos os corpos celestes nesse intervalo,
    tomando como referencia o sistema/estrela selecionado. Por exemplo: "Desejo obter
    informacoes sobre todos os corpos celestes situados a uma distancia superior a 100
    anos-luz e inferior a 200 anos-luz do Sistema Solar".
*/

 -- Nao feita

/*
    c. Bonus (1.0): Implemente uma solucao que otimize o calculo de distancias entre
    estrelas.
*/

-- Feita no Pacote Lider da Faccao



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

SELECT count(*) FROM ESTRELA;


CREATE MATERIALIZED VIEW ESTRELAS_DISTANCIAS
    BUILD IMMEDIATE
    REFRESH FORCE ON DEMAND
    AS SELECT E1.ID_ESTRELA AS Estrela1, E2.ID_ESTRELA AS Estrela2,
        Distancia_Estrela(E1.ID_ESTRELA,E2.ID_ESTRELA) AS Distance
    
    FROM ESTRELA E1 CROSS JOIN ESTRELA E2
    WHERE E1.ID_ESTRELA < E2.ID_ESTRELA;
-- Ok
-- 3444 segundos para criar


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

explain plan for
SELECT * FROM ESTRELAS_DISTANCIAS WHERE Estrela1 = '1' AND Estrela2 = '9';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
