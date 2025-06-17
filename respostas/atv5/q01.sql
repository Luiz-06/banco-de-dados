-- Tabela de Apartamentos
CREATE TABLE Apartamento (
    num_apt INT PRIMARY KEY,
    status VARCHAR(20) NOT NULL
);

-- Tabela de Hóspedes
CREATE TABLE Hospede (
    cod_hosp INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    idade INT NOT NULL
);

-- Tabela de Hospedagens
CREATE TABLE Hospedagem (
    cod_hospedagem SERIAL PRIMARY KEY,
    cod_hosp INT REFERENCES Hospede(cod_hosp),
    num_apt INT REFERENCES Apartamento(num_apt),
    data_ent DATE NOT NULL,
    data_sai DATE
);

CREATE VIEW NOME_IDADE
as SELECT H.nome, H.idade FROM Hospede AS H

SELECT * FROM NOME_IDADE

