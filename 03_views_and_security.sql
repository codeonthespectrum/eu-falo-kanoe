-- ==================================================================
-- ARQUIVO: 03_views_and_security.sql
-- DESCRIÇÃO: Criação de Views amigáveis e Políticas de Segurança (RLS)
-- ==================================================================

-- 1. View Consolidada (O "Dicionário Pronto")
CREATE OR REPLACE VIEW view_dicionario_completo AS
SELECT 
    p.id_palavra,
    p.termo_kanoe AS palavra,
    p.classe_gramatical,
    pr.ipa AS pronuncia,
    s.traducao_primaria AS traducao,
    s.nota_cultural,
    b.titulo AS fonte,
    -- Agrega frases em uma única string para visualização rápida
    (SELECT string_agg(f.texto_kanoe || ' (' || f.traducao_pt || ')', ' | ') 
     FROM frase f WHERE f.fk_id_palavra = p.id_palavra) as exemplos
FROM palavra p
LEFT JOIN significado s ON p.id_palavra = s.fk_id_palavra
LEFT JOIN pronuncia pr ON p.id_palavra = pr.fk_id_palavra
LEFT JOIN bibliografia b ON s.fk_id_bibliografia = b.id_fonte
WHERE pr.tipo_forma = 'padrao' OR pr.tipo_forma IS NULL;

-- 2. Row Level Security (RLS)
-- Habilita segurança no nível do banco
ALTER TABLE palavra ENABLE ROW LEVEL SECURITY;
ALTER TABLE significado ENABLE ROW LEVEL SECURITY;
ALTER TABLE frase ENABLE ROW LEVEL SECURITY;

-- Regra: Leitura (SELECT) liberada para todos (Público)
CREATE POLICY "Public Read Palavras" ON palavra FOR SELECT USING (true);
CREATE POLICY "Public Read Significados" ON significado FOR SELECT USING (true);

-- Regra: Escrita (INSERT/UPDATE/DELETE) apenas para usuários logados
CREATE POLICY "Admin Write Palavras" ON palavra FOR ALL TO authenticated USING (true);
