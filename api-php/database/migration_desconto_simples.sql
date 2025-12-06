-- =====================================================
-- MIGRAÇÃO SIMPLES: Adicionar campos de desconto
-- =====================================================
-- Data: 2024
-- Descrição: Adiciona campos de desconto nas tabelas usuarios e pedidos
-- 
-- ATENÇÃO: Execute este script apenas se as colunas ainda não existirem!
-- Se as colunas já existirem, você receberá um erro. Nesse caso, ignore o erro.
-- =====================================================

-- 1. ALTERAR TABELA usuarios
-- Adiciona campos de configuração de desconto
ALTER TABLE usuarios 
ADD COLUMN Desconto_Padrao DECIMAL(10,2) DEFAULT 10.00,
ADD COLUMN Permite_Desconto TINYINT(1) DEFAULT 1,
ADD COLUMN Tipo_Desconto VARCHAR(1) DEFAULT 'P' COMMENT 'P = Percentual, V = Valor';

-- 2. ALTERAR TABELA pedidos
-- Adiciona campos de desconto do pedido
ALTER TABLE pedidos 
ADD COLUMN ValorTotalSemDesconto DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN ValorTotalComDesconto DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN TipoDesconto VARCHAR(1) DEFAULT NULL COMMENT 'P = Percentual, V = Valor',
ADD COLUMN ValorDesconto DECIMAL(10,2) DEFAULT 0.00;

-- =====================================================
-- NOTAS:
-- - Desconto_Padrao: Valor máximo permitido (em % ou R$)
-- - Permite_Desconto: 1 = Sim, 0 = Não
-- - Tipo_Desconto: 'P' = Percentual, 'V' = Valor em Reais
-- - ValorTotalSemDesconto: Total antes de aplicar desconto
-- - ValorTotalComDesconto: Total após aplicar desconto
-- - TipoDesconto: Tipo de desconto aplicado no pedido
-- - ValorDesconto: Valor do desconto aplicado
-- =====================================================

