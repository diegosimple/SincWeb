<?php
class ClientesController {

    /**
     * Listar todos os clientes
     * GET /api/clientes
     */
    public function getAll() {
        $codEmp = $_GET['codEmp'] ?? ($GLOBALS['cod_emp'] ?? null);

        try {
            $db = Database::getInstance()->getConnection();

            // Nota: A tabela no banco MySQL da nuvem é "clientes" (sem _sf)
            $sql = "SELECT * FROM clientes";
            $params = [];

            if ($codEmp) {
                $sql .= " WHERE codemp = :codEmp";
                $params['codEmp'] = $codEmp;
            }

            $sql .= " ORDER BY razao_nome";

            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            $clientes = $stmt->fetchAll();

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'data' => $clientes,
                'count' => count($clientes)
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao buscar clientes',
                'message' => ENVIRONMENT === 'dev' ? $e->getMessage() : null
            ]);
        }
    }

    /**
     * Buscar cliente por ID
     * GET /api/clientes/{id}
     */
    public function getById($id) {
        try {
            $db = Database::getInstance()->getConnection();
            $codEmp = $GLOBALS['cod_emp'] ?? null;

            // Nota: A tabela no banco MySQL da nuvem é "clientes" (sem _sf)
            $sql = "SELECT * FROM clientes WHERE codigo = :id";
            $params = ['id' => $id];

            if ($codEmp) {
                $sql .= " AND codemp = :codEmp";
                $params['codEmp'] = $codEmp;
            }

            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            $cliente = $stmt->fetch();

            if (!$cliente) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Cliente não encontrado'
                ]);
                return;
            }

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'data' => $cliente
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao buscar cliente',
                'message' => ENVIRONMENT === 'dev' ? $e->getMessage() : null
            ]);
        }
    }

    /**
     * Criar novo cliente
     * POST /api/clientes
     */
    public function create() {
        $data = json_decode(file_get_contents('php://input'), true);
    
        // Log detalhado em DEV
        if (defined('ENVIRONMENT') && ENVIRONMENT === 'dev') {
            error_log('=== ClientesController::create ===');
            error_log('Dados recebidos: ' . json_encode($data, JSON_PRETTY_PRINT));
            error_log('Headers: ' . json_encode(getallheaders(), JSON_PRETTY_PRINT));
        }
    
        try {
            $db = Database::getInstance()->getConnection();
            $codEmp = $data['CodEmp'] ?? ($GLOBALS['cod_emp'] ?? null);
    
            // Validações
            if (!$codEmp) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Código da empresa (CodEmp) é obrigatório',
                    'data_received' => $data
                ]);
                return;
            }
    
            if (!isset($data['Codigo']) || empty($data['Codigo'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Código do cliente é obrigatório',
                    'data_received' => $data
                ]);
                return;
            }
    
            if (!isset($data['Razao_Nome']) || empty($data['Razao_Nome'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Razão/Nome do cliente é obrigatório',
                    'data_received' => $data
                ]);
                return;
            }
    
            // Verificar se já existe
            $stmtCheck = $db->prepare("
                SELECT codigo FROM clientes 
                WHERE codigo = :codigo AND codemp = :codemp
                LIMIT 1
            ");
            $stmtCheck->execute([
                'codigo' => $data['Codigo'],
                'codemp' => $codEmp
            ]);
            $existente = $stmtCheck->fetch();
    
            if ($existente) {
                // UPDATE
                $stmt = $db->prepare("
                    UPDATE clientes SET
                        razao_nome = :razao_nome,
                        apelido_fantasia = :apelido_fantasia,
                        cpf_cnpj = :cpf_cnpj,
                        cidade = :cidade,
                        uf = :uf,
                        fone = :fone,
                        celular = :celular,
                        cli_obs = :cli_obs,
                        endereco = :endereco,
                        endereco_numero = :endereco_numero,
                        Complemento = :Complemento,
                        bairro = :bairro,
                        cep = :cep,
                        cweb = :cweb,
                        last_mod = NOW()
                    WHERE codigo = :codigo AND codemp = :codemp
                ");
            } else {
                // INSERT
                $stmt = $db->prepare("
                    INSERT INTO clientes (
                        codigo, razao_nome, apelido_fantasia, cpf_cnpj, cidade, uf,
                        fone, celular, cli_obs, endereco, endereco_numero, Complemento,
                        bairro, cep, codemp, cweb, last_mod
                    )
                    VALUES (
                        :codigo, :razao_nome, :apelido_fantasia, :cpf_cnpj, :cidade, :uf,
                        :fone, :celular, :cli_obs, :endereco, :endereco_numero, :Complemento,
                        :bairro, :cep, :codemp, :cweb, NOW()
                    )
                ");
            }
    
            $stmt->execute([
                'codigo' => $data['Codigo'],
                'razao_nome' => $data['Razao_Nome'] ?? '',
                'apelido_fantasia' => $data['Apelido_Fantasia'] ?? null,
                'cpf_cnpj' => $data['Cpf_Cnpj'] ?? null,
                'cidade' => $data['Cidade'] ?? null,
                'uf' => $data['UF'] ?? null,
                'fone' => $data['Fone'] ?? null,
                'celular' => $data['Celular'] ?? null,
                'cli_obs' => $data['Cli_Obs'] ?? null,
                'endereco' => $data['endereco'] ?? null,
                'endereco_numero' => $data['endereco_numero'] ?? null,
                'Complemento' => $data['Complemento'] ?? null,
                'bairro' => $data['bairro'] ?? null,
                'cep' => $data['cep'] ?? null,
                'codemp' => $codEmp,
                'cweb' => $data['Codigo'], // cweb = código do cliente
            ]);
    
            if (defined('ENVIRONMENT') && ENVIRONMENT === 'dev') {
                error_log('Cliente salvo com sucesso: ' . $data['Codigo']);
            }
    
            http_response_code($existente ? 200 : 201);
            echo json_encode([
                'success' => true,
                'message' => $existente ? 'Cliente atualizado com sucesso' : 'Cliente criado com sucesso',
                'codigo' => $data['Codigo']
            ]);
    
        } catch (Exception $e) {
            error_log('ERRO ClientesController::create: ' . $e->getMessage());
            error_log('Stack trace: ' . $e->getTraceAsString());
            
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao salvar cliente',
                'message' => ENVIRONMENT === 'dev' ? $e->getMessage() : 'Erro interno do servidor',
                'trace' => ENVIRONMENT === 'dev' ? $e->getTraceAsString() : null
            ]);
        }
    }

    public function syncClientes() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
    
            // Validações
            if (empty($data['cnpj'])) {
                http_response_code(400);
                echo json_encode(['status' => false, 'mensagem' => 'CNPJ é obrigatório']);
                return;
            }
    
            if (empty($data['chave_api'])) {
                http_response_code(400);
                echo json_encode(['status' => false, 'mensagem' => 'Chave API é obrigatória']);
                return;
            }
    
            if (empty($data['codemp'])) {
                http_response_code(400);
                echo json_encode(['status' => false, 'mensagem' => 'Código da empresa é obrigatório']);
                return;
            }
    
            if (empty($data['clientes']) || !is_array($data['clientes'])) {
                http_response_code(400);
                echo json_encode(['status' => false, 'mensagem' => 'Lista de clientes é obrigatória']);
                return;
            }
    
            $cnpj = $data['cnpj'];
            $chaveApi = $data['chave_api'];
            $codemp = (int)$data['codemp'];
            $clientes = $data['clientes'];
    
            $db = Database::getInstance()->getConnection();
    
            // Validar empresa e chave API
            $stmtEmpresa = $db->prepare("SELECT codemp, `key` FROM empresas WHERE cnpj = :cnpj LIMIT 1");
            $stmtEmpresa->execute(['cnpj' => $cnpj]);
            $empresa = $stmtEmpresa->fetch(PDO::FETCH_ASSOC);
    
            if (!$empresa) {
                throw new Exception('Empresa não encontrada');
            }
    
            if ($empresa['key'] !== $chaveApi) {
                throw new Exception('Chave API inválida');
            }
    
            if ($empresa['codemp'] != $codemp) {
                throw new Exception('Código da empresa não corresponde ao CNPJ informado');
            }
    
            // Iniciar transação
            $db->beginTransaction();
    
            try {
                $totalSincronizados = 0;
    
                // Preparar statement para INSERT/UPDATE
                $stmtCliente = $db->prepare("
                    INSERT INTO clientes (
                        codemp, codigo, razao_nome, apelido_fantasia, cpf_cnpj,
                        endereco, endereco_numero, Complemento, bairro, cep,
                        cidade, uf, Fone, Celular, cli_Obs, last_mod
                    ) VALUES (
                        :codemp, :codigo, :razao_nome, :apelido_fantasia, :cpf_cnpj,
                        :endereco, :endereco_numero, :Complemento, :bairro, :cep,
                        :cidade, :uf, :Fone, :Celular, :cli_Obs, NOW()
                    )
                    ON DUPLICATE KEY UPDATE
                        razao_nome = VALUES(razao_nome),
                        apelido_fantasia = VALUES(apelido_fantasia),
                        cpf_cnpj = VALUES(cpf_cnpj),
                        endereco = VALUES(endereco),
                        endereco_numero = VALUES(endereco_numero),
                        Complemento = VALUES(Complemento),
                        bairro = VALUES(bairro),
                        cep = VALUES(cep),
                        cidade = VALUES(cidade),
                        uf = VALUES(uf),
                        Fone = VALUES(Fone),
                        Celular = VALUES(Celular),
                        cli_Obs = VALUES(cli_Obs),
                        last_mod = NOW()
                ");
    
                // Processar cada cliente
                foreach ($clientes as $cliente) {
                    $stmtCliente->execute([
                        'codemp'           => $codemp,
                        'codigo'           => $cliente['codigo'] 
                                              ?? ($cliente['CODIGO'] ?? 0),
                        'razao_nome'       => $cliente['razao_nome'] ?? ($cliente['RAZAO_NOME'] ?? ''),
                        'apelido_fantasia' => $cliente['apelido_fantasia'] ?? ($cliente['APELIDO_FANTASIA'] ?? ''),
                        'cpf_cnpj'         => $cliente['cpf_cnpj'] ?? ($cliente['CPF_CNPJ'] ?? ''),
                        'endereco'         => $cliente['endereco'] ?? ($cliente['ENDERECO'] ?? ''),
                        'endereco_numero'  => $cliente['endereco_numero'] ?? ($cliente['ENDERECO_NUMERO'] ?? ''),
                        'Complemento'      => $cliente['Complemento'] ?? ($cliente['COMPLEMENTO'] ?? ''),
                        'bairro'           => $cliente['bairro'] ?? ($cliente['BAIRRO'] ?? ''),
                        'cep'              => $cliente['cep'] ?? ($cliente['CEP'] ?? ''),
                        'cidade'           => $cliente['cidade'] ?? ($cliente['CIDADE'] ?? ''),
                        'uf'               => $cliente['uf'] ?? ($cliente['UF'] ?? ''),
                        'Fone'             => $cliente['Fone'] ?? ($cliente['FONE'] ?? ''),
                        'Celular'          => $cliente['Celular'] ?? ($cliente['CELULAR'] ?? ''),
                        'cli_Obs'          => $cliente['cli_Obs'] ?? ($cliente['CLI_OBS'] ?? '')
                    ]);
    
                    $totalSincronizados++;
                }
    
                // Commit
                $db->commit();
    
                http_response_code(200);
                echo json_encode([
                    'status' => true,
                    'mensagem' => 'Clientes sincronizados com sucesso',
                    'total_sincronizados' => $totalSincronizados
                ]);
    
            } catch (Exception $e) {
                $db->rollBack();
                throw $e;
            }
    
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'status' => false,
                'mensagem' => $e->getMessage()
            ]);
        }
    }

    /**
     * Atualizar cliente
     * PUT /api/clientes/{id}
     */
    public function update($id) {
        $data = json_decode(file_get_contents('php://input'), true);
        $codEmp = $GLOBALS['cod_emp'] ?? null;

        try {
            $db = Database::getInstance()->getConnection();

            // Nota: A tabela no banco MySQL da nuvem é "clientes" (sem _sf)
            $stmt = $db->prepare("
                UPDATE clientes SET
                    razao_nome = :razao_nome,
                    apelido_fantasia = :apelido_fantasia,
                    cpf_cnpj = :cpf_cnpj,
                    cidade = :cidade,
                    uf = :uf,
                    fone = :fone,
                    celular = :celular,
                    cli_obs = :cli_obs,
                    endereco = :endereco,
                    endereco_numero = :endereco_numero,
                    Complemento = :Complemento,
                    bairro = :bairro,
                    cep = :cep,
                    cweb = :cweb,
                    last_mod = NOW()
                WHERE codigo = :id AND codemp = :codemp
            ");

            $stmt->execute([
                'razao_nome' => $data['Razao_Nome'] ?? '',
                'apelido_fantasia' => $data['Apelido_Fantasia'] ?? null,
                'cpf_cnpj' => $data['Cpf_Cnpj'] ?? null,
                'cidade' => $data['Cidade'] ?? null,
                'uf' => $data['UF'] ?? null,
                'fone' => $data['Fone'] ?? null,
                'celular' => $data['Celular'] ?? null,
                'cli_obs' => $data['Cli_Obs'] ?? null,
                'endereco' => $data['endereco'] ?? null,
                'endereco_numero' => $data['endereco_numero'] ?? null,
                'Complemento' => $data['Complemento'] ?? null,
                'bairro' => $data['bairro'] ?? null,
                'cep' => $data['cep'] ?? null,
                'cweb' => $data['cweb'] ?? null,
                'id' => $id,
                'codemp' => $codEmp
            ]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Cliente não encontrado'
                ]);
                return;
            }

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'message' => 'Cliente atualizado com sucesso'
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao atualizar cliente',
                'message' => ENVIRONMENT === 'dev' ? $e->getMessage() : null
            ]);
        }
    }

    public function download()
    {
        try {
            $db = $this->getDb();
            
            // Pega codemp do header
            $codemp = $this->getCodempFromHeaders();
            
            if (!$codemp) {
                $this->sendError('Código da empresa não informado', 400);
                return;
            }

            // Pega parâmetros opcionais
            $lastMod = $_GET['last_mod'] ?? null;
            
            // Montar query
            $sql = "
                SELECT 
                    codemp,
                    codigo,
                    razao_nome,
                    apelido_fantasia,
                    cpf_cnpj,
                    endereco,
                    endereco_numero,
                    Complemento,
                    bairro,
                    cep,
                    cidade,
                    uf,
                    fone,
                    celular,
                    cli_obs,
                    last_mod,
                    cweb
                FROM clientes
                WHERE codemp = :codemp
            ";
            
            $params = ['codemp' => $codemp];
            
            // Se tiver last_mod, busca apenas registros novos/alterados
            if ($lastMod) {
                $sql .= " AND last_mod > :last_mod";
                $params['last_mod'] = $lastMod;
            }
            
            $sql .= " ORDER BY codigo";
            
            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            $clientes = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $this->sendSuccess([
                'total' => count($clientes),
                'clientes' => $clientes,
                'last_sync' => date('Y-m-d H:i:s')
            ]);

        } catch (Exception $e) {
            error_log("Erro ao buscar clientes para download: " . $e->getMessage());
            $this->sendError('Erro ao buscar clientes: ' . $e->getMessage(), 500);
        }
    }
}
