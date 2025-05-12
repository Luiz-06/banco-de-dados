/* Primeiro crie uma tabela chamada Funcionário com os
seguintes campos: código (int), nome (varchar(30)), salário
(int), data_última_atualização (timestamp),
usuário_que_atualizou (varchar(30)). Na inserção desta
tabela, você deve informar apenas o código, nome e salário do
funcionário. Agora crie um Trigger que não permita o nome
nulo, a salário nulo e nem negativo. Faça testes que
comprovem o funcionamento do Trigger. */

CREATE FUNCTION validarFuncionario() RETURNS TRIGGER AS
$$
    BEGIN 
    IF NEW.NOME IS NULL 
    OR NEW.SALARIO IS NULL
    OR NEW.SALARIO < 0 
    THEN
        RAISE EXCEPTION 'Nome ou salario invalido';
    END IF; 
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TABLE FUNCIONARIO
(CODIGO SERIAL PRIMARY KEY, NOME VARCHAR(100), SALARIO INT);

CREATE TRIGGER VALIDATE_FUNC
BEFORE INSERT OR UPDATE ON FUNCIONARIO
FOR EACH ROW 
EXECUTE PROCEDURE validarFuncionario();

INSERT INTO FUNCIONARIO(NOME, SALARIO)
VALUES('JOAO', NULL);
INSERT INTO FUNCIONARIO(NOME, SALARIO)
VALUES('MARIA', 1600);
INSERT INTO FUNCIONARIO(NOME, SALARIO)
VALUES('ANA', -2);