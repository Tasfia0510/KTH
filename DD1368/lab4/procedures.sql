CREATE PROCEDURE investment_return (
    IN initial_investment INT, 
    IN yearly_return DECIMAL, 
    IN number_of_years INT, 
    INOUT size_of_investment INT DEFAULT NULL
) 

LANGUAGE plpgsql
AS $$
BEGIN 
    size_of_investment := ROUND(initial_investment * POWER(1+yearly_return, number_of_years));
END;
$$;




