# SINC - Sistema de Sincronização ERP ↔ API FSVendas

Sistema Delphi completo para sincronização bidirecional entre ERP local (Firebird) e API FSVendas na nuvem.

## 📁 Arquitetura do Projeto

```
Sincronizador/
├── SINC/
│   ├── Provider/
│   │   └── SINC.Provider.ConexaoBD.pas        # Conexão FireDAC (Singleton)
│   ├── Models/
│   │   ├── SINC.Model.Empresa.pas             # Model Empresa
│   │   ├── SINC.Model.Usuario.pas             # Model Usuario
│   │   ├── SINC.Model.FormaPagamento.pas      # Model Forma de Pagamento
│   │   ├── SINC.Model.Vendedor.pas            # Model Vendedor
│   │   ├── SINC.Model.Pessoa.pas              # Model Pessoa/Cliente
│   │   ├── SINC.Model.Orcamento.pas           # Model Orçamento
│   │   └── SINC.Model.OrcamentoItem.pas       # Model Item de Orçamento
│   ├── Services/
│   │   ├── SINC.Services.EmpresaService.pas
│   │   ├── SINC.Services.UsuarioService.pas
│   │   ├── SINC.Services.FormaPagamentoService.pas
│   │   ├── SINC.Services.VendedorService.pas
│   │   ├── SINC.Services.PessoaService.pas
│   │   ├── SINC.Services.OrcamentoService.pas
│   │   └── SINC.Services.OrcamentoItemService.pas
│   ├── API/
│   │   └── SINC.API.SincronizadorApi.pas      # RESTRequest4D
│   ├── Orquestracao/
│   │   ├── SINC.Orquestracao.Sincronizador.pas
│   │   └── SINC.Orquestracao.PedidoWeb.pas
│   └── Forms/
│       ├── SINC.Forms.Principal.pas
│       └── SINC.Forms.Principal.dfm
├── SINC.dpr                                    # Projeto Principal
├── Sincronizador.ini.exemplo                   # Arquivo de configuração
└── README_SINC.md                              # Esta documentação
```

## 🎯 Características

### ✅ Implementações Obrigatórias

- ✅ **Namespace SINC.***: Todas as units utilizam o prefixo SINC
- ✅ **FireDAC**: Uso exclusivo do FireDAC para acesso ao banco
- ✅ **FieldByName SEMPRE**: Nenhum acesso direto a Fields[] ou Fields.Items[]
- ✅ **Classes Model**: 7 models completos (TEmpresa, TUsuario, TFormaPagamento, etc)
- ✅ **Camada Service**: CRUD completo para cada entidade
- ✅ **Camada API**: Comunicação HTTP via RESTRequest4D
- ✅ **Camada Orquestração**: Controle de sincronização
- ✅ **Provider de Conexão**: Singleton para gerenciar conexão BD
- ✅ **Form com 3 Abas**: Configuração, Sincronização, Logs
- ✅ **Timer**: Sincronização automática configurável
- ✅ **Tray Icon**: Minimizar para bandeja do sistema

### 🔄 Fluxo de Dados

```
┌─────────────────────────────────────────────────────────┐
│                    ARQUITETURA SINC                     │
└─────────────────────────────────────────────────────────┘

ENVIO (Local → API):
DataSet → Model.FromDataSet() → Model.ToJSON() → API → Nuvem

RECEBIMENTO (API → Local):
Nuvem → API → JSON → Model.FromJSON() → Service.Salvar() → BD

REGRA FUNDAMENTAL:
❌ NUNCA: DataSet → API
✅ SEMPRE: DataSet → Model → JSON → API
```

## 🚀 Como Usar

### 1. Configuração Inicial

1. Copie `Sincronizador.ini.exemplo` para `Sincronizador.ini`
2. Edite o arquivo e configure:

```ini
[API]
Endpoint=https://api.fsvendas.com.br
ChaveAPI=SUA_CHAVE_API_AQUI

[BANCO_DADOS]
Servidor=localhost
Porta=3050
Database=C:\DADOS\BANCO.FDB
Usuario=SYSDBA
Senha=masterkey

[SYNC]
TempoSegundos=300

[CONFIG]
QtdCelulares=5
```

### 2. Compilação

Requer:
- Delphi XE7 ou superior
- FireDAC
- RESTRequest4D (Boss install)

```bash
# Instalar dependências via Boss
boss install horse
boss install dataset-serialize
boss install RESTRequest4D
```

### 3. Interface

#### ABA 1 - Configuração

- Endpoint da API
- Chave API
- Tempo de sincronização (segundos)
- Quantidade de celulares permitidos
- Opções de inicialização

**Botões:**
- **Salvar Configuração**: Grava no INI
- **Testar Conexão**: Valida comunicação com API

#### ABA 2 - Sincronização

**Checkboxes:**
- ☑ Empresa (POST/PUT)
- ☑ Usuário (POST/PUT)
- ☑ Vendedores (POST/PUT)
- ☑ Formas de Pagamento (POST/PUT)
- ☑ Clientes (GET/POST/PUT)
- ☐ Produtos (POST)
- ☑ Pedidos (GET/POST/PUT)

**Botões:**
- **Enviar Dados**: Envia apenas dados selecionados
- **Receber Dados**: Busca dados da API
- **Reset Empresa**: DELETE na API (cuidado!)
- **SINCRONIZAR AGORA**: Envio + Recebimento completo

#### ABA 3 - Logs

- Visualização de logs em tempo real
- Data/Hora de última sincronização
- Botão para limpar log

### 4. Tray Icon

Clique direito no ícone da bandeja:
- **Restaurar Janela**: Volta para tela principal
- **Sincronizar Agora**: Executa sincronização imediata
- **Pausar/Retomar**: Liga/desliga timer automático
- **Sair**: Fecha o aplicativo

## 🔧 Funcionalidades por Camada

### Provider (SINC.Provider.ConexaoBD)

```pascal
var
  Conexao: TConexaoBD;
  Query: TFDQuery;
begin
  Conexao := TConexaoBD.GetInstance;
  Query := Conexao.NovaQuery;
  try
    Query.SQL.Text := 'SELECT * FROM EMPRESA WHERE CODIGO = :CODIGO';
    Query.ParamByName('CODIGO').AsInteger := 1;
    Query.Open;

    // SEMPRE usar FieldByName
    ShowMessage(Query.FieldByName('FANTASIA').AsString);
  finally
    Query.Free;
  end;
end;
```

### Models

Todos os Models implementam:

```pascal
procedure FromDataSet(AQry: TFDQuery);  // BD → Model
procedure FromJSON(AJSON: TJSONObject); // JSON → Model
function ToJSON: TJSONObject;           // Model → JSON
procedure Salvar;                       // Chama Service
```

Exemplo:

```pascal
var
  Empresa: TEmpresa;
  Qry: TFDQuery;
begin
  Qry := Conexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM EMPRESA WHERE CODIGO = 1';
    Qry.Open;

    Empresa := TEmpresa.Create;
    try
      Empresa.FromDataSet(Qry);  // FieldByName usado internamente
      Empresa.Fantasia := 'Nova Razão Social';
      Empresa.Salvar;
    finally
      Empresa.Free;
    end;
  finally
    Qry.Free;
  end;
end;
```

### Services

Cada Service implementa:

```pascal
function BuscarPorCodigo(ACodigo: Integer): TModel;
function ListarParaEnvio: TObjectList<TModel>;
procedure SalvarOuAtualizar(AModel: TModel);
function Existe(ACodigo: Integer): Boolean;
function ProximoCodigo: Integer;
```

### API (SINC.API.SincronizadorApi)

Comunicação HTTP com a API:

```pascal
var
  API: TSincronizadorApi;
  Empresa: TEmpresa;
begin
  API := TSincronizadorApi.Create;
  try
    Empresa := TEmpresa.Create;
    try
      Empresa.Codigo := 1;
      Empresa.Fantasia := 'Minha Empresa';
      // ...

      if API.EnviarEmpresa(Empresa) then
        ShowMessage('Empresa enviada com sucesso!');
    finally
      Empresa.Free;
    end;
  finally
    API.Free;
  end;
end;
```

### Orquestração (SINC.Orquestracao.Sincronizador)

Controla o fluxo completo:

```pascal
var
  Sinc: TSincronizador;
begin
  Sinc := TSincronizador.Create;
  try
    Sinc.OnLog := procedure(const AMsg: string)
    begin
      Memo1.Lines.Add(AMsg);
    end;

    // Sincronização completa
    Sinc.SincronizarTudo;

    // Ou parcial
    Sinc.EnviarEmpresa;
    Sinc.ReceberClientes;
  finally
    Sinc.Free;
  end;
end;
```

### Pedidos Web (SINC.Orquestracao.PedidoWeb)

Processa pedidos da API:

1. Busca pedidos pendentes na API
2. Valida se cliente existe local (senão baixa da API)
3. Cria orçamento local
4. Cria itens do orçamento
5. Atualiza status na API ("sincronizado")

```pascal
var
  PedidoWeb: TPedidoWeb;
begin
  PedidoWeb := TPedidoWeb.Create;
  try
    PedidoWeb.OnLog := AdicionarLog;
    PedidoWeb.BuscarPedidosPendentes;
  finally
    PedidoWeb.Free;
  end;
end;
```

## 📊 Endpoints da API

| Entidade          | Envio (POST/PUT) | Recebimento (GET) |
|-------------------|------------------|-------------------|
| Empresa           | `/empresa`       | `/empresa`        |
| Usuários          | `/usuarios`      | `/usuarios`       |
| Vendedores        | `/vendedores`    | -                 |
| Formas Pagamento  | `/formas-pagamento` | `/formas-pagamento` |
| Clientes          | `/clientes`      | `/clientes`       |
| Orçamentos        | `/orcamentos`    | `/orcamentos`     |
| Pedidos Pendentes | -                | `/pedidos/pendentes` |

## 🔒 Segurança

- Autenticação via Header: `X-API-KEY`
- Senha armazenada com `PasswordChar` no form
- Conexão HTTPS obrigatória
- Timeout de 30 segundos nas requisições

## 📝 Exemplos de SQL (com FieldByName)

### INSERT

```pascal
Qry.SQL.Text := 'INSERT INTO EMPRESA (CODIGO, FANTASIA, RAZAO, CNPJ) ' +
                'VALUES (:CODIGO, :FANTASIA, :RAZAO, :CNPJ)';
Qry.ParamByName('CODIGO').AsInteger := Empresa.Codigo;
Qry.ParamByName('FANTASIA').AsString := Empresa.Fantasia;
Qry.ParamByName('RAZAO').AsString := Empresa.Razao;
Qry.ParamByName('CNPJ').AsString := Empresa.CNPJ;
Qry.ExecSQL;
```

### UPDATE

```pascal
Qry.SQL.Text := 'UPDATE PESSOA SET FANTASIA = :FANTASIA, CNPJ = :CNPJ ' +
                'WHERE EMPRESA = :EMPRESA AND CODIGO = :CODIGO';
Qry.ParamByName('FANTASIA').AsString := Pessoa.Fantasia;
Qry.ParamByName('CNPJ').AsString := Pessoa.CNPJ;
Qry.ParamByName('EMPRESA').AsInteger := Pessoa.Empresa;
Qry.ParamByName('CODIGO').AsInteger := Pessoa.Codigo;
Qry.ExecSQL;
```

### SELECT

```pascal
Qry.SQL.Text := 'SELECT * FROM ORCAMENTO WHERE CODIGO = :CODIGO';
Qry.ParamByName('CODIGO').AsInteger := ACodigoOrcamento;
Qry.Open;

if not Qry.IsEmpty then
begin
  Orcamento.Codigo := Qry.FieldByName('CODIGO').AsInteger;
  Orcamento.Cliente := Qry.FieldByName('CLIENTE').AsString;
  Orcamento.Total := Qry.FieldByName('TOTAL').AsFloat;
end;
```

## 🐛 Troubleshooting

### Erro: "Arquivo de configuração não encontrado"

- Certifique-se que `Sincronizador.ini` existe no mesmo diretório do executável

### Erro: "Erro ao conectar ao banco de dados"

- Verifique se o Firebird está rodando
- Confirme caminho do banco no INI
- Teste usuário/senha

### Erro: "Endpoint da API não configurado"

- Edite o INI e preencha `[API] Endpoint=...`
- Clique em "Salvar Configuração" no form

### Erro: "Falha na conexão com API"

- Verifique se o endpoint está correto
- Teste a Chave API
- Verifique se há firewall bloqueando

## 📄 Licença

Sistema desenvolvido para uso interno.

## 👨‍💻 Suporte

Para dúvidas ou problemas, entre em contato com a equipe de desenvolvimento.

---

**Versão:** 1.0
**Data:** 2025-12-06
**Autor:** Sistema SINC
