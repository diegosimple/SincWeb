-- ============================================
-- MIGRATION: Adicionar campo cweb em clientes
-- Data: 2024
-- Descrição: Campo para amarrar cadastro local com cadastro da nuvem
-- ============================================

-- Adicionar coluna cweb na tabela clientes (se não existir)
ALTER TABLE clientes 
ADD COLUMN cweb INTEGER NULL 
COMMENT 'Código web - usado para correlação entre cadastro local e nuvem';

-- Atualizar cweb com o valor do código (para registros existentes)
UPDATE clientes 
SET cweb = codigo 
WHERE cweb IS NULL;

-- Criar índice para melhorar performance nas buscas por cweb
CREATE INDEX idx_clientes_cweb ON clientes(cweb);

-- ============================================
-- NOTAS:
-- - cweb será preenchido automaticamente na sincronização
-- - cweb = código do cliente na nuvem/web
-- - Código local pode ser diferente, mas cweb deve bater
-- ============================================

