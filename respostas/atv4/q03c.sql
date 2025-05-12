/*Crie um trigger que sempre que houver inserções, remoções ou alterações
na tabela "item_pedido", haja a atualização da "quant_itens_pedidos"
e do "valor_total_pedido" da tabela "pedido", bem como a quantidade de estoqu na tabela Livro*/

CREATE FUNCTION controlador() RETURNS TRIGGER AS
$$
    BEGIN
        IF TG_OP = 'INSERT' THEN
            UPDATE PEDIDO 
            SET VALOR_TOTAL_PEDIDO = 
                (
                    SELECT SUM(IP.QTD_ITENS * L.VALOR_LIVRO) FROM
                    ITEM_PEDIDO AS IP 
                    JOIN LIVRO AS L ON IP.COD_LIVRO = L.COD_LIVRO
                    WHERE IP.COD_PEDIDO = NEW.COD_PEDIDO
                ),
                QUANT_ITENS_PEDIDOS = (
                    SELECT SUM(IP.QTD_ITENS) FROM
                    ITEM_PEDIDO AS IP
                    WHERE IP.COD_PEDIDO = NEW.COD_PEDIDO
                )
            WHERE COD_PEDIDO = NEW.COD_PEDIDO;

            UPDATE LIVRO 
            SET QTD_ESTOQUE = QTD_ESTOQUE-NEW.QTD_ITENS
            WHERE LIVRO.COD_LIVRO = NEW.COD_LIVRO;

        ELSIF TG_OP = 'UPDATE' THEN
            UPDATE PEDIDO 
            SET VALOR_TOTAL_PEDIDO = 
                (
                    SELECT SUM(IP.QTD_ITENS * L.VALOR_LIVRO) FROM
                    ITEM_PEDIDO AS IP 
                    JOIN LIVRO AS L ON IP.COD_LIVRO = L.COD_LIVRO
                    WHERE IP.COD_PEDIDO = NEW.COD_PEDIDO
                ),
                QUANT_ITENS_PEDIDOS = (
                    SELECT SUM(IP.QTD_ITENS) FROM
                    ITEM_PEDIDO AS IP
                    WHERE IP.COD_PEDIDO = NEW.COD_PEDIDO
                )
            WHERE COD_PEDIDO = NEW.COD_PEDIDO;

            UPDATE LIVRO
            SET QTD_ESTOQUE = QTD_ESTOQUE + OLD.QTD_ITENS
            WHERE LIVRO.COD_LIVRO = OLD.COD_LIVRO;

            UPDATE LIVRO 
            SET QTD_ESTOQUE = QTD_ESTOQUE - NEW.QTD_ITENS
            WHERE LIVRO.COD_LIVRO = NEW.COD_LIVRO;

        ELSIF TG_OP = 'DELETE' THEN 
            UPDATE PEDIDO 
            SET 
                VALOR_TOTAL_PEDIDO = (
                    SELECT COALESCE(SUM(IP.QTD_ITENS * L.VALOR_LIVRO), 0)
                    FROM ITEM_PEDIDO AS IP 
                    JOIN LIVRO AS L ON IP.COD_LIVRO = L.COD_LIVRO
                    WHERE IP.COD_PEDIDO = OLD.COD_PEDIDO
                ),
                QUANT_ITENS_PEDIDOS = (
                    SELECT COALESCE(SUM(IP.QTD_ITENS), 0)
                    FROM ITEM_PEDIDO AS IP
                    WHERE IP.COD_PEDIDO = OLD.COD_PEDIDO
                )
            WHERE COD_PEDIDO = OLD.COD_PEDIDO;

            UPDATE LIVRO
            SET QTD_ESTOQUE = QTD_ESTOQUE + OLD.QTD_ITENS
            WHERE COD_LIVRO = OLD.COD_LIVRO;
        END IF;

    END;
$$ LANGUAGE plpgsql;

CREATE TABLE TITULO (
    COD_TITULO SERIAL PRIMARY KEY, 
    NOME_TITULO VARCHAR(100), 
    DESC_TITULO VARCHAR(100)
);

CREATE TABLE LIVRO (
    COD_LIVRO SERIAL PRIMARY KEY, 
    COD_TITULO INT, 
    VALOR_LIVRO INT,
    QTD_ESTOQUE INT,
    FOREIGN KEY (COD_TITULO) REFERENCES TITULO(COD_TITULO)
);

CREATE TABLE FORNECEDOR (
    COD_FORNECEDOR SERIAL PRIMARY KEY, 
    NOME_FORNECEDOR VARCHAR(100),
    FONE_FORNECEDOR VARCHAR(100)
);

CREATE TABLE PEDIDO (
    COD_PEDIDO SERIAL PRIMARY KEY, 
    COD_FORNECEDOR INT, 
    HORA_PEDIDO TIME,
    DATA_PEDIDO DATE,
    VALOR_TOTAL_PEDIDO INT,
    QUANT_ITENS_PEDIDOS INT,
    FOREIGN KEY (COD_FORNECEDOR) REFERENCES FORNECEDOR(COD_FORNECEDOR)
);

CREATE TABLE ITEM_PEDIDO (
    COD_ITEM_PEDIDO SERIAL PRIMARY KEY, 
    COD_PEDIDO INT, 
    COD_LIVRO INT,
    QTD_ITENS INT,
    FOREIGN KEY (COD_PEDIDO) REFERENCES PEDIDO(COD_PEDIDO),
    FOREIGN KEY (COD_LIVRO) REFERENCES LIVRO(COD_LIVRO)
);

INSERT INTO TITULO (NOME_TITULO, DESC_TITULO) VALUES
('O Senhor dos Anéis', 'Fantasia épica'),
('1984', 'Distopia totalitária'),
('A Revolução dos Bichos', 'Fábula política'),
('Dom Quixote', 'Romance clássico'),
('Harry Potter e a Pedra Filosofal', 'Fantasia juvenil');

INSERT INTO LIVRO (COD_TITULO, VALOR_LIVRO, QTD_ESTOQUE) VALUES
(1, 100, 50),
(2, 50, 30),
(3, 40, 20),
(4, 80, 15),
(5, 90, 25);

INSERT INTO FORNECEDOR (NOME_FORNECEDOR, FONE_FORNECEDOR) VALUES
('Editora A', '1234-5678'),
('Editora B', '2345-6789'),
('Editora C', '3456-7890'),
('Editora D', '4567-8901'),
('Editora E', '5678-9012');

INSERT INTO PEDIDO (COD_FORNECEDOR, HORA_PEDIDO, DATA_PEDIDO, VALOR_TOTAL_PEDIDO, QTD_ITENS_PEDIDOS) VALUES
(1, '10:30:00', '2025-04-01', 500, 5),
(2, '11:00:00', '2025-04-02', 300, 3),
(3, '14:45:00', '2025-04-03', 200, 5),
(4, '09:15:00', '2025-04-04', 400, 3),
(5, '16:00:00', '2025-04-05', 600, 1);

INSERT INTO ITEM_PEDIDO (COD_PEDIDO, COD_LIVRO, QTD_ITENS) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 3),
(3, 4, 4),
(4, 5, 5);

CREATE TRIGGER CONTROLADOR_TRIGGER 
AFTER INSERT OR DELETE OR UPDATE 
ON ITEM_PEDIDO FOR EACH ROW 
EXECUTE FUNCTION controlador();