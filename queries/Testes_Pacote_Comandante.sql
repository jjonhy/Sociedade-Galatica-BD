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
incluir_federacao_na_nacao ('123.456.789-10','federal');
END;

select * from nacao where nacao.federacao = 'federal';
-- OK

-- excluir_federacao_da_nacao

select * from nacao where nacao.federacao = 'federal';

BEGIN
excluir_federacao_da_nacao ('123.456.789-10');
END;
-- OK

select * from nacao where nacao.federacao = 'federal';
-- OK

BEGIN
excluir_federacao_da_nacao ('123.456.789-10');
END;
-- OK

-- criar_federacao

BEGIN
criar_federacao ('123.456.789-10','piramide');
END;
-- OK

select * from nacao where nacao.federacao = 'piramide';
-- ok

select * from federacao where federacao.nome = 'piramide';

BEGIN
excluir_federacao_da_nacao ('123.456.789-10');
END;
-- ok

select * from federacao where federacao.nome = 'piramide';
-- ainda existe

BEGIN
criar_federacao ('123.456.789-10','ponte',TO_DATE('2000-01-01', 'yyyy-mm-dd'));
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
insere_dominancia('123.456.789-10','dominado');
END;
-- OK

select * from dominancia;
-- OK

BEGIN
insere_dominancia('123.456.789-10','brasil');
END;
-- OK

BEGIN
insere_dominancia('111.456.789-10','brasil');
END;
-- OK

-- FIM Testes