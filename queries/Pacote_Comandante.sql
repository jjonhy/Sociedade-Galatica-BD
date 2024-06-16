-- Comandante

CREATE OR REPLACE PACKAGE PacoteComandante AS

    TYPE t_informacoes_1 IS RECORD (
        PLANETAS PLANETA.ID_ASTRO%TYPE,
        QUANTIDADE_COMUNIDADES NUMBER,
        QUANTIDADE_ESPECIES NUMBER,
        QUANTIDADE_HABITANTES NUMBER,
        QUANTIDADE_ORIGEM NUMBER,
        QUANTIDADE_FACCOES NUMBER,
        FACCAO_MAJORITARIA FACCAO.NOME%TYPE
    );
    
    type T_INFORMACOES_1_TYPE IS TABLE OF t_informacoes_1;

    TYPE t_informacoes_2 IS RECORD (
        PLANETAS PLANETA.ID_ASTRO%TYPE,
        NACOES_DOMINANTES NACAO.NOME%TYPE,
        DATA_INI_ULTIMA_DOMINACAO DOMINANCIA.DATA_INI%TYPE,
        DATA_FIM_ULTIMA_DOMINACAO DOMINANCIA.DATA_FIM%TYPE
    );

    type T_INFORMACOES_2_TYPE IS TABLE OF t_informacoes_2;

    e_naoPermitido EXCEPTION;
    e_naoEncontrado EXCEPTION;

    PROCEDURE incluir_federacao_na_nacao(p_cpi LIDER.CPI%TYPE, p_nome_fd FEDERACAO.NOME%TYPE);
    PROCEDURE excluir_federacao_da_nacao(p_cpi LIDER.CPI%TYPE);
    PROCEDURE criar_federacao (p_cpi LIDER.CPI%TYPE, p_nome_fd FEDERACAO.NOME%TYPE, p_data_fund FEDERACAO.DATA_FUND%TYPE DEFAULT SYSDATE);
    PROCEDURE insere_dominancia(p_cpi LIDER.CPI%TYPE,p_planeta DOMINANCIA.PLANETA%TYPE,p_data_ini DOMINANCIA.DATA_INI%TYPE DEFAULT SYSDATE);
    

END PacoteComandante;
/
CREATE OR REPLACE PACKAGE BODY PacoteComandante AS
    -- Gerenciamento
    
    -- a) Pode alterar aspectos da propria nacao:
    
    -- i) Incluir/excluir a propria nacao de uma federacao existente

    PROCEDURE incluir_federacao_na_nacao (
            p_cpi LIDER.CPI%TYPE,
            p_nome_fd FEDERACAO.NOME%TYPE
        ) IS
    
        v_nacao NACAO.NOME%TYPE;
        v_federacao NACAO.FEDERACAO%TYPE;
    
        federacao_existente EXCEPTION;
    
    BEGIN
        SELECT LIDER.NACAO INTO v_nacao FROM LIDER
            WHERE LIDER.CPI = p_cpi;
    
        BEGIN
            SELECT NACAO.FEDERACAO INTO v_federacao FROM NACAO
                WHERE NACAO.NOME = v_nacao;
            EXCEPTION
                WHEN NO_DATA_FOUND
                    THEN v_federacao:= NULL;
        END;
        -- Exception: A nacao ja possui uma federacao atual
        IF v_federacao IS NOT NULL THEN
            RAISE federacao_existente;
        END IF;
    
         SELECT NACAO.FEDERACAO INTO v_federacao FROM NACAO
            WHERE NACAO.NOME = v_nacao;
    
        UPDATE NACAO SET NACAO.FEDERACAO=p_nome_fd
            WHERE nome=v_nacao;
    
        EXCEPTION
            WHEN federacao_existente
                THEN RAISE_APPLICATION_ERROR(-20101, 'Nacao ja possui uma federacao associada. Exclua primeira a federacao atual.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');

    END incluir_federacao_na_nacao;
    
    PROCEDURE excluir_federacao_da_nacao (
            p_cpi LIDER.CPI%TYPE
        ) IS
    
        v_nacao NACAO.NOME%TYPE;
        v_federacao NACAO.FEDERACAO%TYPE;
    
        federacao_inexistente EXCEPTION;
    
    BEGIN
        SELECT LIDER.NACAO INTO v_nacao FROM LIDER
            WHERE LIDER.CPI = p_cpi;
    
        BEGIN
            SELECT NACAO.FEDERACAO INTO v_federacao FROM NACAO
                WHERE NACAO.NOME = v_nacao;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_federacao := NULL;
        END;
    
        IF v_federacao IS NULL THEN
            RAISE federacao_inexistente;
        END IF;
    
        UPDATE NACAO SET NACAO.FEDERACAO=NULL
            WHERE nome=v_nacao;
    
        EXCEPTION
            WHEN federacao_inexistente
                THEN RAISE_APPLICATION_ERROR(-20102, 'Nao ha nenhuma federacao relacionada a nacao do comandante.');
    
    END excluir_federacao_da_nacao;
    
    -- ii) Criar nova federacao, com a propria nacao
    
    PROCEDURE criar_federacao (
            p_cpi LIDER.CPI%TYPE,
            p_nome_fd FEDERACAO.NOME%TYPE,
            p_data_fund FEDERACAO.DATA_FUND%TYPE DEFAULT SYSDATE
        ) IS
    
        v_nacao NACAO.NOME%TYPE;
        v_federacao NACAO.FEDERACAO%TYPE;
    
        federacao_existente EXCEPTION;
    
    BEGIN
        SELECT LIDER.NACAO INTO v_nacao FROM LIDER
            WHERE LIDER.CPI = p_cpi;
    
        SELECT NACAO.FEDERACAO INTO v_federacao FROM NACAO
            WHERE NACAO.NOME = v_nacao;
        
        BEGIN
            SELECT NACAO.FEDERACAO INTO v_federacao FROM NACAO
                WHERE NACAO.NOME = v_nacao;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_federacao := NULL;
        END;
    
        IF v_federacao IS NOT NULL THEN
            RAISE federacao_existente;
        END IF;
    
        INSERT INTO FEDERACAO VALUES(p_nome_fd, p_data_fund);
    
        UPDATE NACAO SET NACAO.FEDERACAO=p_nome_fd
            WHERE nome=v_nacao;
    
        EXCEPTION
            WHEN federacao_existente
                THEN RAISE_APPLICATION_ERROR(-20103, 'Nacao ja possui uma federacao associada.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');

    END criar_federacao;
    
    -- b) Insere nova dominancia de um planeta que nao esta sendo dominado por ninguem
    
    PROCEDURE insere_dominancia(
            p_cpi LIDER.CPI%TYPE,
            p_planeta DOMINANCIA.PLANETA%TYPE,
            p_data_ini DOMINANCIA.DATA_INI%TYPE DEFAULT SYSDATE
        ) IS
        
        v_nacao DOMINANCIA.NACAO%TYPE;
        v_planeta DOMINANCIA.PLANETA%TYPE;
        
        planeta_ja_dominado EXCEPTION;
        parent_key_not_found EXCEPTION;
        
        PRAGMA EXCEPTION_INIT(parent_key_not_found, -2291);
        
    BEGIN
        SELECT LIDER.NACAO INTO v_nacao FROM LIDER
            WHERE LIDER.CPI = p_cpi;
    
        BEGIN
            SELECT DOMINANCIA.PLANETA INTO v_planeta FROM DOMINANCIA
                WHERE DOMINANCIA.PLANETA = p_planeta AND DOMINANCIA.DATA_FIM IS NULL;
            
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_planeta := NULL;
                WHEN TOO_MANY_ROWS THEN
                    v_planeta := 'planeta';
        END;
        
        IF v_planeta IS NOT NULL THEN
            RAISE planeta_ja_dominado;
        END IF;
        
        INSERT INTO DOMINANCIA VALUES(p_planeta,v_nacao,p_data_ini,NULL);
        
        EXCEPTION
            WHEN NO_DATA_FOUND
                THEN RAISE_APPLICATION_ERROR(-20104, 'Lider nao encontrado.');
            WHEN planeta_ja_dominado
                THEN RAISE_APPLICATION_ERROR(-20105, 'Planeta ja esta sendo dominado por uma nacao.');
            WHEN parent_key_not_found
                THEN RAISE_APPLICATION_ERROR(-20106, 'Planeta nao encontrado.');
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');

    END insere_dominancia;
    
    -- Relatorio
    
    /*
        a. Informacoes de planetas dominados por todas as nacoes: um comandante esta
        interessado em informacoes de domonio tanto de sua quanto de outras nacoes.
        Sendo assim, comandantes tem acesso a relatorios sobre planetas dominados e de
        potencial dominacao, contendo para cada planeta informacoes como: nacao
        dominante (se houver), datas de inicio e fim da ultima dominacao, quantidades de
        comunidades, especies, habitantes, e faccoes presentes, faccao majoritaria (se
        houver), entre outros.
    */
    
    /*
        i. Informacoes estrategicas importantes (a ser definido pelo grupo) devem estar
        disponiveis apenas para comandantes de suas respectivas nacoes, sendo
        ocultadas para demais comandantes na geracao do relatorio.
    */
    
    -- TODO: ainda nao ha validacao dessa parte pela API
    
    PROCEDURE consulta_informacoes_estrategicas (
            p_informacoes_est1 OUT T_INFORMACOES_1_TYPE,
            p_informacoes_est2 OUT T_INFORMACOES_2_TYPE
        ) IS
        

    BEGIN
    
        WITH QTD_ESPECIES_ORIGIN_PLANETA AS (
            SELECT PLANETA_OR, COUNT(*) AS QTD
            FROM ESPECIE
            GROUP BY PLANETA_OR
        )
        
        SELECT PLANETA.ID_ASTRO,
            COUNT(DISTINCT COMUNIDADE.ESPECIE || COMUNIDADE.NOME),
            COUNT(DISTINCT COMUNIDADE.ESPECIE),
            COALESCE(SUM(COMUNIDADE.QTD_HABITANTES),0),
            COALESCE(MIN(E.QTD),0),
            COUNT(DISTINCT PARTICIPA.FACCAO),
            STATS_MODE(PARTICIPA.FACCAO) 
        
        BULK COLLECT INTO p_informacoes_est1
            
            FROM PLANETA
            LEFT JOIN HABITACAO 
                ON PLANETA.ID_ASTRO = HABITACAO.PLANETA
                LEFT JOIN COMUNIDADE
                    ON HABITACAO.ESPECIE = COMUNIDADE.ESPECIE
                    AND HABITACAO.COMUNIDADE = COMUNIDADE.NOME
                    AND HABITACAO.DATA_FIM IS NULL
                    LEFT JOIN PARTICIPA
                        ON PARTICIPA.ESPECIE = COMUNIDADE.ESPECIE
                        AND PARTICIPA.COMUNIDADE = COMUNIDADE.NOME
            
            LEFT JOIN QTD_ESPECIES_ORIGIN_PLANETA E 
                ON PLANETA.ID_ASTRO = E.PLANETA_OR
            WHERE (PLANETA.ID_ASTRO = 'terra' OR PLANETA.ID_ASTRO = 'marte') -- DADOS TESTES: descomente o WHERE para testar
            
        GROUP BY PLANETA.ID_ASTRO
        ORDER BY PLANETA.ID_ASTRO;
        

        SELECT PLANETA.ID_ASTRO,
            DOMINANCIA.NACAO,
            DOMINANCIA.DATA_INI,
            DOMINANCIA.DATA_FIM
            
        BULK COLLECT INTO p_informacoes_est2
            
            FROM PLANETA
                LEFT JOIN DOMINANCIA
                ON PLANETA.ID_ASTRO = DOMINANCIA.PLANETA
                AND DOMINANCIA.DATA_FIM IS NULL
            WHERE (PLANETA.ID_ASTRO = 'terra' OR PLANETA.ID_ASTRO = 'marte') -- DADOS TESTES: descomente o WHERE para testar
        
        ORDER BY PLANETA.ID_ASTRO;
        
        -- Para testes (probably deprecated):
        -- FOR i IN 1..LEAST(cardinality(p_informacoes_est1.PLANETAS), 20) LOOP -- Imprime os 20 primeiros ou a quantidade de planetas encontrados (caso a quantidade seja menor que 20)
            
        --     DBMS_OUTPUT.PUT_LINE (
        --         'Planeta: ' ||p_informacoes_est1(i).PLANETAS || CHR(13) || CHR(10)
        --         || '    Dominancia Atual: ' ||p_informacoes_est2(i).NACOES_DOMINANTES || CHR(13) || CHR(10)
        --         || '    Data Inicial: ' ||p_informacoes_est2(i).DATA_INI_ULTIMA_DOMINACAO||' Data Final: ' ||p_informacoes_est2(i).DATA_FIM_ULTIMA_DOMINACAO || CHR(13) || CHR(10)
        --         || '    Quantidade de:' || CHR(13) || CHR(10)
        --         || '        Comunidades: '||p_informacoes_est1(i).QUANTIDADE_COMUNIDADES|| ', Especies: ' ||p_informacoes_est1(i).QUANTIDADE_ESPECIES|| ', Habitantes: ' ||T_INFORMACOES_EST(i).QUANTIDADE_HABITANTES
        --         || ', Faccoes: ' ||p_informacoes_est1(i).QUANTIDADE_FACCOES|| ', Especies Originaria: ' ||p_informacoes_est1(i).QUANTIDADE_ORIGEM || CHR(13) || CHR(10)
        --         || '    Faccao Majoritaria: ' ||p_informacoes_est1(i).FACCAO_MAJORITARIA
        --     );
        -- END LOOP;

        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000, 'Erro desconhecido');
    END;
    
    /*
        ii. No mesmo relatorio, comandantes devem poder ter acesso a informacoes
        sobre planetas com potencial de expansao de sua nacao, i.e., planetas nao
        -errantes que nao estao sendo dominados por outra nacao. Esses planetas
        com potencial de dominacao podem pertencer a um sistema em que a nacao
        ja esta presente, ou a um sistema vizinho/proximo em que a nacao nao esta
        presente . Podem ser adicionados, por exemplo, filtros de distancia para
        encontrar planetas em sistemas proximos ao territorio da nacao (obs: o
        territorio de uma nacao eh o conjunto de sistemas onde existem planetas
        dominados por ela) A Figura 1 ilustra o territorio da Nacao X e as distancias
        dos sistemas das estrelas Sirius e Barnand's Star. Dica: pode-se utilizar a
        distancia Euclideana.
    */
    
    FUNCTION planetas_em_potencial(p_lider lider.cpi%TYPE) RETURN SYS_REFCURSOR IS
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
    END planetas_em_potencial;
        
    END PacoteComandante;
/



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    







