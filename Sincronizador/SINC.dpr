program SINC;

{*******************************************************************************
  SINC - Sistema de Sincronização ERP ↔ API FSVendas

  Arquitetura Moderna Delphi com:
  - Namespace SINC.*
  - FireDAC (sempre FieldByName)
  - Models (classes)
  - Services (camada de negócio)
  - API (RESTRequest4D)
  - Orquestração (sincronização)
  - Provider (conexão BD)

  Autor: Sistema SINC
  Versão: 1.0
  Data: 2025-12-06
*******************************************************************************}

uses
  Vcl.Forms,
  // Provider
  SINC.Provider.ConexaoBD in 'SINC\Provider\SINC.Provider.ConexaoBD.pas',
  // Models
  SINC.Model.Empresa in 'SINC\Models\SINC.Model.Empresa.pas',
  SINC.Model.Usuario in 'SINC\Models\SINC.Model.Usuario.pas',
  SINC.Model.FormaPagamento in 'SINC\Models\SINC.Model.FormaPagamento.pas',
  SINC.Model.Vendedor in 'SINC\Models\SINC.Model.Vendedor.pas',
  SINC.Model.Pessoa in 'SINC\Models\SINC.Model.Pessoa.pas',
  SINC.Model.Orcamento in 'SINC\Models\SINC.Model.Orcamento.pas',
  SINC.Model.OrcamentoItem in 'SINC\Models\SINC.Model.OrcamentoItem.pas',
  // Services
  SINC.Services.EmpresaService in 'SINC\Services\SINC.Services.EmpresaService.pas',
  SINC.Services.UsuarioService in 'SINC\Services\SINC.Services.UsuarioService.pas',
  SINC.Services.FormaPagamentoService in 'SINC\Services\SINC.Services.FormaPagamentoService.pas',
  SINC.Services.VendedorService in 'SINC\Services\SINC.Services.VendedorService.pas',
  SINC.Services.PessoaService in 'SINC\Services\SINC.Services.PessoaService.pas',
  SINC.Services.OrcamentoService in 'SINC\Services\SINC.Services.OrcamentoService.pas',
  SINC.Services.OrcamentoItemService in 'SINC\Services\SINC.Services.OrcamentoItemService.pas',
  // API
  SINC.API.SincronizadorApi in 'SINC\API\SINC.API.SincronizadorApi.pas',
  // Orquestração
  SINC.Orquestracao.Sincronizador in 'SINC\Orquestracao\SINC.Orquestracao.Sincronizador.pas',
  SINC.Orquestracao.PedidoWeb in 'SINC\Orquestracao\SINC.Orquestracao.PedidoWeb.pas',
  // Forms
  SINC.Forms.Principal in 'SINC\Forms\SINC.Forms.Principal.pas' {FormPrincipalSINC};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SINC - Sincronizador FSVendas';
  Application.CreateForm(TFormPrincipalSINC, FormPrincipalSINC);
  Application.Run;
end.
