-- Adiciona a coluna 'key' na tabela empresas se ela não existir
-- Este script é idempotente, pode ser executado múltiplas vezes sem erro.

-- Verifica se a coluna 'key' existe na tabela 'empresas'
SET @alter_sql = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'empresas' 
     AND COLUMN_NAME = 'key') = 0,
    'ALTER TABLE empresas ADD COLUMN `key` VARCHAR(255) DEFAULT NULL COMMENT ''Chave API da empresa para autenticação'';',
    'SELECT ''Column key already exists in empresas. Skipping migration.'';'
);

PREPARE stmt FROM @alter_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Opcional: Adicionar índice para key se for usado frequentemente em buscas
SET @index_sql = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'empresas' 
     AND INDEX_NAME = 'idx_key') = 0,
    'CREATE INDEX idx_key ON empresas (`key`);',
    'SELECT ''Index idx_key already exists on empresas. Skipping index creation.'';'
);

PREPARE stmt FROM @index_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

