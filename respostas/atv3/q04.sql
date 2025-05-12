/*Crie a tabela Empregado2 com os atributos código (serial e
chave primária), nome (varchar) e salário (integer). Crie
também a tabela Empregado2_audit com os seguintes
atributos: usuário (varchar), data (timestamp), id (integer),
coluna (text), valor_antigo (text), valor_novo(text). Agora crie
um trigger que não permita a alteração da chave primária e
insira registros na tabela Empregado2_audit para refletir as
alterações realizadas na tabela Empregado2*/

CREATE FUNCTION auditoria_empregado() RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO EMPREGADO_AUDITORIA2 
        (USUARIO, DATA, ID, SALARIO_ANT, SALARIO_NOVO)
        VALUES (CURRENT_USER, CURRENT_TIMESTAMP, NEW.ID_EMP, NULL, NEW.SALARIO);
        RETURN NEW;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO EMPREGADO_AUDITORIA2 
        (USUARIO, DATA, ID, SALARIO_ANT, SALARIO_NOVO)
        VALUES (CURRENT_USER, CURRENT_TIMESTAMP, NEW.ID_EMP, OLD.SALARIO, NEW.SALARIO);
        RETURN NEW;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        INSERT INTO EMPREGADO_AUDITORIA2 
        (USUARIO, DATA, ID, SALARIO_ANT, SALARIO_NOVO)
        VALUES (CURRENT_USER, CURRENT_TIMESTAMP, OLD.ID_EMP,OLD.SALARIO, NULL);
        RETURN OLD;
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION nao_trocar_pk() RETURN TRIGGER AS
$$
BEGIN
    IF NEW.ID_EMP <> OLD.ID_EMP THEN
        RAISE EXCEPTION 'Não é permitido alterar a chave primária';
    END IF;
    RETURN NEW;
END; 
$$ LANGUAGE plpgsql;

CREATE TABLE EMPREGADO2 (
    ID_EMP SERIAL PRIMARY KEY,
    NOME VARCHAR(100), 
    SALARIO INT
);

CREATE TABLE EMPREGADO_AUDITORIA2 (        
    USUARIO VARCHAR(100),       
    DATA TIMESTAMP,             
    ID INT,    
    SALARIO_ANT INT,
    SALARIO_NOVO INT                
);

CREATE TRIGGER auditoria_empregado2
BEFORE INSERT OR UPDATE OR DELETE ON EMPREGADO2
FOR EACH ROW
EXECUTE PROCEDURE auditoria_empregado();

CREATE TRIGGER NAO_PODE_TROCAR 
BEFORE UPDATE ON EMPREGADO2
FOR EACH ROW 
EXECUTE PROCEDURE nao_trocar_pk()
