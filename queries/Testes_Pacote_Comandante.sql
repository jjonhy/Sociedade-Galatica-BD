-- Testes:

set serveroutput on; -- Para testes e debugs

-- incluir_federacao_na_nacao

INSERT INTO NACAO VALUES('castelo',4,null);

INSERT INTO LIDER VALUES('123.456.789-10','Chefe','COMANDANTE','castelo','humano');

INSERT INTO FEDERACAO VALUES('federal',SYSDATE);

-- select * from federacao;

select * from federacao where federacao.nome = 'federal';

select * from nacao where nacao.federacao = 'federal';

BEGIN
PacoteComandante.incluir_federacao_na_nacao ('123.456.789-10','federal');
END;

select * from nacao where nacao.federacao = 'federal';
-- OK

-- excluir_federacao_da_nacao

select * from nacao where nacao.federacao = 'federal';

BEGIN
PacoteComandante.excluir_federacao_da_nacao ('123.456.789-10');
END;
-- OK

select * from nacao where nacao.federacao = 'federal';
-- OK

BEGIN
PacoteComandante.excluir_federacao_da_nacao ('123.456.789-10');
END;
-- OK

-- criar_federacao

BEGIN
PacoteComandante.criar_federacao ('123.456.789-10','piramide');
END;
-- OK

select * from nacao where nacao.federacao = 'piramide';
-- ok

select * from federacao where federacao.nome = 'piramide';

BEGIN
PacoteComandante.excluir_federacao_da_nacao ('123.456.789-10');
END;
-- ok

select * from federacao where federacao.nome = 'piramide';
-- ainda existe

BEGIN
PacoteComandante.criar_federacao ('123.456.789-10','ponte','01/01/2001');
END;
-- ok

select * from federacao where federacao.nome = 'ponte';
-- ok

select * from nacao where nacao.federacao = 'ponte';

-- insere_dominancia

INSERT INTO PLANETA VALUES('dominado',1,1,'ok');
-- ok

select * from dominancia;

BEGIN
PacoteComandante.insere_dominancia('123.456.789-10','dominado');
END;
-- OK

select * from dominancia;
-- OK

BEGIN
PacoteComandante.insere_dominancia('123.456.789-10','brasil');
END;
-- OK

BEGIN
PacoteComandante.insere_dominancia('111.456.789-10','brasil');
END;
-- OK

-- planetas_em_potencial

select * from dominancia;

select * from lider;

select * from
    faccao join
    lider
    on faccao.lider = lider.cpi;

select * from sistema JOIN ORBITA_PLANETA ON SISTEMA.ESTRELA = ORBITA_PLANETA.ESTRELA;

INSERT INTO PLANETA VALUES('PODE_DOMINAR',1,1,'SIM');

INSERT INTO	ORBITA_PLANETA VALUES('PODE_DOMINAR', 1, 900, 1000, 10);

INSERT INTO	DOMINANCIA VALUES('marte', 'brasil', TO_DATE('2011-02-01', 'yyyy-mm-dd'), TO_DATE('2011-02-02', 'yyyy-mm-dd'));

SELECT * FROM ORBITA_ESTRELA;

-- FIM Testes