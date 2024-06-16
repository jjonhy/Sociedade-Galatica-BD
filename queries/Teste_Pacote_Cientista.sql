-- Testes

-- teste create

DECLARE
    p_id_estrela estrela.id_estrela%type := '2345690230933332';
    p_X estrela.X%TYPE := 8;
    p_Y estrela.Y%TYPE := 9;
    p_Z estrela.Z%TYPE := 100;
    p_NOME estrela.NOME%TYPE := 'estrela0';
    p_CLASSIFICACAO estrela.CLASSIFICACAO%TYPE := 'super';
    p_MASSA estrela.MASSA%TYPE := '9999';
BEGIN
    PacoteCientista.cria_estrela(p_id_estrela, p_x, p_y, p_z, p_nome, p_classificacao, p_massa);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
end;

-- teste read

SELECT * FROM ESTRELA WHERE ID_ESTRELA = 'GJ 9798';

DECLARE
    l_cursor SYS_REFCURSOR;
    v_id_estrela ESTRELA.id_estrela%TYPE;
    v_nome ESTRELA.nome%TYPE;
    v_classificacao ESTRELA.classificacao%TYPE;
    v_massa ESTRELA.massa%TYPE;
    v_x ESTRELA.x%TYPE;
    v_y ESTRELA.y%TYPE;
    v_z ESTRELA.z%TYPE;
BEGIN
    l_cursor := PacoteCientista.busca_estrela('GJ 9798');

    LOOP FETCH l_cursor INTO v_id_estrela, v_nome, v_classificacao, v_massa, v_x, v_y, v_z;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_id_estrela || ' ' || v_nome || ' ' || v_classificacao || ' ' || v_massa || ' ' || v_x || ' ' || v_y || ' ' || v_z);
    END LOOP;
    close l_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
end;

-- teste update

SELECT * FROM ESTRELA WHERE ID_ESTRELA = '2345690230933332';

DECLARE
    p_id_estrela estrela.id_estrela%type := '2345690230933332';
    p_id_estrela_novo estrela.id_estrela%type := '2345690230933332';
    p_X estrela.X%TYPE := 77;
    p_Y estrela.Y%TYPE := 90;
    p_Z estrela.Z%TYPE := 55;
    p_NOME estrela.NOME%TYPE := 'estrela0';
    p_CLASSIFICACAO estrela.CLASSIFICACAO%TYPE := 'super';
    p_MASSA estrela.MASSA%TYPE := '9999';
BEGIN
    PacoteCientista.edita_estrela(p_id_estrela, p_id_estrela_novo, p_x, p_y, p_z, p_nome, p_classificacao, p_massa);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
end;

-- teste delete

SELECT * FROM ESTRELA WHERE ID_ESTRELA = '2345690230933332';

DECLARE
BEGIN
    PacoteCientista.deleta_estrela('2345690230933332');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Erro: ' || SQLERRM);
end;

-- teste relatorios

select * from PLANETA;
DECLARE
    l_cursor SYS_REFCURSOR;

    v_id_astro PLANETA.id_astro%type;
    v_massa PLANETA.massa%type;
    v_raio PLANETA.raio%type;
    v_classificacao PLANETA.classificacao%type;
BEGIN
    l_cursor := PacoteCientista.relatorio_planeta(10);

    LOOP FETCH l_cursor INTO v_id_astro, v_massa, v_raio, v_classificacao;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_id_astro || ' ' || v_massa || ' ' || v_raio || ' ' || v_classificacao);
    END LOOP;

    CLOSE l_cursor;
END;

select * from ESTRELA;
DECLARE
    l_cursor SYS_REFCURSOR;

    v_id_estrela ESTRELA.id_estrela%TYPE;
    v_nome ESTRELA.nome%TYPE;
    v_classificacao ESTRELA.classificacao%TYPE;
    v_massa ESTRELA.massa%TYPE;
    v_x ESTRELA.x%TYPE;
    v_y ESTRELA.y%TYPE;
    v_z ESTRELA.z%TYPE;
BEGIN
    l_cursor := PacoteCientista.relatorio_estrela(10);

    LOOP FETCH l_cursor INTO v_id_estrela, v_nome, v_classificacao, v_massa, v_x, v_y, v_z;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_id_estrela || ' ' || v_nome || ' ' || v_classificacao || ' ' || v_massa || ' ' || v_x || ' ' || v_y || ' ' || v_z);
    END LOOP;

    CLOSE l_cursor;
END;

DECLARE
    l_cursor SYS_REFCURSOR;

    v_estrela SISTEMA.estrela%type;
    v_nome SISTEMA.nome%type;
BEGIN
    l_cursor := PacoteCientista.RELATORIO_SISTEMA(10);

    LOOP FETCH l_cursor INTO v_estrela, v_nome;
        EXIT WHEN l_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_estrela || ' ' || v_nome);
    END LOOP;

    CLOSE l_cursor;
END;