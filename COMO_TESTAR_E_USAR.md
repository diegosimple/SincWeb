# COMO TESTAR E USAR O SINCRONIZADOR FSVENDAS

## 📋 ÍNDICE

1. [Requisitos](#requisitos)
2. [Instalação](#instalação)
3. [Configuração Inicial](#configuração-inicial)
4. [Guia de Uso - Passo a Passo](#guia-de-uso)
5. [Testes Funcionais](#testes-funcionais)
6. [Resolução de Problemas](#resolução-de-problemas)
7. [FAQ](#faq)

---

## REQUISITOS

### Software Necessário

- Windows 7 ou superior
- Delphi XE7 ou superior (para compilação)
- Firebird 2.5+ ou outro banco de dados compatível com FireDAC
- Conexão com internet (para sincronização)

### DLLs Necessárias (para HTTPS)

Copie para a pasta do executável:
```
libssl-1_1.dll
libcrypto-1_1.dll
```

### Estrutura do Banco de Dados

Execute os scripts SQL abaixo **ANTES** de usar:

```sql
-- Adicionar campo CWEB na tabela EMPRESA
ALTER TABLE EMPRESA ADD COLUMN CWEB INTEGER DEFAULT 0;

-- Adicionar campo CODIGO_WEB nas tabelas necessárias
ALTER TABLE PESSOA ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;
ALTER TABLE PRODUTO ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;
ALTER TABLE ORCAMENTO ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;

-- Criar índices para performance
CREATE INDEX idx_pessoa_codigo_web ON PESSOA(CODIGO_WEB);
CREATE INDEX idx_produto_codigo_web ON PRODUTO(CODIGO_WEB);
CREATE INDEX idx_orcamento_codigo_web ON ORCAMENTO(CODIGO_WEB);

-- Adicionar campos opcionais para usuários (desconto)
ALTER TABLE USUARIOS ADD COLUMN DESCONTO_PADRAO DECIMAL(5,2) DEFAULT 10.00;
ALTER TABLE USUARIOS ADD COLUMN PERMITE_DESCONTO SMALLINT DEFAULT 1;
ALTER TABLE USUARIOS ADD COLUMN TIPO_DESCONTO CHAR(1) DEFAULT 'P';
```

---

## INSTALAÇÃO

### 1. Compilação

1. Abra o projeto `SincronizadorApp.dpr` no Delphi
2. Compile o projeto (Project → Build)
3. O executável será gerado em `Win32\Debug\SincronizadorApp.exe`

### 2. Deploy

Copie os seguintes arquivos para a pasta de instalação:

```
SincronizadorApp.exe
libssl-1_1.dll
libcrypto-1_1.dll
fbclient.dll (se usar Firebird)
```

### 3. Primeira Execução

Ao executar pela primeira vez:
- Será criado automaticamente o arquivo `Sincronizador.ini`
- Será criada a pasta `Logs\`

---

## CONFIGURAÇÃO INICIAL

### Passo 1: Aba "Configuração da API"

![Aba 1 - Configuração](docs/screenshots/aba1.png)

1. **Endpoint (URL API):**
   ```
   https://api.fsvendas.com.br/api
   ```

2. **Chave API:**
   - Obtenha a chave com o administrador do sistema
   - Exemplo: `abc123def456ghi789`

3. **Tempo de Sincronização:**
   - Padrão: 300 segundos (5 minutos)
   - Mínimo: 30 segundos
   - Recomendado para produção: 300-600 segundos

4. **Quantidade de Celulares:**
   - Número de dispositivos móveis permitidos
   - Padrão: 5

5. **Opções do Sistema:**
   - ☑ **Iniciar com o Windows**: Abre automaticamente ao ligar o PC
   - ☑ **Minimizar para Tray**: Minimiza para a bandeja do sistema

6. **Teste a Conexão:**
   - Clique em **Testar Conexão**
   - Aguarde a mensagem: "Conexão estabelecida com sucesso!"
   - Se der erro, verifique:
     - Endpoint correto
     - Chave API válida
     - Conexão com internet
     - DLLs SSL presentes

7. **Salvar:**
   - Clique em **Salvar Configurações**

---

### Passo 2: Aba "O que Sincronizar"

![Aba 2 - Sincronização](docs/screenshots/aba2.png)

#### Enviar para Nuvem

Marque os itens que deseja enviar:

- ☑ **Empresa / Usuário / Espécies / Vendedores**
  - Envia dados da empresa, usuários do sistema, formas de pagamento e vendedores
  - **Quando usar:** Primeira sincronização ou quando alterar dados da empresa

- ☑ **Clientes (POST / PUT)**
  - Envia clientes cadastrados no ERP para a nuvem
  - **Quando usar:** Sempre que houver novos clientes ou alterações

- ☑ **Produtos (POST)**
  - Envia produtos ativos do ERP para a nuvem
  - **Quando usar:** Sempre que houver novos produtos ou alterações de preço

- ☐ **Incluir Imagens de Produtos**
  - Envia fotos dos produtos (Base64)
  - ⚠️ **Atenção:** Deixe desmarcado se tiver muitos produtos (pode demorar)

#### Receber da Nuvem

- ☑ **Clientes (GET)**
  - Baixa clientes novos ou atualizados da nuvem
  - Usa timestamp para baixar apenas modificações

- ☑ **Pedidos (GET)**
  - Baixa pedidos pendentes feitos pelo app mobile
  - **Recomendado:** Sempre marcado

#### Sincronização Automática

- ☑ **Enviar automaticamente (via Timer)**
  - Envia dados automaticamente no intervalo configurado
  - Útil para manter produtos/clientes sempre atualizados

- ☑ **Receber automaticamente (via Timer)**
  - Recebe pedidos automaticamente
  - **Recomendado:** Sempre ativo para capturar pedidos em tempo real

---

### Passo 3: Aba "Logs e Progresso"

![Aba 3 - Logs](docs/screenshots/aba3.png)

#### Visualização de Logs

Monitore em tempo real:
```
[2025-12-06 14:35:22] [SISTEMA] Sincronizador FSVendas iniciado
[2025-12-06 14:35:25] [EMPRESA] POST /api/empresa/sync - Status: 200 - Sucesso
[2025-12-06 14:35:28] [CLIENTES] POST /api/clientes/sync - Status: 200 - 150 registros enviados
[2025-12-06 14:35:30] [PRODUTOS] POST /api/produtos/sync - Status: 200 - 89 registros enviados
```

#### Ações

- **Limpar Log:** Limpa a tela de logs
- **Exportar Log:** Salva os logs em arquivo .TXT
- **Salvar logs em arquivo automaticamente:** Salva diariamente em `Logs\2025-12-06.log`

---

## GUIA DE USO

### Caso de Uso 1: PRIMEIRA SINCRONIZAÇÃO

**Objetivo:** Enviar todos os dados do ERP para a nuvem pela primeira vez.

**Passos:**

1. Configure a API (Aba 1) e salve
2. Vá para Aba 2
3. Marque:
   - ☑ Empresa / Usuário / Espécies / Vendedores
   - ☑ Clientes
   - ☑ Produtos
   - ☐ Incluir Imagens (deixe desmarcado por enquanto)
4. Clique em **ENVIAR DADOS**
5. Aguarde a conclusão (acompanhe na Aba 3)
6. Verifique se apareceu a mensagem: "=== ENVIO CONCLUÍDO COM SUCESSO ==="
7. Depois, envie as imagens separadamente:
   - Marque ☑ Incluir Imagens de Produtos
   - Clique em **ENVIAR DADOS** novamente

**Tempo estimado:** 5-15 minutos (depende da quantidade de dados)

---

### Caso de Uso 2: RECEBER PEDIDOS

**Objetivo:** Baixar pedidos feitos pelo app mobile.

**Passos:**

1. Vá para Aba 2
2. Marque:
   - ☑ Pedidos (GET)
3. Clique em **RECEBER DADOS**
4. Os pedidos serão importados para a tabela ORCAMENTO
5. Verifique no ERP os novos pedidos

**Automático:**
- Se marcar ☑ **Receber automaticamente (via Timer)**, os pedidos serão baixados a cada 5 minutos

---

### Caso de Uso 3: ENVIAR NOVOS PRODUTOS

**Objetivo:** Enviar produtos cadastrados hoje para a nuvem.

**Passos:**

1. Cadastre os produtos no ERP normalmente
2. Abra o Sincronizador
3. Vá para Aba 2
4. Marque:
   - ☑ Produtos
   - ☐ Incluir Imagens (se tiver fotos)
5. Clique em **ENVIAR DADOS**
6. Pronto! Produtos disponíveis no app mobile

---

### Caso de Uso 4: RESETAR EMPRESA

**Objetivo:** Apagar TODOS os dados da empresa na nuvem (útil para recomeçar do zero).

⚠️ **ATENÇÃO:** Esta ação é IRREVERSÍVEL!

**Passos:**

1. Vá para Aba 2
2. Clique em **RESETAR EMPRESA** (botão vermelho)
3. Confirme 2 vezes (segurança)
4. Aguarde a mensagem: "Empresa resetada com sucesso!"
5. Faça uma nova sincronização completa (Caso de Uso 1)

**Quando usar:**
- Dados corrompidos na nuvem
- Testes/homologação
- Mudança de CNPJ

---

### Caso de Uso 5: SINCRONIZAÇÃO AUTOMÁTICA

**Objetivo:** Manter dados sempre atualizados automaticamente.

**Passos:**

1. Configure a API (Aba 1)
2. Defina **Tempo de Sincronização:** 300 segundos (5 min)
3. Vá para Aba 2
4. Marque:
   - ☑ Empresa / Usuário / Espécies / Vendedores
   - ☑ Clientes
   - ☑ Produtos
   - ☑ Receber Clientes
   - ☑ Receber Pedidos
5. Marque:
   - ☑ **Enviar automaticamente (via Timer)**
   - ☑ **Receber automaticamente (via Timer)**
6. Minimize para Tray
7. O sincronizador rodará em segundo plano!

**Notificações:**
- Você receberá notificações balloon no Tray Icon quando houver erros ou conclusões

---

## TESTES FUNCIONAIS

### Teste 1: Configuração e Conexão

**Objetivo:** Validar configuração da API

**Passos:**
1. Abra o Sincronizador
2. Vá para Aba 1
3. Preencha endpoint e chave API
4. Clique em **Testar Conexão**

**Resultado Esperado:**
- ✅ Label "Conexão OK!" em verde
- ✅ Log: "[SISTEMA] Token obtido com sucesso"

**Se falhar:**
- ❌ Verificar endpoint (https://...)
- ❌ Verificar chave API
- ❌ Verificar DLLs SSL
- ❌ Verificar firewall/proxy

---

### Teste 2: Envio de Empresa

**Objetivo:** Sincronizar dados da empresa

**Passos:**
1. Marque ☑ Empresa
2. Clique em **ENVIAR DADOS**
3. Aguarde

**Resultado Esperado:**
- ✅ Log: "[EMPRESA] POST /api/empresa/sync - Status: 200 - Sucesso"
- ✅ Campo `CWEB` preenchido na tabela EMPRESA

**Validação:**
```sql
SELECT CODIGO, FANTASIA, CWEB FROM EMPRESA;
```
CWEB deve ser > 0

---

### Teste 3: Envio de Clientes

**Objetivo:** Sincronizar clientes

**Passos:**
1. Cadastre 3 clientes de teste no ERP
2. Marque ☑ Clientes
3. Clique em **ENVIAR DADOS**

**Resultado Esperado:**
- ✅ Log: "[CLIENTES] POST /api/clientes/sync - Status: 200 - 3 registros enviados"
- ✅ Campo `CODIGO_WEB` preenchido

**Validação:**
```sql
SELECT CODIGO, RAZAO, CODIGO_WEB FROM PESSOA WHERE CLI = 'S' ORDER BY CODIGO DESC LIMIT 3;
```

---

### Teste 4: Envio de Produtos

**Objetivo:** Sincronizar produtos

**Passos:**
1. Cadastre 2 produtos de teste
2. Marque ☑ Produtos
3. Clique em **ENVIAR DADOS**

**Resultado Esperado:**
- ✅ Log: "[PRODUTOS] POST /api/produtos/sync - Status: 200 - 2 registros enviados"

---

### Teste 5: Recebimento de Pedidos

**Objetivo:** Baixar pedidos da nuvem

**Pré-requisito:** Crie um pedido manualmente na API ou app mobile

**Passos:**
1. Marque ☑ Receber Pedidos
2. Clique em **RECEBER DADOS**

**Resultado Esperado:**
- ✅ Log: "[PEDIDOS] GET /api/pedidos/pendentes - Status: 200 - 1 pedidos recebidos"
- ✅ Pedido importado na tabela ORCAMENTO

**Validação:**
```sql
SELECT CODIGO, CLIENTE, TOTAL, CODIGO_WEB FROM ORCAMENTO WHERE CODIGO_WEB > 0;
```

---

### Teste 6: Timer Automático

**Objetivo:** Validar sincronização automática

**Passos:**
1. Configure tempo: 60 segundos (1 minuto)
2. Marque ☑ Receber automaticamente
3. Aguarde 1 minuto

**Resultado Esperado:**
- ✅ Log a cada 60 segundos: "[TIMER] Sincronização automática iniciada"

---

### Teste 7: Tray Icon

**Objetivo:** Validar minimização para bandeja

**Passos:**
1. Marque ☑ Minimizar para Tray (Aba 1)
2. Salve configurações
3. Feche a janela (X)

**Resultado Esperado:**
- ✅ Aplicação minimiza para bandeja (não fecha)
- ✅ Ícone aparece na bandeja do sistema
- ✅ Duplo clique no ícone restaura a janela

**Menu do Tray:**
- ✅ "Abrir" → restaura janela
- ✅ "Sincronizar Agora" → executa sincronização
- ✅ "Sair" → fecha aplicação

---

### Teste 8: Reset de Empresa

**Objetivo:** Validar limpeza completa

⚠️ **Atenção:** Use apenas em ambiente de testes!

**Passos:**
1. Clique em **RESETAR EMPRESA**
2. Confirme 2 vezes

**Resultado Esperado:**
- ✅ Log: "[SISTEMA] DELETE /api/empresa/reset - Status: 200 - Empresa resetada"
- ✅ Campo `CWEB` volta para 0
- ✅ Timestamps limpos no Sincronizador.ini

**Validação:**
```sql
SELECT CWEB FROM EMPRESA;
```
CWEB deve ser = 0

---

### Teste 9: Exportação de Logs

**Objetivo:** Validar exportação

**Passos:**
1. Execute algumas sincronizações
2. Vá para Aba 3
3. Clique em **Exportar Log**
4. Salve como `teste.txt`

**Resultado Esperado:**
- ✅ Arquivo criado
- ✅ Conteúdo igual ao memo
- ✅ Encoding UTF-8

---

### Teste 10: Iniciar com Windows

**Objetivo:** Validar auto-start

**Passos:**
1. Marque ☑ Iniciar com o Windows
2. Salve configurações
3. Reinicie o PC

**Resultado Esperado:**
- ✅ Aplicação abre automaticamente após login

**Validação Manual:**
1. Pressione `Win + R`
2. Digite: `regedit`
3. Navegue até: `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run`
4. Verifique chave: `SincronizadorFSVendas`

---

## RESOLUÇÃO DE PROBLEMAS

### Erro: "Endpoint não configurado"

**Causa:** Campo vazio ou inválido

**Solução:**
1. Vá para Aba 1
2. Preencha: `https://api.fsvendas.com.br/api`
3. Salve

---

### Erro: "Falha na autenticação"

**Causa:** Chave API inválida ou expirada

**Solução:**
1. Verifique a chave API com o administrador
2. Teste novamente a conexão

---

### Erro: "Erro HTTP 401"

**Causa:** Token JWT expirado

**Solução:**
- Aguarde alguns segundos e tente novamente
- O sistema renova o token automaticamente

---

### Erro: "Erro HTTP 400 - CNPJ inválido"

**Causa:** CNPJ da empresa não está formatado

**Solução:**
```sql
UPDATE EMPRESA SET CNPJ = '12.345.678/0001-90' WHERE CODIGO = 1;
```

---

### Erro: "SSL não carregado"

**Causa:** DLLs SSL ausentes

**Solução:**
1. Baixe as DLLs:
   - libssl-1_1.dll
   - libcrypto-1_1.dll
2. Copie para a pasta do executável

**Download:**
[https://indy.fulgan.com/SSL/](https://indy.fulgan.com/SSL/)

---

### Sincronização Muito Lenta

**Causa:** Muitos produtos com imagens

**Solução:**
1. Desmarcque ☐ Incluir Imagens de Produtos
2. Envie os produtos sem imagens primeiro
3. Depois, envie as imagens separadamente (em lotes menores)

---

### Pedidos Não Aparecem no ERP

**Causa:** Mapeamento incorreto de campos

**Verificação:**
```sql
SELECT * FROM ORCAMENTO WHERE CODIGO_WEB > 0;
```

Se vazio:
- Verifique se o campo CODIGO_WEB existe
- Verifique se há pedidos pendentes na API

---

## FAQ

### 1. Preciso sincronizar manualmente sempre?

**Não.** Configure a sincronização automática:
- Marque ☑ Enviar automaticamente
- Marque ☑ Receber automaticamente
- Defina o intervalo (300 segundos = 5 min)

---

### 2. Posso usar HTTP ao invés de HTTPS?

**Tecnicamente sim**, mas **NÃO É RECOMENDADO**.
- HTTPS garante segurança na transmissão de dados
- Evite usar HTTP em produção

---

### 3. Quantos dispositivos móveis posso ter?

O limite é configurável na **Aba 1 → Quantidade de Celulares**.
- Padrão: 5 dispositivos
- Máximo: 20 dispositivos

---

### 4. Os logs ocupam muito espaço?

Não. Cada dia gera um novo arquivo (ex: `2025-12-06.log`).
- Tamanho médio: 100-500 KB/dia
- Recomendado: Apagar logs com mais de 30 dias

---

### 5. Posso rodar em mais de um computador?

**Sim**, desde que:
- Todos apontem para o mesmo banco de dados
- **Apenas 1 computador** deve ter sincronização automática ativa

---

### 6. Como saber se a sincronização está funcionando?

Verifique:
1. Aba 3 → Logs em tempo real
2. Timestamps no arquivo `Sincronizador.ini`
3. Notificações balloon no Tray Icon

---

### 7. Posso agendar sincronização em horários específicos?

Atualmente não. A sincronização funciona por **intervalo** (ex: a cada 5 min).

**Workaround:**
- Use o Agendador de Tarefas do Windows
- Crie uma tarefa para abrir o sincronizador em horários específicos

---

### 8. O que acontece se eu perder conexão durante a sincronização?

O sistema:
1. Tenta 3 vezes com backoff exponencial (2s, 4s, 8s)
2. Registra erro no log
3. Aguarda o próximo timer

**Dados não são perdidos**, apenas não são enviados naquela tentativa.

---

### 9. Posso sincronizar apenas produtos alterados hoje?

Atualmente não. O sistema envia **todos os produtos ativos**.

**Melhoria futura:** Implementar filtro por data de alteração.

---

### 10. Como voltar atrás depois de resetar a empresa?

**Não é possível.** O reset apaga permanentemente os dados na nuvem.

**Prevenção:**
- Faça backup do banco antes
- Use apenas em testes ou quando absolutamente necessário

---

## CHECKLIST DE IMPLANTAÇÃO

Antes de ir para produção:

- [ ] Executou os scripts SQL (campos CWEB, CODIGO_WEB)
- [ ] Testou conexão com a API
- [ ] Fez primeira sincronização completa (empresa, clientes, produtos)
- [ ] Testou recebimento de pedidos
- [ ] Configurou sincronização automática
- [ ] Testou Tray Icon e minimização
- [ ] Configurou "Iniciar com Windows" (se desejado)
- [ ] Documentou endpoint e chave API em local seguro
- [ ] Testou em ambiente de homologação primeiro

---

## SUPORTE

Para dúvidas ou problemas:

- **Email:** suporte@fsvendas.com.br
- **WhatsApp:** (48) 99846-3846
- **Documentação:** [https://docs.fsvendas.com.br](https://docs.fsvendas.com.br)

---

**Última atualização:** 2025-12-06
**Versão:** 1.0
