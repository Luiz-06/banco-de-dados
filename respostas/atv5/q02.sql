CREATE OR REPLACE FUNCTION realizar_hospedagem(COD_HOSP_P INT, NUM_AP_P INT) 
RETURNS TEXT 
AS $$
DECLARE 
    hosp_exist INT;
    ap_ocupado INT;
BEGIN
    -- Verifica se o hóspede existe
    SELECT COUNT(*) INTO hosp_exist 
    FROM HOSPEDE
    WHERE COD_HOSP = COD_HOSP_P;

    IF hosp_exist = 0 THEN
        RETURN 'ESSE HÓSPEDE NÃO EXISTE';
    END IF;

    -- Verifica se o apartamento está ocupado
    SELECT COUNT(*) INTO ap_ocupado
    FROM HOSPEDAGEM
    WHERE NUM_AP = NUM_AP_P AND DT_SAIDA IS NULL;

    IF ap_ocupado > 0 THEN
        RETURN 'Apartamento ocupado.';
    END IF;

    -- Realiza a hospedagem
    INSERT INTO HOSPEDAGEM (NUM_AP, COD_HOSP, COD_FUNC, DT_ENT, DT_SAIDA)
    VALUES (NUM_AP_P, COD_HOSP_P, 1, CURRENT_DATE, NULL);

    RETURN 'Hospedagem registrada com sucesso.';
END;
$$ LANGUAGE plpgsql;

SELECT realizar_hospedagem(1, 1);
