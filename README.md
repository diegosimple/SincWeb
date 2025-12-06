# SINCRONIZADOR FSVENDAS - Delphi Desktop Application

![Version](https://img.shields.io/badge/version-1.0-blue)
![Delphi](https://img.shields.io/badge/Delphi-XE7+-red)
![License](https://img.shields.io/badge/license-Proprietary-green)

**Aplicação Desktop Delphi para sincronização bidirecional entre ERP local e API FSVendas Web.**

---

## 🚀 CARACTERÍSTICAS

- ✅ **Interface com 3 Abas**: Configuração, Sincronização, Logs
- ✅ **Tray Icon**: Minimização para bandeja do sistema
- ✅ **Sincronização Automática**: Timer configurável
- ✅ **Logs Detalhados**: Em tempo real com exportação
- ✅ **Segurança**: HTTPS + JWT + validações
- ✅ **Progress Bar**: Acompanhamento visual
- ✅ **Notificações**: Balloon hints no tray
- ✅ **Auto-start**: Iniciar com Windows (opcional)

---

## 📁 ESTRUTURA DO PROJETO

```
SincWeb/
├── Sincronizador/
│   ├── SincronizadorApp.dpr          # Projeto principal
│   ├── uFormPrincipal.pas/.dfm       # Form com 3 abas
│   ├── uConfiguracao.pas             # Gerenciamento INI
│   ├── uLogSistema.pas               # Sistema de logs
│   ├── uSincronizacao.pas            # Controlador de sincronização
│   ├── uSincronizadorApi.pas         # Comunicação com API
│   ├── uSincronizar.pas/.dfm         # Unit existente (compatibilidade)
│   └── uPedidoWeb.pas/.dfm           # Unit existente (compatibilidade)
│
├── ARQUITETURA_SINCRONIZADOR.md      # Documentação técnica completa
├── COMO_TESTAR_E_USAR.md             # Guia de uso e testes
└── README.md                         # Este arquivo
```

---

## 🎯 ENTIDADES SINCRONIZADAS

### Envio (ERP → Nuvem)

| Entidade | Métodos | Descrição |
|----------|---------|-----------|
| **Empresa** | POST, PUT | Dados da empresa, formas de pagamento, usuários |
| **Clientes** | POST, PUT | Cadastro de clientes |
| **Produtos** | POST | Produtos ativos (com/sem imagens) |
| **Pedidos** | POST, PUT | Pedidos (futuro) |

### Recebimento (Nuvem → ERP)

| Entidade | Métodos | Descrição |
|----------|---------|-----------|
| **Clientes** | GET | Clientes novos/atualizados |
| **Pedidos** | GET | Pedidos pendentes do app mobile |

---

## 📦 INSTALAÇÃO

### Requisitos

- Windows 7+
- Delphi XE7+ (para compilação)
- Firebird 2.5+ ou banco compatível FireDAC
- DLLs SSL (libssl-1_1.dll, libcrypto-1_1.dll)

### Setup do Banco de Dados

Execute os scripts SQL:

```sql
ALTER TABLE EMPRESA ADD COLUMN CWEB INTEGER DEFAULT 0;
ALTER TABLE PESSOA ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;
ALTER TABLE PRODUTO ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;
ALTER TABLE ORCAMENTO ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;

CREATE INDEX idx_pessoa_codigo_web ON PESSOA(CODIGO_WEB);
CREATE INDEX idx_produto_codigo_web ON PRODUTO(CODIGO_WEB);
CREATE INDEX idx_orcamento_codigo_web ON ORCAMENTO(CODIGO_WEB);
```

### Compilação

```bash
# Abra o projeto no Delphi
File → Open Project → SincronizadorApp.dpr

# Compile
Project → Build SincronizadorApp
```

### Deploy

Copie para a pasta de instalação:
- `SincronizadorApp.exe`
- `libssl-1_1.dll`
- `libcrypto-1_1.dll`
- `fbclient.dll` (se usar Firebird)

---

## ⚙️ CONFIGURAÇÃO RÁPIDA

### 1. Primeira Execução

Ao abrir o aplicativo:
1. Vá para **Aba 1 - Configuração da API**
2. Preencha:
   - **Endpoint:** `https://api.fsvendas.com.br/api`
   - **Chave API:** (obtenha com o administrador)
3. Clique em **Testar Conexão**
4. Clique em **Salvar Configurações**

### 2. Primeira Sincronização

1. Vá para **Aba 2 - O que Sincronizar**
2. Marque:
   - ☑ Empresa / Usuário / Espécies / Vendedores
   - ☑ Clientes
   - ☑ Produtos
3. Clique em **ENVIAR DADOS**
4. Aguarde a conclusão na **Aba 3 - Logs**

### 3. Sincronização Automática

1. Na **Aba 2**, marque:
   - ☑ Enviar automaticamente (via Timer)
   - ☑ Receber automaticamente (via Timer)
2. Minimize para Tray
3. Pronto! O sistema sincroniza automaticamente a cada 5 minutos

---

## 📖 DOCUMENTAÇÃO

### Arquivos de Documentação

- **[ARQUITETURA_SINCRONIZADOR.md](ARQUITETURA_SINCRONIZADOR.md)**
  - Arquitetura completa do sistema
  - Classes e units detalhadas
  - Fluxos de sincronização
  - Diagramas e estruturas

- **[COMO_TESTAR_E_USAR.md](COMO_TESTAR_E_USAR.md)**
  - Guia passo a passo de uso
  - 10 testes funcionais
  - Casos de uso práticos
  - Troubleshooting completo
  - FAQ

---

## 🔧 FUNCIONALIDADES PRINCIPAIS

### Aba 1: Configuração da API

- Configurar endpoint e chave API
- Testar conexão
- Definir tempo de sincronização (padrão: 300s)
- Configurar auto-start com Windows
- Habilitar minimização para tray

### Aba 2: O que Sincronizar

- **Enviar para Nuvem:**
  - Empresa + Usuários + Formas de Pagamento
  - Clientes
  - Produtos (com opção de imagens)

- **Receber da Nuvem:**
  - Clientes novos/atualizados
  - Pedidos pendentes

- **Ações:**
  - Botão ENVIAR DADOS
  - Botão RECEBER DADOS
  - Botão RESETAR EMPRESA (apaga tudo na nuvem)

- **Automação:**
  - Timer para envio automático
  - Timer para recebimento automático

### Aba 3: Logs e Progresso

- Visualização em tempo real
- Progress bar
- Exportar logs para TXT
- Salvar logs em arquivo automaticamente

### Tray Icon

- Minimizar para bandeja
- Menu de contexto:
  - Abrir
  - Sincronizar Agora
  - Sair
- Notificações balloon (erros, sucesso)

---

## 🧪 TESTES

Execute os **10 testes funcionais** descritos em [COMO_TESTAR_E_USAR.md](COMO_TESTAR_E_USAR.md):

1. ✅ Configuração e Conexão
2. ✅ Envio de Empresa
3. ✅ Envio de Clientes
4. ✅ Envio de Produtos
5. ✅ Recebimento de Pedidos
6. ✅ Timer Automático
7. ✅ Tray Icon
8. ✅ Reset de Empresa
9. ✅ Exportação de Logs
10. ✅ Iniciar com Windows

---

## 📊 FORMATO DOS LOGS

```
[2025-12-06 14:35:22] [SISTEMA] Sincronizador FSVendas iniciado
[2025-12-06 14:35:22] [INFO] Versão 1.0 - Build 2025-12-06
[2025-12-06 14:35:25] [SISTEMA] Obtendo token de autenticação...
[2025-12-06 14:35:26] [SUCESSO] Token obtido com sucesso
[2025-12-06 14:35:28] [EMPRESA] Iniciando envio...
[2025-12-06 14:35:30] [SUCESSO] [EMPRESA] POST /api/empresa/sync - Status: 200 - Sucesso
[2025-12-06 14:35:32] [CLIENTES] Iniciando envio...
[2025-12-06 14:35:35] [SUCESSO] [CLIENTES] POST /api/clientes/sync - Status: 200 - 150 registros enviados
[2025-12-06 14:35:38] [PRODUTOS] Iniciando envio...
[2025-12-06 14:35:42] [SUCESSO] [PRODUTOS] POST /api/produtos/sync - Status: 200 - 89 registros enviados
[2025-12-06 14:35:45] [SUCESSO] === ENVIO CONCLUÍDO COM SUCESSO ===
```

---

## 🔒 SEGURANÇA

- **HTTPS:** Comunicação criptografada (TLS 1.2+)
- **JWT:** Autenticação via token
- **Validações:** Verificações de CNPJ, chave API, endpoints
- **Retry Logic:** 3 tentativas com backoff exponencial
- **Confirmação Dupla:** Reset de empresa requer 2 confirmações

---

## 🐛 TROUBLESHOOTING

### Erro: "SSL não carregado"
**Solução:** Copie `libssl-1_1.dll` e `libcrypto-1_1.dll` para a pasta do executável.

### Erro: "Falha na autenticação"
**Solução:** Verifique a chave API com o administrador.

### Erro: "CNPJ inválido"
**Solução:** Formate o CNPJ: `12.345.678/0001-90`

### Sincronização muito lenta
**Solução:** Desmarcque "Incluir Imagens de Produtos" na primeira sincronização.

Ver mais em: [COMO_TESTAR_E_USAR.md](COMO_TESTAR_E_USAR.md#resolução-de-problemas)

---

## 📝 ARQUIVO DE CONFIGURAÇÃO

**Sincronizador.ini**

```ini
[API]
Endpoint=https://api.fsvendas.com.br/api
ChaveAPI=sua-chave-aqui
TempoSincronizacao=300
QtdCelulares=5

[SISTEMA]
IniciarComWindows=1
MinimizarParaTray=1
SalvarLogsArquivo=0

[SINCRONIZACAO]
AutoEnviar=1
AutoReceber=1
SincronizarImagens=0

[ULTIMO_ENVIO]
Empresa=2025-12-06 10:30:00
Clientes=2025-12-06 10:31:15
Produtos=2025-12-06 10:35:42

[ULTIMO_RECEBIMENTO]
Clientes=2025-12-06 14:20:00
Pedidos=2025-12-06 14:25:30
```

---

## 🛠️ TECNOLOGIAS UTILIZADAS

- **Delphi XE7+**: Linguagem de programação
- **FireDAC**: Acesso a banco de dados
- **Indy HTTP**: Comunicação HTTP/HTTPS
- **JSON**: Serialização de dados
- **TIniFile**: Gerenciamento de configurações
- **TRegistry**: Integração com Windows
- **TTrayIcon**: Minimização para bandeja

---

## 📞 SUPORTE

- **Email:** suporte@fsvendas.com.br
- **WhatsApp:** (48) 99846-3846
- **Site:** [https://fsvendas.com.br](https://fsvendas.com.br)

---

## 📜 LICENÇA

Proprietary - Todos os direitos reservados © 2025 FSVendas

---

## 👨‍💻 AUTOR

**Sistema FSVendas**
Desenvolvimento: Equipe FSVendas
Data: 2025-12-06
Versão: 1.0

---

## 🎓 APRENDIZADO

Este projeto demonstra:
- Arquitetura em camadas (UI, Business Logic, Data Access)
- Padrão MVC adaptado para Delphi
- Comunicação RESTful com autenticação JWT
- Tratamento robusto de erros
- Logs estruturados
- Interface responsiva com multi-threading
- Integração com sistema operacional (registry, tray icon)

---

**Última atualização:** 2025-12-06
