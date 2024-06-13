-- Triggers para garantir as consistencias estipuladas na descricao do projeto

-- 1) Uma federação soh pode existir se estiver associada a pelo menos 1 nacao

/*
    Considerando a consistencia dada, temos que nao podemos inserir uma federacao nova a nao ser que ela
    esteja associada a uma nacao. Entretanto, como a nacao tem chave estrangeira para federacao, nao podemos
    inserir ou atualizar a nacao com o valor nome-fd de federacao sem que a nacao exista. Para isso, podemos
    fazer, a nivel de aplicacao, com que o usuario, ao inserir uma nova federacao, insira tambem o nome de uma
    nacao, para que, na mesma transacao, a federacao seja inserida e logo apos uma nacao seja atualizada ou criada
    com o nome da nacao dado e com a federacao associada. Ou seja, nao e possovel resolver apenas com trigger.
    Nisso, nao sera feito um trigger para insert pois nao daria para inserir novas federacoes.
    Entao, havera apenas um trigger para delete e update.
*/

CREATE OR REPLACE TRIGGER Delete_Nacao_Federacao
    FOR DELETE OR UPDATE OF FEDERACAO ON NACAO
    COMPOUND TRIGGER

    deleteException EXCEPTION;
    TYPE feder IS TABLE OF INT INDEX BY VARCHAR2(15);
    
    V_FEDER feder;
    
    BEFORE STATEMENT IS
    BEGIN
        FOR NAC IN(
        SELECT NACAO.FEDERACAO, COUNT(*) AS QUANT
            FROM NACAO
            WHERE NACAO.FEDERACAO IS NOT NULL
            GROUP BY NACAO.FEDERACAO) LOOP
            V_FEDER(NAC.federacao) :=  NAC.QUANT;
        END LOOP;
    
    END BEFORE STATEMENT;
    
    AFTER EACH ROW IS
    
    BEGIN
        IF :old.FEDERACAO IS NOT NULL THEN
            IF :NEW.FEDERACAO IS NOT NULL THEN
               V_FEDER(:NEW.FEDERACAO) := V_FEDER(:NEW.FEDERACAO) + 1;
            END IF;
            V_FEDER(:old.FEDERACAO) := V_FEDER(:old.FEDERACAO) - 1;
            IF V_FEDER(:old.FEDERACAO) <= 0 THEN
                RAISE deleteException;
            END IF;
        ELSE
            IF :NEW.FEDERACAO IS NOT NULL THEN
                V_FEDER(:NEW.FEDERACAO) := 1;
            END IF;
        END IF;
    
        EXCEPTION
            WHEN deleteException THEN
                DBMS_OUTPUT.put_line('Nao ha como detelar/editar esta nacao pois ela eh a unica associada a uma nacao');
                RAISE_APPLICATION_ERROR(-20015,'Nao ha como detelar/editar esta nacao pois ela eh a unica associada a uma nacao.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
    END AFTER EACH ROW;
END Delete_Nacao_Federacao;


-- 2) O lider de uma faccao deve estar associado a uma naccao em que a faccao está presente.

/*
    Como a Faccao soh ira existir se houver um lider associado por chave estrageira, entao eh necessario que ja 
    exista um lider associado obrigatoriamente a uma nacao, fazendo com que essa nacao tambem ja exista. Ou seja,
    quando criarmos uma Faccao nova, precisamos inserir na tabela NacaoFaccao a faccao associada a nacao do seu lider.
    Caso contrario, teremos outros problemas de incosistencia que n�o seram resolvidos utilizando somente triggers.
*/

CREATE OR REPLACE TRIGGER Insert_NacaoFaccao_After_Faccao
    AFTER INSERT ON FACCAO
    FOR EACH ROW
    
    DECLARE
        v_nacao LIDER.NACAO%TYPE;
    
    BEGIN
    
        SELECT LIDER.NACAO INTO v_nacao FROM LIDER WHERE LIDER.CPI = :NEW.LIDER;
    
        INSERT INTO	NACAO_FACCAO VALUES(v_nacao,:NEW.NOME);
        DBMS_OUTPUT.put_line('Inserido nacao faccao!');
    
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
END Insert_NacaoFaccao_After_Faccao;

CREATE OR REPLACE TRIGGER Update_Lider_Faccao
    AFTER UPDATE OF LIDER ON FACCAO
    FOR EACH ROW
    
    DECLARE
        v_nacao LIDER.NACAO%TYPE;
    
    BEGIN
    
        SELECT LIDER.NACAO INTO v_nacao FROM LIDER WHERE LIDER.CPI = :NEW.LIDER;
    
        SELECT NACAO_FACCAO.NACAO INTO v_nacao FROM NACAO_FACCAO
            WHERE NACAO_FACCAO.FACCAO = :NEW.NOME AND NACAO_FACCAO.NACAO = v_nacao;
    
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.put_line('Nao ha como colocar este lider, pois ele pertence a uma na��o que n�o est� na fac��o');
                RAISE_APPLICATION_ERROR(-20017,'Nao ha como mudar a nacao do lider, pois nao faz parte da faccao do mesmo.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
END Update_Lider_Faccao;

CREATE OR REPLACE TRIGGER Update_Lider_Nacao
    AFTER UPDATE OF NACAO ON LIDER
    FOR EACH ROW
    
    DECLARE
        v_faccao FACCAO.NOME%TYPE;
        Update_Lider_Nacao_Exception EXCEPTION;
    
    BEGIN
    
        SELECT FACCAO.NOME INTO v_faccao FROM FACCAO WHERE FACCAO.LIDER = :OLD.CPI;
    
        SELECT NACAO_FACCAO.FACCAO INTO v_faccao FROM NACAO_FACCAO
            WHERE NACAO_FACCAO.FACCAO = v_faccao AND NACAO_FACCAO.NACAO = :NEW.NACAO;

    
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.put_line('Nao ha como mudar a nacao do lider, pois nao faz parte da faccao do mesmo.');
                RAISE_APPLICATION_ERROR(-20017,'Nao ha como mudar a nacao do lider, pois nao faz parte da faccao do mesmo.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
END Update_Lider_Nacao;


-- 3) A quantidade de nacoes, na tabela Faccao dever estar sempre atualizada.

-- Devemos abordar os casos de insert (quando uma nacao eh associada a uma faccao), o update
-- (quando eh colocada outra faccao com a mesma nacao, retirando a quantia da faccao antiga
-- e colocando na nova - nao sendo necessario abordar o caso de que a nacao eh atualizada,
-- pois a quantidade nao vai ser alterar) e o delete (onde nacao eh desassociada da faccao, 
-- diminuindo a contagem). Os codigos foram feitos separados pois apresentam comportamentos
-- e utilizacao de identificadores diferentes.

CREATE OR REPLACE TRIGGER Insert_Faccao_QtdNacoes
    AFTER INSERT ON NACAO_FACCAO
    FOR EACH ROW
    
    BEGIN
    
        UPDATE FACCAO
            SET QTD_NACOES = QTD_NACOES + 1
            WHERE FACCAO.NOME = :NEW.FACCAO;
    
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
    
END Insert_Faccao_QtdNacoes;

CREATE OR REPLACE TRIGGER Update_Faccao_Qtd_Nacoes
    AFTER UPDATE ON NACAO_FACCAO
    FOR EACH ROW
    
    DECLARE
    
    BEGIN
    
        IF :NEW.NACAO = :OLD.NACAO THEN
            UPDATE FACCAO
                SET QTD_NACOES = QTD_NACOES - 1
                WHERE FACCAO.NOME = :OLD.FACCAO;
        
            UPDATE FACCAO
                SET QTD_NACOES = QTD_NACOES + 1
                WHERE FACCAO.NOME = :NEW.FACCAO;
        END IF;
    
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
END Update_Faccao_Qtd_Nacoes;

CREATE OR REPLACE TRIGGER Delete_Faccao_Qtd_Nacoes
    AFTER DELETE ON NACAO_FACCAO
    FOR EACH ROW
    
    BEGIN
    
        UPDATE FACCAO
            SET QTD_NACOES = QTD_NACOES - 1
            WHERE FACCAO.NOME = :OLD.FACCAO;
    
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
END Delete_Faccao_Qtd_Nacoes;


-- 4) Na tabela Nacao, o atributo qtd_planetas deve considerar somente dominancias atuais.

/*
    Como no nosso banco iremos considerar apenas a insercao de datas-ini com data presente (sys-date)
    ou passada, e data-fim nula, presente ou passada (na qual nula indicara que a dominancia eh presente),
    dominancias atuais sao aquelas que possuem se e somente se data-fim = null.
    Os codigos foram feitos separados pois apresentam comportamentos e utilizacao de identificadores
    diferentes.
*/

CREATE OR REPLACE TRIGGER Insert_Nacao_Qtd_Planetas
    AFTER INSERT ON DOMINANCIA
    FOR EACH ROW
    
    BEGIN
    
        IF :NEW.DATA_FIM IS NULL THEN
            UPDATE NACAO
                SET NACAO.QTD_PLANETAS = NACAO.QTD_PLANETAS + 1
                WHERE NACAO.NOME = :NEW.NACAO;
        END IF;
    
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
END Insert_Nacao_Qtd_Planetas;

CREATE OR REPLACE TRIGGER Update_Nacao_Qtd_Planetas
    AFTER UPDATE ON DOMINANCIA
    FOR EACH ROW
    
    BEGIN
    
        IF :OLD.DATA_FIM IS NULL AND :NEW.DATA_FIM IS NOT NULL THEN
            UPDATE NACAO
                SET NACAO.QTD_PLANETAS = NACAO.QTD_PLANETAS - 1
                WHERE NACAO.NOME = :OLD.NACAO;
        
        ELSIF :OLD.NACAO <> :OLD.NACAO THEN
            UPDATE NACAO
                SET NACAO.QTD_PLANETAS = NACAO.QTD_PLANETAS + 1
                WHERE NACAO.NOME = :NEW.NACAO;
                
            UPDATE NACAO
                SET NACAO.QTD_PLANETAS = NACAO.QTD_PLANETAS - 1
                WHERE NACAO.NOME = :OLD.NACAO;
        END IF;
        
    
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
END Update_Nacao_Qtd_Planetas;

CREATE OR REPLACE TRIGGER Delete_Nacao_Qtd_Planetas
    AFTER DELETE ON DOMINANCIA
    FOR EACH ROW
    
    BEGIN
    
        IF :OLD.DATA_FIM IS NULL THEN
            UPDATE NACAO
                SET NACAO.QTD_PLANETAS = NACAO.QTD_PLANETAS - 1
                WHERE NACAO.NOME = :OLD.nacao;
        END IF;
    
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
                RAISE_APPLICATION_ERROR(-20016,'Erro: ' || SQLERRM);
    
END Delete_Nacao_Qtd_Planetas;

