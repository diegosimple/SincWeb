# Migração: Campos de Desconto

## 📋 Resumo
Este documento descreve as alterações necessárias para adicionar suporte a desconto nas tabelas `usuarios` e `pedidos` do banco de dados da nuvem.

## 🗄️ Arquivos SQL

### 1. `migration_desconto.sql`
Script completo com verificação de existência das colunas antes de adicionar. **Recomendado para produção.**

### 2. `migration_desconto_simples.sql`
Script simples sem verificação. Mais rápido, mas pode gerar erro se as colunas já existirem. **Use apenas se tiver certeza que as colunas não existem.**

## 📝 Campos Adicionados

### Tabela `usuarios`
- **Desconto_Padrao** (DECIMAL(10,2)): Valor máximo permitido de desconto (padrão: 10.00)
- **Permite_Desconto** (TINYINT(1)): Se o usuário pode aplicar desconto (1 = Sim, 0 = Não)
- **Tipo_Desconto** (VARCHAR(1)): Tipo de desconto permitido ('P' = Percentual, 'V' = Valor)

### Tabela `pedidos`
- **ValorTotalSemDesconto** (DECIMAL(10,2)): Total antes de aplicar desconto
- **ValorTotalComDesconto** (DECIMAL(10,2)): Total após aplicar desconto
- **TipoDesconto** (VARCHAR(1)): Tipo de desconto aplicado ('P' = Percentual, 'V' = Valor)
- **ValorDesconto** (DECIMAL(10,2)): Valor do desconto aplicado

## 🔧 Alterações nos Controladores

### 1. `PedidosController.php`
✅ Atualizado para incluir os campos de desconto no INSERT:
- `ValorTotalSemDesconto`
- `ValorTotalComDesconto`
- `TipoDesconto`
- `ValorDesconto`

### 2. `SyncController.php`
✅ Atualizado para incluir os campos de desconto do usuário no SELECT:
- `Desconto_Padrao`
- `Permite_Desconto`
- `Tipo_Desconto`

## 📱 Mobile (já implementado)
O aplicativo mobile já está enviando os campos de desconto:
- `NewOrderScreen.js` salva os campos ao criar/atualizar pedido
- A sincronização já inclui todos os campos do pedido

## 🚀 Como Aplicar

1. **Backup do banco de dados** (IMPORTANTE!)

2. **Execute o SQL de migração:**
   ```sql
   -- Opção 1: Script com verificação (recomendado)
   source api-php/database/migration_desconto.sql;
   
   -- Opção 2: Script simples
   source api-php/database/migration_desconto_simples.sql;
   ```

3. **Verifique se as colunas foram criadas:**
   ```sql
   -- Verificar usuarios
   DESCRIBE usuarios;
   
   -- Verificar pedidos
   DESCRIBE pedidos;
   ```

4. **Teste a sincronização:**
   - Crie um pedido com desconto no mobile
   - Sincronize o pedido
   - Verifique se os campos foram salvos corretamente na nuvem

## ⚠️ Observações

- Os valores padrão são seguros e não afetam dados existentes
- Se as colunas já existirem, o script com verificação não gerará erro
- O script simples pode gerar erro se executado mais de uma vez

## ✅ Checklist

- [ ] Backup do banco de dados realizado
- [ ] SQL de migração executado
- [ ] Colunas verificadas no banco
- [ ] Teste de sincronização realizado
- [ ] Pedido com desconto criado e sincronizado com sucesso

