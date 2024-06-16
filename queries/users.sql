CREATE TABLE Users (
    userId NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    idLider char(15),
    password char(32)
)

insert into users(idlider) select cpi from lider;

update users set password = 123;
commit;