-- ============================================
-- MIGRATION: Adicionar campos de endereço em clientes
-- Data: 2024
-- Descrição: Adiciona campos de endereço completo para clientes
-- ============================================

-- Adicionar colunas de endereço na tabela clientes (se não existirem)
ALTER TABLE clientes 
ADD COLUMN endereco VARCHAR(60) NULL 
COMMENT 'Logradouro (Rua, Avenida, etc.)';

ALTER TABLE clientes 
ADD COLUMN endereco_numero VARCHAR(15) NULL 
COMMENT 'Número do endereço';

ALTER TABLE clientes 
ADD COLUMN Complemento VARCHAR(255) NULL 
COMMENT 'Complemento (Apto, Bloco, etc.)';

ALTER TABLE clientes 
ADD COLUMN bairro VARCHAR(40) NULL 
COMMENT 'Bairro';

ALTER TABLE clientes 
ADD COLUMN cep VARCHAR(10) NULL 
COMMENT 'CEP';

-- ============================================
-- NOTAS:
-- - Todos os campos são opcionais (NULL)
-- - Campos serão preenchidos no cadastro ou consulta CNPJ
-- ============================================

