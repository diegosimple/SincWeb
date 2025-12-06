-- Script SQL para criar tabelas no MySQL
-- Execute este script no seu banco de dados MySQL em nuvem

CREATE DATABASE IF NOT EXISTS conectivasf;
USE conectivasf;

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS usuario_sf (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Senha_mobile VARCHAR(100) NOT NULL,
    CodEmp INT,
    Last_mod TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (Email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de clientes
CREATE TABLE IF NOT EXISTS clientes_sf (
    Codigo INT PRIMARY KEY,
    Razao_Nome VARCHAR(200) NOT NULL,
    Apelido_Fantasia VARCHAR(200),
    Cpf_Cnpj VARCHAR(20),
    Cidade VARCHAR(100),
    UF VARCHAR(2),
    Fone VARCHAR(20),
    Celular VARCHAR(20),
    Cli_Obs TEXT,
    CodEmp INT,
    Last_mod TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_codemp (CodEmp),
    INDEX idx_razao (Razao_Nome),
    INDEX idx_lastmod (Last_mod)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de produtos
CREATE TABLE IF NOT EXISTS produtos_sf (
    Codigo INT PRIMARY KEY,
    Descricao VARCHAR(200) NOT NULL,
    Referencia VARCHAR(50),
    Codigo_Barras VARCHAR(50),
    Preco_Venda DECIMAL(10,2),
    Estoque_Atual DECIMAL(10,2),
    Unidade VARCHAR(10),
    CodEmp INT,
    Last_mod TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_codemp (CodEmp),
    INDEX idx_descricao (Descricao),
    INDEX idx_barras (Codigo_Barras),
    INDEX idx_lastmod (Last_mod)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de pedidos
CREATE TABLE IF NOT EXISTS pedidos_sf (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Numero_Pedido VARCHAR(20),
    CodCliente INT,
    CodVendedor INT,
    Data_Pedido DATETIME,
    Valor_Total DECIMAL(10,2),
    Status VARCHAR(20),
    Obs TEXT,
    CodEmp INT,
    Sincronizado TINYINT(1) DEFAULT 1,
    Last_mod TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CodCliente) REFERENCES clientes_sf(Codigo),
    INDEX idx_codemp (CodEmp),
    INDEX idx_data (Data_Pedido),
    INDEX idx_cliente (CodCliente),
    INDEX idx_lastmod (Last_mod)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de itens de pedidos
CREATE TABLE IF NOT EXISTS pedidos_itens_sf (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    CodPedido INT,
    CodProduto INT,
    Quantidade DECIMAL(10,2),
    Preco_Unitario DECIMAL(10,2),
    Desconto DECIMAL(10,2) DEFAULT 0,
    Valor_Total DECIMAL(10,2),
    FOREIGN KEY (CodPedido) REFERENCES pedidos_sf(Id) ON DELETE CASCADE,
    FOREIGN KEY (CodProduto) REFERENCES produtos_sf(Codigo),
    INDEX idx_pedido (CodPedido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de planos de pagamento
CREATE TABLE IF NOT EXISTS planos_pgto_sf (
    Codigo INT PRIMARY KEY,
    Descricao VARCHAR(100) NOT NULL,
    Parcelas INT,
    CodEmp INT,
    Last_mod TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_codemp (CodEmp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inserir usuário admin padrão
INSERT INTO usuario_sf (Id, Nome, Email, Senha_mobile, CodEmp)
VALUES (1, 'Administrador', 'admin@conectivasf.com', 'admin123', 1)
ON DUPLICATE KEY UPDATE Nome = 'Administrador';

-- Inserir alguns dados de exemplo (opcional)
INSERT INTO clientes_sf (Codigo, Razao_Nome, Apelido_Fantasia, Cpf_Cnpj, Cidade, UF, Celular, CodEmp) VALUES
(1, 'Cliente Exemplo LTDA', 'Cliente Exemplo', '12.345.678/0001-90', 'São Paulo', 'SP', '(11) 98765-4321', 1),
(2, 'João da Silva', 'João Silva', '123.456.789-00', 'Rio de Janeiro', 'RJ', '(21) 91234-5678', 1)
ON DUPLICATE KEY UPDATE Razao_Nome = VALUES(Razao_Nome);

INSERT INTO produtos_sf (Codigo, Descricao, Referencia, Codigo_Barras, Preco_Venda, Estoque_Atual, Unidade, CodEmp) VALUES
(1, 'Produto Exemplo 1', 'REF001', '7891234567890', 150.00, 100, 'UN', 1),
(2, 'Produto Exemplo 2', 'REF002', '7891234567891', 250.00, 50, 'UN', 1)
ON DUPLICATE KEY UPDATE Descricao = VALUES(Descricao);

INSERT INTO planos_pgto_sf (Codigo, Descricao, Parcelas, CodEmp) VALUES
(1, 'À Vista', 1, 1),
(2, '2x sem juros', 2, 1),
(3, '3x sem juros', 3, 1)
ON DUPLICATE KEY UPDATE Descricao = VALUES(Descricao);
