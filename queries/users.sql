CREATE TABLE Users (
    userId NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    idLider VARCHAR2(15),
    password VARCHAR2(32)
)

-- Executar para adicionar os lideres a tabela de usuarios e colocar senha padrão: 123

insert into users(idlider) select cpi from lider;

update users set password = 123;
commit;

select * from users;

-- fim da execucao

ALTER TABLE Users ADD CONSTRAINT pk_users PRIMARY KEY (userId);
ALTER TABLE Users ADD CONSTRAINT uq_idLider UNIQUE (idLider);

CREATE TABLE LOG_TABLE (
    logId NUMBER GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    userId VARCHAR2(15),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message VARCHAR2(255),
    CONSTRAINT pk_log_table PRIMARY KEY (logId),
    CONSTRAINT fk_user FOREIGN KEY (userId) REFERENCES Users(idLider)
);