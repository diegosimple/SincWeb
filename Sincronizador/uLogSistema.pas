unit uLogSistema;

{*******************************************************************************
  UNIT DE LOGS DO SINCRONIZADOR

  Responsável por:
  - Adicionar mensagens formatadas ao memo de logs
  - Salvar logs em arquivo (opcional)
  - Exportar logs para TXT
  - Limpar logs

  Formato: [2025-12-06 14:35:22] [TIPO] Mensagem

  Autor: Sistema FSVendas
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TLogTipo = (ltInfo, ltAviso, ltErro, ltSucesso, ltSistema);

  TLogSistema = class
  private
    FMemo: TMemo;
    FStatusBar: TStatusBar;
    FSalvarArquivo: Boolean;
    FArquivoLog: string;
    FCaminhoLogs: string;

    function FormatarMensagem(const AMensagem: string; ATipo: TLogTipo): string;
    function GetPrefixoTipo(ATipo: TLogTipo): string;
    procedure SalvarEmArquivo(const AMensagem: string);
    function GetCaminhoArquivoLog: string;
  public
    constructor Create(AMemo: TMemo; AStatusBar: TStatusBar = nil);
    destructor Destroy; override;

    procedure AdicionarLog(const AMensagem: string; ATipo: TLogTipo = ltInfo);
    procedure LimparLog;
    procedure ExportarLog(const ACaminho: string);

    property SalvarArquivo: Boolean read FSalvarArquivo write FSalvarArquivo;
    property CaminhoLogs: string read FCaminhoLogs write FCaminhoLogs;
  end;

implementation

uses
  Winapi.Windows, Vcl.Forms, System.IOUtils;

{ TLogSistema }

constructor TLogSistema.Create(AMemo: TMemo; AStatusBar: TStatusBar);
begin
  inherited Create;
  FMemo := AMemo;
  FStatusBar := AStatusBar;
  FSalvarArquivo := False;

  // Definir caminho padrão dos logs
  FCaminhoLogs := ExtractFilePath(Application.ExeName) + 'Logs\';
  if not DirectoryExists(FCaminhoLogs) then
    ForceDirectories(FCaminhoLogs);

  FArquivoLog := GetCaminhoArquivoLog;
end;

destructor TLogSistema.Destroy;
begin
  inherited;
end;

function TLogSistema.GetCaminhoArquivoLog: string;
begin
  Result := FCaminhoLogs + FormatDateTime('yyyy-mm-dd', Now) + '.log';
end;

function TLogSistema.FormatarMensagem(const AMensagem: string; ATipo: TLogTipo): string;
var
  LDataHora: string;
  LPrefixo: string;
begin
  LDataHora := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
  LPrefixo := GetPrefixoTipo(ATipo);
  Result := Format('[%s] [%s] %s', [LDataHora, LPrefixo, AMensagem]);
end;

function TLogSistema.GetPrefixoTipo(ATipo: TLogTipo): string;
begin
  case ATipo of
    ltInfo:    Result := 'INFO';
    ltAviso:   Result := 'AVISO';
    ltErro:    Result := 'ERRO';
    ltSucesso: Result := 'SUCESSO';
    ltSistema: Result := 'SISTEMA';
  else
    Result := 'INFO';
  end;
end;

procedure TLogSistema.AdicionarLog(const AMensagem: string; ATipo: TLogTipo);
var
  LMensagemFormatada: string;
begin
  if not Assigned(FMemo) then
    Exit;

  LMensagemFormatada := FormatarMensagem(AMensagem, ATipo);

  // Adicionar ao memo (thread-safe)
  TThread.Synchronize(nil,
    procedure
    begin
      FMemo.Lines.Add(LMensagemFormatada);

      // Auto-scroll para o final
      SendMessage(FMemo.Handle, EM_LINESCROLL, 0, FMemo.Lines.Count);

      // Atualizar status bar se disponível
      if Assigned(FStatusBar) and (FStatusBar.Panels.Count > 0) then
        FStatusBar.Panels[0].Text := AMensagem;

      Application.ProcessMessages;
    end
  );

  // Salvar em arquivo se configurado
  if FSalvarArquivo then
    SalvarEmArquivo(LMensagemFormatada);
end;

procedure TLogSistema.SalvarEmArquivo(const AMensagem: string);
var
  LArquivo: TextFile;
begin
  try
    // Atualizar nome do arquivo diariamente
    FArquivoLog := GetCaminhoArquivoLog;

    AssignFile(LArquivo, FArquivoLog);
    if FileExists(FArquivoLog) then
      Append(LArquivo)
    else
      Rewrite(LArquivo);

    try
      WriteLn(LArquivo, AMensagem);
    finally
      CloseFile(LArquivo);
    end;
  except
    on E: Exception do
    begin
      // Não gerar erro se falhar ao salvar log
      // apenas ignorar silenciosamente
    end;
  end;
end;

procedure TLogSistema.LimparLog;
begin
  if Assigned(FMemo) then
  begin
    FMemo.Lines.Clear;
    if Assigned(FStatusBar) and (FStatusBar.Panels.Count > 0) then
      FStatusBar.Panels[0].Text := 'Logs limpos';
  end;
end;

procedure TLogSistema.ExportarLog(const ACaminho: string);
begin
  if not Assigned(FMemo) then
    Exit;

  try
    FMemo.Lines.SaveToFile(ACaminho, TEncoding.UTF8);
  except
    on E: Exception do
      raise Exception.Create('Erro ao exportar log: ' + E.Message);
  end;
end;

end.
