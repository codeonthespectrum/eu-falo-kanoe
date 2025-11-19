-- ==================================================================
-- ARQUIVO: 02_etl_processing.sql
-- DESCRIÇÃO: Lógica de ETL para processamento e desduplicação de dados brutos
-- ==================================================================

-- Exemplo da lógica utilizada para processar a tabela de staging (import_csv_unificado)
-- Este bloco PL/pgSQL é idempotente (pode rodar várias vezes sem duplicar)

DO $$
DECLARE
    reg RECORD;
    v_id_palavra BIGINT;
    v_id_sentido BIGINT;
    v_id_bibliografia BIGINT;
    v_id_frase BIGINT;
BEGIN
    -- Loop pela tabela de carga (staging)
    FOR reg IN SELECT * FROM import_csv_unificado LOOP
        
        -- 1. Gestão de Fontes (Busca ou Criação)
        SELECT id_fonte INTO v_id_bibliografia FROM bibliografia 
        WHERE titulo ILIKE '%' || reg.fonte_info || '%' LIMIT 1;

        IF v_id_bibliografia IS NULL AND reg.fonte_info IS NOT NULL THEN
            INSERT INTO bibliografia (titulo, tipo, arquivo_ref) 
            VALUES (reg.fonte_info, 'outro', 'ref_auto_' || md5(reg.fonte_info))
            RETURNING id_fonte INTO v_id_bibliografia;
        END IF;

        -- 2. Gestão de Palavras (Upsert Lógico)
        IF reg.palavra_kanoe IS NOT NULL THEN
            SELECT id_palavra INTO v_id_palavra FROM palavra WHERE termo_kanoe = reg.palavra_kanoe LIMIT 1;

            IF v_id_palavra IS NOT NULL THEN
                -- Enriquecimento: Atualiza dados faltantes
                UPDATE palavra 
                SET classe_gramatical = COALESCE(classe_gramatical, reg.classe_gramatical)
                WHERE id_palavra = v_id_palavra;
            ELSE
                INSERT INTO palavra (termo_kanoe, classe_gramatical)
                VALUES (reg.palavra_kanoe, reg.classe_gramatical)
                RETURNING id_palavra INTO v_id_palavra;
            END IF;

            -- 3. Inserção de Fonética
            IF reg.fonetica IS NOT NULL THEN
                PERFORM 1 FROM pronuncia WHERE fk_id_palavra = v_id_palavra AND ipa = reg.fonetica;
                IF NOT FOUND THEN
                    INSERT INTO pronuncia (fk_id_palavra, grafia, ipa, tipo_forma)
                    VALUES (v_id_palavra, reg.palavra_kanoe, reg.fonetica, 'padrao');
                END IF;
            END IF;

            -- 4. Inserção de Significados
            INSERT INTO significado (fk_id_palavra, traducao_primaria, nota_cultural, fk_id_bibliografia)
            VALUES (v_id_palavra, reg.traducao, reg.nota_cultural, v_id_bibliografia);
        END IF;

        -- 5. Gestão de Frases
        IF reg.frase_kanoe IS NOT NULL AND reg.frase_kanoe != '' AND v_id_palavra IS NOT NULL THEN
            PERFORM 1 FROM frase WHERE texto_kanoe = reg.frase_kanoe AND fk_id_palavra = v_id_palavra;
            IF NOT FOUND THEN
                INSERT INTO frase (texto_kanoe, traducao_pt, fk_id_palavra, fk_id_bibliografia, contexto_uso)
                VALUES (reg.frase_kanoe, reg.frase_pt, v_id_palavra, v_id_bibliografia, reg.nota_cultural);
            END IF;
        END IF;

    END LOOP;
END $$;
