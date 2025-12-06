# ARQUITETURA SINCRONIZADOR DELPHI - FSVendas

## VISÃO GERAL

Aplicação Desktop Delphi que sincroniza dados entre o ERP local e a API FSVendas Web (PHP).
- **Sincronização Bidirecional**: Envio e recebimento de dados
- **Modos**: Manual (botões) e Automático (timer configurável)
- **Execução em Background**: Tray Icon com minimização
- **Tecnologias**: FireDAC + Indy HTTP + RESTful API + JSON

---

## ESTRUTURA DO PROJETO

### 📁 Estrutura de Arquivos

```
Sincronizador/
├── SincronizadorApp.dpr              // Projeto principal
├── uFormPrincipal.pas/.dfm           // Form principal com 3 abas
├── uConfiguracao.pas                 // Gerenciamento de configurações INI
├── uSincronizacao.pas                // Controlador de sincronização
├── uLogSistema.pas                   // Sistema de logs
├── uSincronizadorApi.pas             // Comunicação com API (JÁ EXISTE)
├── uSincronizar.pas/.dfm             // Unit existente (compatibilidade)
├── uPedidoWeb.pas/.dfm               // Unit existente (compatibilidade)
└── Sincronizador.ini                 // Arquivo de configuração
```

---

## INTERFACE GRÁFICA (3 ABAS)

### ABA 1 - CONFIGURAÇÃO DA API

**Componentes:**
```delphi
TPageControl: pgcPrincipal
  TTabSheet: tsConfiguracao
    TLabeledEdit: edtEndpoint          // URL base da API
    TLabeledEdit: edtChaveAPI          // Chave de autenticação
    TSpinEdit: spnTempo                // Segundos para sincronismo
    TSpinEdit: spnQtdCelulares         // Limite de dispositivos
    TCheckBox: chkIniciarWindows       // Iniciar com Windows
    TCheckBox: chkMinimizarTray        // Minimizar para bandeja
    TButton: btnSalvarConfig           // Salvar configurações
    TButton: btnTestarConexao          // Testar API
    TLabel: lblStatusConexao           // Status do teste
```

**Funcionalidades:**
- Salvar/Carregar configurações do arquivo `Sincronizador.ini`
- Testar conexão com API (obter token JWT)
- Validar endpoint e chave API
- Configurar inicialização automática do Windows (registro)

---

### ABA 2 - O QUE SINCRONIZAR

**Componentes:**
```delphi
TTabSheet: tsSincronizar
  TGroupBox: grpEnviar                 // Envio para nuvem
    TCheckBox: chkEnviarEmpresa        // Empresa/Usuário/Espécies
    TCheckBox: chkEnviarClientes       // Clientes
    TCheckBox: chkEnviarProdutos       // Produtos
    TCheckBox: chkEnviarPedidos        // Pedidos

  TGroupBox: grpReceber                // Recebimento da nuvem
    TCheckBox: chkReceberClientes      // Clientes novos/atualizados
    TCheckBox: chkReceberPedidos       // Pedidos pendentes

  TPanel: pnlAcoes
    TButton: btnEnviarDados            // Enviar selecionados
    TButton: btnReceberDados           // Receber selecionados
    TButton: btnResetarEmpresa         // RESET TOTAL
    TCheckBox: chkSincronizarImagens   // Incluir imagens de produtos

  TGroupBox: grpAutomatico
    TCheckBox: chkSincAutoEnviar       // Auto-enviar
    TCheckBox: chkSincAutoReceber      // Auto-receber
```

**Métodos Suportados por Entidade:**

| Entidade | GET | POST | PUT | DELETE |
|----------|-----|------|-----|--------|
| Empresa/Usuário/Espécies | ❌ | ✅ | ✅ | ❌ |
| Clientes | ✅ | ✅ | ✅ | ❌ |
| Produtos | ❌ | ✅ | ❌ | ❌ |
| Pedidos | ✅ | ✅ | ✅ | ❌ |

**Botão RESETAR EMPRESA:**
- Envia `DELETE /api/empresa/reset`
- Headers: `X-API-Key`, `Authorization: Bearer <token>`
- Apaga TODOS os dados da empresa na nuvem
- Limpa cache local de sincronização
- Confirmação dupla para segurança

---

### ABA 3 - LOGS E PROGRESSO

**Componentes:**
```delphi
TTabSheet: tsLogs
  TMemo: memoLogs                      // Logs em tempo real
    - ReadOnly = True
    - ScrollBars = ssVertical
    - Font = 'Courier New'

  TProgressBar: prgSincronizacao       // Barra de progresso
    - Style = pbstNormal
    - Min = 0
    - Max = 100

  TPanel: pnlLogsAcoes
    TButton: btnLimparLog              // Limpar memo
    TCheckBox: chkSalvarLogsArquivo    // Salvar em arquivo .log
    TButton: btnExportarLog            // Exportar para TXT
```

**Formato do Log:**
```
[2025-12-06 14:35:22] [EMPRESA] POST /api/empresa/sync - Status: 200 - Sucesso
[2025-12-06 14:35:25] [CLIENTES] POST /api/clientes/sync - Status: 200 - 150 registros enviados
[2025-12-06 14:35:28] [PRODUTOS] POST /api/produtos/sync - Status: 400 - Erro: CNPJ inválido
[2025-12-06 14:35:30] [PEDIDOS] GET /api/pedidos/pendentes - Status: 200 - 5 pedidos recebidos
[2025-12-06 14:35:32] [SISTEMA] Sincronização automática concluída
```

**Função Padrão de Log:**
```delphi
procedure AdicionarLog(const AMensagem: string; ATipo: TLogTipo = ltInfo);
```

---

## TRAY ICON E MINIMIZAÇÃO

**Componentes:**
```delphi
TTrayIcon: trayIconSincronizador
TPopupMenu: popupTray
  TMenuItem: mniAbrir                  // Restaurar janela
  TMenuItem: mniSincronizarAgora       // Sincronizar manual
  TMenuItem: mniSeparador              // Separador
  TMenuItem: mniSair                   // Fechar aplicação
```

**Comportamento:**
- `OnMinimize`: Form minimiza para tray (se `chkMinimizarTray` marcado)
- `OnDblClick`: Restaurar janela
- `OnBalloonClick`: Abrir aba de logs
- Notificações balloon:
  - Início da sincronização
  - Erros críticos
  - Conclusão bem-sucedida

---

## SINCRONIZAÇÃO AUTOMÁTICA

**Componentes:**
```delphi
TTimer: tmrSincronizacao
  - Interval: configurável via spnTempo (padrão 300000 ms = 5 min)
  - Enabled: controlado por chkSincAutoEnviar/chkSincAutoReceber
```

**Fluxo do Timer:**
```pascal
procedure TFormPrincipal.tmrSincronizacaoTimer(Sender: TObject);
begin
  if FSincronizandoAgora then Exit; // Evita sobreposição

  FSincronizandoAgora := True;
  try
    AdicionarLog('[SISTEMA] Iniciando sincronização automática');

    // Enviar dados (se habilitado)
    if chkSincAutoEnviar.Checked then
      EnviarDadosSelecionados;

    // Receber dados (se habilitado)
    if chkSincAutoReceber.Checked then
      ReceberDadosSelecionados;

    AdicionarLog('[SISTEMA] Sincronização automática concluída');
  finally
    FSincronizandoAgora := False;
  end;
end;
```

---

## ARQUIVO DE CONFIGURAÇÃO

**Sincronizador.ini**
```ini
[API]
Endpoint=https://api.fsvendas.com.br/api
ChaveAPI=sua-chave-aqui-123456
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
Pedidos=2025-12-06 10:40:12

[ULTIMO_RECEBIMENTO]
Clientes=2025-12-06 14:20:00
Pedidos=2025-12-06 14:25:30
```

**Gerenciamento:**
```delphi
type
  TConfiguracao = class
  private
    FIniFile: TIniFile;
    FCaminho: string;
  public
    constructor Create;
    destructor Destroy; override;

    // Getters
    function GetEndpoint: string;
    function GetChaveAPI: string;
    function GetTempoSincronizacao: Integer;

    // Setters
    procedure SetEndpoint(const AValue: string);
    procedure SetChaveAPI(const AValue: string);
    procedure SetTempoSincronizacao(AValue: Integer);

    // Controle de timestamps
    function GetUltimoEnvio(const AEntidade: string): TDateTime;
    procedure SetUltimoEnvio(const AEntidade: string; AData: TDateTime);
  end;
```

---

## FLUXO DE SINCRONIZAÇÃO

### ENVIO DE DADOS

```
┌─────────────────────────────────────────────────────────────┐
│ ENVIAR DADOS                                                │
├─────────────────────────────────────────────────────────────┤
│ 1. Verificar configurações (endpoint + chave)              │
│ 2. Obter token JWT da API                                   │
│ 3. Para cada entidade marcada:                              │
│    a. Buscar dados do banco local (FireDAC)                 │
│    b. Converter DataSet → JSON (DataSetToJSONArray)         │
│    c. Enviar via POST/PUT                                    │
│    d. Atualizar progress bar                                │
│    e. Registrar log                                         │
│ 4. Se imagens: Enviar separadamente (Base64)                │
│ 5. Atualizar timestamp no INI                               │
│ 6. Notificar conclusão (tray balloon)                       │
└─────────────────────────────────────────────────────────────┘
```

### RECEBIMENTO DE DADOS

```
┌─────────────────────────────────────────────────────────────┐
│ RECEBER DADOS                                               │
├─────────────────────────────────────────────────────────────┤
│ 1. Verificar configurações                                  │
│ 2. Obter token JWT                                          │
│ 3. Para cada entidade marcada:                              │
│    a. Fazer GET na API com last_mod (timestamp)             │
│    b. Receber JSON array                                    │
│    c. Para cada registro JSON:                              │
│       - Verificar se existe (por CODIGO_WEB)                │
│       - INSERT ou UPDATE no banco local                     │
│       - Mapear campos JSON → campos do banco                │
│    d. Atualizar progress bar                                │
│    e. Registrar log                                         │
│ 4. Atualizar timestamp no INI                               │
│ 5. Commit transação                                         │
└─────────────────────────────────────────────────────────────┘
```

### RESET DA EMPRESA

```
┌─────────────────────────────────────────────────────────────┐
│ RESETAR EMPRESA                                             │
├─────────────────────────────────────────────────────────────┤
│ 1. Confirmar ação (MessageDlg duplo)                        │
│    "TEM CERTEZA? TODOS OS DADOS SERÃO APAGADOS!"            │
│ 2. Obter token JWT                                          │
│ 3. Enviar DELETE /api/empresa/reset                         │
│    Headers:                                                 │
│      - X-API-Key: <chave>                                   │
│      - Authorization: Bearer <token>                        │
│ 4. Aguardar resposta                                        │
│ 5. Se sucesso:                                              │
│    - Limpar timestamps do INI                               │
│    - Resetar campo CWEB=0 na tabela EMPRESA                 │
│    - Limpar campo CODIGO_WEB dos clientes/produtos          │
│ 6. Registrar log                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## CLASSES PRINCIPAIS

### 1. TSincronizadorApi (já existe - expandida)

**Responsabilidades:**
- Comunicação HTTP com API
- Autenticação JWT
- Serialização JSON
- Tratamento de erros HTTP

**Métodos Principais:**
```delphi
function ObterTokenDaApi(const ACNPJ, AChave: string): string;
function SincronizarEmpresa(...): Boolean;
function SincronizarClientes(AMetodo: string; ...): Boolean;
function SincronizarProdutos(...): Boolean;
function BaixarPedidosPendentes(...): Boolean;
function MarcarPedidoSincronizado(...): Boolean;
function ResetarEmpresa(const ACNPJ, AChave: string): Boolean;
```

---

### 2. TControladorSincronizacao

**Responsabilidades:**
- Orquestrar sincronização completa
- Controlar progress bar
- Gerenciar logs
- Tratar exceções

**Métodos:**
```delphi
type
  TControladorSincronizacao = class
  private
    FApi: TSincronizadorApi;
    FConfig: TConfiguracao;
    FOnLog: TLogEvent;
    FOnProgress: TProgressEvent;
  public
    procedure EnviarEmpresa;
    procedure EnviarClientes;
    procedure EnviarProdutos;
    procedure ReceberClientes;
    procedure ReceberPedidos;
    procedure ResetarDadosEmpresa;
  end;
```

---

### 3. TLogSistema

**Responsabilidades:**
- Formatar mensagens de log
- Escrever em arquivo (opcional)
- Enviar para interface (memo)

**Tipos de Log:**
```delphi
type
  TLogTipo = (ltInfo, ltAviso, ltErro, ltSucesso);

  TLogSistema = class
  private
    FMemo: TMemo;
    FSalvarArquivo: Boolean;
    FArquivoLog: string;
  public
    procedure AdicionarLog(const AMensagem: string; ATipo: TLogTipo = ltInfo);
    procedure LimparLog;
    procedure ExportarLog(const ACaminho: string);
  end;
```

---

## TRATAMENTO DE ERROS

### Estratégia de Retry

```delphi
function TFormPrincipal.EnviarComRetry(
  AMetodo: TProcedure;
  ATentativas: Integer = 3
): Boolean;
var
  LTentativa: Integer;
begin
  Result := False;
  for LTentativa := 1 to ATentativas do
  begin
    try
      AMetodo;
      Result := True;
      Break;
    except
      on E: EIdHTTPProtocolException do
      begin
        AdicionarLog(Format('[ERRO] Tentativa %d/%d: %s',
          [LTentativa, ATentativas, E.Message]), ltErro);
        if LTentativa = ATentativas then
          raise;
        Sleep(2000 * LTentativa); // Backoff exponencial
      end;
    end;
  end;
end;
```

### Validações

```delphi
procedure ValidarConfiguracao;
begin
  if Trim(edtEndpoint.Text) = '' then
    raise Exception.Create('Endpoint não configurado');

  if not edtEndpoint.Text.ToLower.StartsWith('http') then
    raise Exception.Create('Endpoint inválido (deve iniciar com http/https)');

  if Trim(edtChaveAPI.Text) = '' then
    raise Exception.Create('Chave API não configurada');

  if spnTempo.Value < 30 then
    raise Exception.Create('Tempo mínimo de sincronização: 30 segundos');
end;
```

---

## SEGURANÇA

### 1. Armazenamento de Senha
```delphi
// NÃO armazenar chave API em texto puro
// Usar criptografia simples (XOR, Base64, ou DPAPI)
function CriptografarChave(const AChave: string): string;
function DescriptografarChave(const AChaveCripto: string): string;
```

### 2. Comunicação HTTPS
```delphi
// Sempre usar HTTPS para produção
if not FURLBase.ToLower.StartsWith('https://') then
  ShowMessage('AVISO: Conexão não segura (HTTP). Recomenda-se HTTPS.');
```

### 3. Validação de Token
```delphi
// Token JWT deve ser renovado se expirado
if TokenExpirado(FTokenJWT) then
  FTokenJWT := ObterNovoToken;
```

---

## INICIALIZAÇÃO COM WINDOWS

```delphi
procedure TFormPrincipal.ConfigurarInicioWindows(AHabilitar: Boolean);
var
  LReg: TRegistry;
begin
  LReg := TRegistry.Create(KEY_WRITE);
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    LReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);

    if AHabilitar then
      LReg.WriteString('SincronizadorFSVendas', Application.ExeName)
    else if LReg.ValueExists('SincronizadorFSVendas') then
      LReg.DeleteValue('SincronizadorFSVendas');
  finally
    LReg.Free;
  end;
end;
```

---

## TESTES

### Testes Manuais

**ABA 1 - Configuração:**
1. Testar salvamento/carregamento do INI
2. Validar endpoint inválido
3. Testar conexão com API (botão Testar)
4. Verificar habilitação de inicio com Windows

**ABA 2 - Sincronização:**
1. Enviar empresa (POST)
2. Enviar clientes (POST e PUT)
3. Enviar produtos sem imagens
4. Enviar produtos com imagens
5. Receber clientes novos
6. Receber pedidos pendentes
7. Testar botão Resetar Empresa

**ABA 3 - Logs:**
1. Verificar formato das mensagens
2. Testar limpeza de log
3. Verificar exportação para arquivo
4. Validar progress bar

**Tray Icon:**
1. Minimizar para bandeja
2. Duplo clique para restaurar
3. Menu de contexto
4. Notificações balloon

**Timer:**
1. Configurar tempo de 1 minuto
2. Verificar sincronização automática
3. Garantir que não sobrepõe execuções

---

## PERFORMANCE

### Otimizações

1. **Sincronização em Lotes:**
```delphi
// Enviar produtos em lotes de 100
const TAMANHO_LOTE = 100;
while not qryProdutos.Eof do
begin
  // Processar lote
  for I := 1 to TAMANHO_LOTE do
  begin
    // Adicionar ao array JSON
    if qryProdutos.Eof then Break;
    qryProdutos.Next;
  end;
  // Enviar lote
  EnviarLote;
end;
```

2. **Compressão de Imagens:**
```delphi
procedure RedimensionarImagem(ABitmap: TBitmap; AMaxWidth, AMaxHeight: Integer);
begin
  // Redimensionar para 800x600 antes de enviar
  // Reduz tamanho do Base64
end;
```

3. **Índices no Banco:**
```sql
CREATE INDEX idx_pessoa_codigo_web ON PESSOA(CODIGO_WEB);
CREATE INDEX idx_produto_codigo_web ON PRODUTO(CODIGO_WEB);
CREATE INDEX idx_orcamento_codigo_web ON ORCAMENTO(CODIGO_WEB);
```

---

## COMPATIBILIDADE

A aplicação mantém compatibilidade com as units existentes:
- `uSincronizar.pas` - Pode ser usada standalone
- `uPedidoWeb.pas` - Download de pedidos
- `uSincronizadorApi.pas` - Core de comunicação

---

## ESTRUTURA DE BANCO DE DADOS

### Campos Necessários

**Tabela EMPRESA:**
```sql
ALTER TABLE EMPRESA ADD COLUMN CWEB INTEGER DEFAULT 0;
```

**Tabela PESSOA:**
```sql
ALTER TABLE PESSOA ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;
```

**Tabela PRODUTO:**
```sql
ALTER TABLE PRODUTO ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;
```

**Tabela ORCAMENTO:**
```sql
ALTER TABLE ORCAMENTO ADD COLUMN CODIGO_WEB INTEGER DEFAULT 0;
```

---

## ENDPOINTS DA API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | /api/auth/token | Obter token JWT |
| POST | /api/empresa/sync | Enviar dados da empresa |
| POST | /api/clientes/sync | Enviar clientes |
| PUT | /api/clientes/:id | Atualizar cliente |
| GET | /api/clientes/download | Baixar clientes |
| POST | /api/produtos/sync | Enviar produtos |
| PUT | /api/produtos/:id/imagem | Enviar imagem |
| GET | /api/pedidos/pendentes | Baixar pedidos |
| POST | /api/pedidos/:id/sincronizado | Marcar como sincronizado |
| DELETE | /api/empresa/reset | Resetar empresa |

---

## CONCLUSÃO

Esta arquitetura fornece:
- ✅ Sincronização bidirecional completa
- ✅ Interface intuitiva com 3 abas
- ✅ Execução em background
- ✅ Logs detalhados
- ✅ Configuração flexível
- ✅ Segurança (HTTPS + JWT)
- ✅ Tratamento robusto de erros
- ✅ Performance otimizada
