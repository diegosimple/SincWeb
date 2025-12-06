program SincronizadorApp;

{*******************************************************************************
  SINCRONIZADOR FSVENDAS - Aplicação Desktop Delphi

  Sincronização bidirecional entre ERP local e API FSVendas Web

  Recursos:
  - Interface com 3 abas (Configuração, Sincronização, Logs)
  - Tray Icon com minimização
  - Timer para sincronização automática
  - Sistema completo de logs
  - Gerenciamento de configurações via INI
  - Suporte a HTTPS + autenticação JWT
  - Progress bar e notificações

  Autor: Sistema FSVendas
  Versão: 1.0
  Data: 2025-12-06
*******************************************************************************}

uses
  Vcl.Forms,
  uFormPrincipal in 'uFormPrincipal.pas' {FormPrincipal},
  uConfiguracao in 'uConfiguracao.pas',
  uLogSistema in 'uLogSistema.pas',
  uSincronizacao in 'uSincronizacao.pas',
  uSincronizadorApi in 'uSincronizadorApi.pas',
  uSincronizar in 'uSincronizar.pas' {FrmSincronizar},
  uPedidoWeb in 'uPedidoWeb.pas' {FrmPedidoWeb},
  Udados in '..\Udados.pas' {Dados: TDataModule},
  uDadosWeb in '..\uDadosWeb.pas' {dadosWeb: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Sincronizador FSVendas';
  Application.CreateForm(TDados, Dados);
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
