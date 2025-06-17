CREATE USER joao_gerente WITH PASSWORD '123';
CREATE USER maria_atendente WITH PASSWORD '123';
CREATE USER lucas_estagiario WITH PASSWORD '123';

-- Atribuir papéis
GRANT GERENTE TO joao_gerente;
GRANT ATENDENTE TO maria_atendente;
GRANT ESTAGIARIO TO lucas_estagiario;
