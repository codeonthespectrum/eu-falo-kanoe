-- ==================================================================
-- ARQUIVO: 04_functions.sql
-- DESCRIÇÃO: Funções armazenadas (Stored Procedures) para busca textual
-- ==================================================================

CREATE OR REPLACE FUNCTION buscar_kanoe(termo text)
RETURNS SETOF view_dicionario_completo AS $$
BEGIN
  -- Retorna resultados buscando em várias colunas ao mesmo tempo
  -- ILIKE garante que a busca ignore maiúsculas/minúsculas
  RETURN QUERY
  SELECT *
  FROM view_dicionario_completo
  WHERE 
    palavra ILIKE '%' || termo || '%' OR
    traducao ILIKE '%' || termo || '%' OR
    nota_cultural ILIKE '%' || termo || '%' OR
    classe_gramatical ILIKE '%' || termo || '%';
END;
$$ LANGUAGE plpgsql;
