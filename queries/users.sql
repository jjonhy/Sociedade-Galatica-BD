CREATE TABLE Users (
    userId NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    idLider VARCHAR2(15),
    password VARCHAR2(32)
)

insert into users(idlider) select cpi from lider;

update users set password = 123;
commit;