SET SERVEROUTPUT ON; -- Testes e Debugs

-- Teste:

-- Delete_Nacao_Federacao



-- Insira caso inexistente
INSERT INTO	FEDERACAO VALUES('MIMI', TO_DATE('2024-03-04', 'yyyy-mm-dd'));
INSERT INTO	FEDERACAO VALUES('NINI', TO_DATE('2030-01-19', 'yyyy-mm-dd'));

INSERT INTO	NACAO VALUES('OI', 10, 'MIMI');
INSERT INTO	NACAO VALUES('TCHAU', 100, 'NINI');

DELETE FROM NACAO WHERE NACAO.NOME = 'OI';

/*
Error starting at line : 79 in command -
DELETE FROM NACAO WHERE NACAO.NOME = 'OI'
Error at Command Line : 79 Column : 13
Error report -
SQL Error: ORA-20015: Nao ha como detelar esta nacao pois ela eh a unica associada a uma nacao.
ORA-06512: at "A11796382.DELETE_NACAO_FEDERACAO", line 35
ORA-04088: error during execution of trigger 'A11796382.DELETE_NACAO_FEDERACAO'
*/

select nacao.nome FROM NACAO WHERE NACAO.NOME = 'OI';

UPDATE NACAO
    SET NACAO.FEDERACAO = 'NINI'
    WHERE NACAO.NOME = 'OI';

/*
Error starting at line : 93 in command -
UPDATE NACAO
    SET NACAO.FEDERACAO = 'NINI'
    WHERE NACAO.NOME = 'OI'
Error at Command Line : 93 Column : 8
Error report -
SQL Error: ORA-20015: Nao ha como detelar esta nacao pois ela eh a unica associada a uma nacao.
ORA-06512: at "A11796382.DELETE_NACAO_FEDERACAO", line 35
ORA-04088: error during execution of trigger 'A11796382.DELETE_NACAO_FEDERACAO'
*/
    
select nacao.nome FROM NACAO WHERE NACAO.NOME = 'OI';


-- Teste:

-- Insert_NacaoFaccao_After_Faccao

-- Update_Lider_Faccao

-- Update_Lider_Nacao



INSERT INTO	ESTRELA	VALUES('1', 'sol', 'estrelinha', 1, 20, 1, -4);
INSERT INTO	ESTRELA	VALUES('9', 'outro sol', 'solzao', 40, -199, 0, 0);

INSERT INTO	SISTEMA	VALUES('1', 'sistema solar');
INSERT INTO	SISTEMA	VALUES('9', null);

INSERT INTO	PLANETA	VALUES('terra', 2, 4000, 'planeta');
INSERT INTO	PLANETA	VALUES('marte', 18, 3000, 'marte');

INSERT INTO	ORBITA_ESTRELA VALUES('1', '9', 2000, 4000, 1);
INSERT INTO	ORBITA_ESTRELA VALUES('9', '1', 100, 1000, 20);

INSERT INTO	ORBITA_PLANETA VALUES('terra', '1', 900, 1000, 1);
INSERT INTO	ORBITA_PLANETA VALUES('marte', '1', 1200, 1500, 2);
INSERT INTO	ORBITA_PLANETA VALUES('terra', '9', 900, 1400, 3);

INSERT INTO	FEDERACAO VALUES('terraqueos', TO_DATE('2024-03-04', 'yyyy-mm-dd'));
INSERT INTO	FEDERACAO VALUES('marcianos', TO_DATE('2030-01-19', 'yyyy-mm-dd'));

INSERT INTO	NACAO VALUES('brasil', 10, 'terraqueos');
INSERT INTO	NACAO VALUES('imperio', 100, 'marcianos');

INSERT INTO	DOMINANCIA VALUES('terra','brasil', TO_DATE('2000-01-01', 'yyyy-mm-dd'), null);
INSERT INTO	DOMINANCIA VALUES('terra','imperio', TO_DATE('2001-03-04', 'yyyy-mm-dd'), TO_DATE('2030-03-04', 'yyyy-mm-dd'));

INSERT INTO	ESPECIE VALUES('humano', 'terra', 'F');
INSERT INTO	ESPECIE VALUES('humano2', 'marte', 'V');
INSERT INTO	ESPECIE VALUES('humano3', 'marte', 'F');
INSERT INTO	ESPECIE VALUES('pokemon', 'marte', 'V');
INSERT INTO	ESPECIE VALUES('pokemon2', 'marte', 'V');
INSERT INTO ESPECIE VALUES('dinossauro' , 'terra', 'F');

INSERT INTO	LIDER VALUES('123.100.111-20', 'darth vader', 'COMANDANTE', 'imperio', 'humano');
INSERT INTO	LIDER VALUES('999.945.678-12', 'lula', 'OFICIAL', 'brasil', 'pokemon');

INSERT INTO	FACCAO VALUES('imperio', '123.100.111-20', 'TOTALITARIA', 30);
INSERT INTO	FACCAO VALUES('brasilia', '999.945.678-12', 'PROGRESSITA', 1);

INSERT INTO	NACAO_FACCAO VALUES('brasil', 'imperio');
INSERT INTO	NACAO_FACCAO VALUES('imperio', 'brasilia');

-- Inserindo nova faccao:

INSERT INTO	LIDER VALUES('123.100.111-22', 'dart', 'COMANDANTE', 'imperio', 'humano');

SELECT * FROM LIDER WHERE LIDER.CPI = '123.100.111-22';

INSERT INTO	FACCAO VALUES('parte', '123.100.111-22', 'TOTALITARIA', 30);

SELECT * FROM nacao_faccao WHERE nacao_faccao.faccao = 'parte';

-- Resultado no select: imperio	parte

-- Editando a nacao do lider:

UPDATE LIDER
    SET LIDER.NACAO = 'brasil'
    WHERE LIDER.CPI = '123.100.111-22';
    
/*
Error starting at line : 227 in command -
UPDATE LIDER
    SET LIDER.NACAO = 'brasil'
    WHERE LIDER.CPI = '123.100.111-22'
Error at Command Line : 227 Column : 8
Error report -
SQL Error: ORA-20017: Nao ha como mudar a nacao do lider, pois nao faz parte da faccao do mesmo.
ORA-06512: at "A11796382.UPDATE_LIDER_NACAO", line 16
ORA-04088: error during execution of trigger 'A11796382.UPDATE_LIDER_NACAO'
*/

-- Update lider da faccao:

UPDATE FACCAO
    SET FACCAO.LIDER = '999.945.678-12'
    WHERE FACCAO.NOME = 'parte';
    
/*
Error starting at line : 267 in command -
UPDATE FACCAO
    SET FACCAO.LIDER = '999.945.678-12'
    WHERE FACCAO.NOME = 'parte'
Error at Command Line : 267 Column : 8
Error report -
SQL Error: ORA-20017: Nao ha como mudar a nacao do lider, pois nao faz parte da faccao do mesmo.
ORA-06512: at "A11796382.UPDATE_LIDER_FACCAO", line 14
ORA-04088: error during execution of trigger 'A11796382.UPDATE_LIDER_FACCAO'
*/


-- Teste:

-- Insert_Faccao_QtdNacoes

-- Update_Faccao_Qtd_Nacoes

-- Delete_Faccao_Qtd_Nacoes



-- Insert:

SELECT * FROM FACCAO WHERE faccao.nome = 'parte';

-- parte	123.100.111-22	TOTALITARIA	30

INSERT INTO	NACAO_FACCAO VALUES('brasil', 'parte');

SELECT * FROM FACCAO WHERE faccao.nome = 'parte';

-- parte	123.100.111-22	TOTALITARIA	31

-- Update:

UPDATE NACAO_FACCAO
    SET NACAO_FACCAO.FACCAO = 'brasilia'
    WHERE NACAO_FACCAO.NACAO = 'brasil'  AND NACAO_FACCAO.FACCAO = 'parte';

SELECT * FROM FACCAO WHERE faccao.nome = 'brasilia';

-- brasilia	999.945.678-12	PROGRESSITA	2

SELECT * FROM FACCAO WHERE faccao.nome = 'parte';

-- parte	123.100.111-22	TOTALITARIA	30

-- Delete:

INSERT INTO	NACAO VALUES('Claro', 10, 'terraqueos');

INSERT INTO	NACAO_FACCAO VALUES('Claro', 'parte');

SELECT * FROM FACCAO WHERE faccao.nome = 'parte';

-- parte	123.100.111-22	TOTALITARIA	31

Delete from NACAO where NACAO.NOME = 'Claro';

SELECT * FROM FACCAO WHERE faccao.nome = 'parte';

-- parte	123.100.111-22	TOTALITARIA	30


-- Teste:

-- Insert_Nacao_Qtd_Planetas

-- Update_Nacao_Qtd_Planetas

-- Delete_Nacao_Qtd_Planetas



-- Insert:

SELECT * FROM nacao WHERE nacao.nome = 'brasil';
-- brasil	10	terraqueos

INSERT INTO	DOMINANCIA VALUES('marte','brasil', TO_DATE('2000-01-01', 'yyyy-mm-dd'), null);

SELECT * FROM nacao WHERE nacao.nome = 'brasil';
-- brasil	11	terraqueos

-- Delete:

UPDATE nacao
    SET nacao.qtd_planetas = 11
    where nacao.nome = 'brasil';

delete from dominancia where dominancia.planeta = 'marte' and dominancia.nacao = 'brasil';

SELECT * FROM nacao WHERE nacao.nome = 'brasil';

-- brasil	10	terraqueos

-- Update:

INSERT INTO	DOMINANCIA VALUES('marte','brasil', TO_DATE('2000-01-01', 'yyyy-mm-dd'), null);

SELECT * FROM nacao WHERE nacao.nome = 'brasil';

SELECT * FROM DOMINANCIA;

-- brasil	11	terraqueos

UPDATE DOMINANCIA
    SET DOMINANCIA.DATA_FIM = TO_DATE('2000-02-02', 'yyyy-mm-dd')
    where DOMINANCIA.planeta = 'marte' and DOMINANCIA.nacao = 'brasil';

SELECT * FROM nacao WHERE nacao.nome = 'brasil';

-- TO_DATE('2000-01-01', 'yyyy-mm-dd')

-- Teste:

-- Insert_Verify_Dates_Dominancia

select * from dominancia;

INSERT INTO	DOMINANCIA VALUES('terra', 'imperio', TO_DATE('1800-01-01', 'yyyy-mm-dd'), TO_DATE('1850-01-01', 'yyyy-mm-dd'));
-- Ok

INSERT INTO	DOMINANCIA VALUES('terra', 'imperio', TO_DATE('1800-01-01', 'yyyy-mm-dd'), TO_DATE('1850-01-01', 'yyyy-mm-dd'));
/*
    Erro de SQL: ORA-20201: Ja existe uma dominancia desse planeta entre essas datas.
    ORA-06512: em "A11796382.INSERT_VERIFY_DATES_DOMINANCIA", line 27
    ORA-04088: erro durante a execução do gatilho 'A11796382.INSERT_VERIFY_DATES_DOMINANCIA'
*/

INSERT INTO	DOMINANCIA VALUES('terra', 'imperio', TO_DATE('1810-01-01', 'yyyy-mm-dd'), TO_DATE('1840-01-01', 'yyyy-mm-dd'));
-- Erro de SQL: ORA-20201

INSERT INTO	DOMINANCIA VALUES('terra', 'imperio', TO_DATE('1810-01-01', 'yyyy-mm-dd'), TO_DATE('1890-01-01', 'yyyy-mm-dd'));
-- Erro de SQL: ORA-20201

INSERT INTO	DOMINANCIA VALUES('terra', 'imperio', TO_DATE('1890-01-01', 'yyyy-mm-dd'), TO_DATE('1895-01-01', 'yyyy-mm-dd'));
-- Ok

select * from dominancia;

INSERT INTO	DOMINANCIA VALUES('marte', 'imperio', TO_DATE('1900-01-01', 'yyyy-mm-dd'), TO_DATE('2000-01-01', 'yyyy-mm-dd'));
-- ok

INSERT INTO	DOMINANCIA VALUES('marte', 'imperio', TO_DATE('1850-01-01', 'yyyy-mm-dd'), NULL);
-- Erro de SQL: ORA-20201

-- Teste:

-- Insert_Verify_Dates_Habitacao

-- Mesmo codigo, ou seja, mesmos testes

-- Teste:

-- Dominancia_Date_Less_Sysdate

INSERT INTO	DOMINANCIA VALUES('marte', 'imperio', TO_DATE('2500-01-01', 'yyyy-mm-dd'), NULL);
/*
Erro de SQL: ORA-20210: Datas precisam ser menores ou iguais a data atual. Nao pode haver datas futuras
ORA-06512: em "A11796382.DOMINANCIA_DATE_LESS_SYSDATE", line 13
ORA-04088: erro durante a execução do gatilho 'A11796382.DOMINANCIA_DATE_LESS_SYSDATE'
*/

INSERT INTO	DOMINANCIA VALUES('marte', 'imperio', TO_DATE('2010-01-01', 'yyyy-mm-dd'), TO_DATE('2025-01-01', 'yyyy-mm-dd'));
-- Erro de SQL: ORA-20210

-- Habitacao_Date_Less_Sysdate 

-- Mesmos testes, mesmo codigo

-- Teste:

-- Add_Estrela_To_Sistema

INSERT INTO	ESTRELA	VALUES('000', 'ioio', 'branca', 10000, 2, 10, 0);
-- Ok

select * from SISTEMA where SISTEMA.ESTRELA='000';
-- 000	000
-- Ok