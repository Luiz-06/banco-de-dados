/*Agora crie uma tabela chamada Empregado com os atributos
nome e salário. Crie também outra tabela chamada
Empregado_auditoria com os atributos: operação (char(1)),
usuário (varchar), data (timestamp), nome (varchar), salário
(integer) . Agora crie um trigger que registre na tabela
Empregado_auditoria a modificação que foi feita na tabela
empregado (E,A,I), quem fez a modificação, a data da
modificação, o nome do empregado que foi alterado e o salário
atual dele.*/

CREATE FUNCTION auditoria_empregado() RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO)
        VALUES ('E', CURRENT_USER, CURRENT_TIMESTAMP, NEW.NOME, NEW.SALARIO);
        RETURN NEW;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO)
        VALUES ('A', CURRENT_USER, CURRENT_TIMESTAMP, NEW.NOME, NEW.SALARIO);
        RETURN NEW;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO)
        VALUES ('I', CURRENT_USER, CURRENT_TIMESTAMP, OLD.NOME, OLD.SALARIO);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE EMPREGADO (
    NOME VARCHAR(100), 
    SALARIO, INT
);

INSERT INTO EMPREGADO(NOME, SALARIO)
VALUES ('JOAO', 1000);
INSERT INTO EMPREGADO(NOME, SALARIO)
VALUES ('ADOLFO', -1000);
INSERT INTO EMPREGADO(NOME, SALARIO)
VALUES ('CHICO COINS', 0);

CREATE TABLE EMPREGADO_AUDITORIA (
    OPERACAO CHAR(1),          
    USUARIO VARCHAR(100),       
    DATA TIMESTAMP,             
    NOME VARCHAR(100),         
    SALARIO INT                
);

CREATE TRIGGER auditoria_empregado
BEFORE INSERT OR UPDATE OR DELETE ON EMPREGADO
FOR EACH ROW
EXECUTE PROCEDURE auditoria_empregado();

INSERT INTO EMPREGADO(NOME, SALARIO)
VALUES ('MARIA', 2000);

UPDATE EMPREGADO
SET SALARIO = 1500
WHERE NOME = 'JOAO';

DELETE FROM EMPREGADO
WHERE NOME = 'ADOLFO';
