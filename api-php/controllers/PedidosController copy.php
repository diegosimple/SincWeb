<?php
class PedidosController {

    /**
     * Listar todos os pedidos
     * GET /api/pedidos
     */
    public function getAll() {
        $codEmp = $_GET['codEmp'] ?? ($GLOBALS['cod_emp'] ?? null);

        try {
            $db = Database::getInstance()->getConnection();

            $sql = "
                SELECT
                    p.*,
                    c.razao_nome as Cliente_Nome
                FROM pedidos p
                LEFT JOIN clientes c ON p.Cod_Cliente = c.codigo AND p.CodEmp = c.codemp
            ";
            $params = [];

            if ($codEmp) {
                $sql .= " WHERE p.CodEmp = :codEmp";
                $params['codEmp'] = $codEmp;
            }

            $sql .= " ORDER BY p.Data_Venda DESC";

            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            $pedidos = $stmt->fetchAll();

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'data' => $pedidos,
                'count' => count($pedidos)
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao buscar pedidos',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * Buscar pedido por ID com itens
     * GET /api/pedidos/{id}
     */
    public function getById($id) {
        try {
            $db = Database::getInstance()->getConnection();

            // Buscar pedido
            $stmt = $db->prepare("
                SELECT
                    p.*,
                    c.razao_nome as Cliente_Nome
                FROM pedidos p
                LEFT JOIN clientes c ON p.Cod_Cliente = c.codigo AND p.CodEmp = c.codemp
                WHERE p.Cod_Pedido = :id
            ");
            $stmt->execute(['id' => $id]);
            $pedido = $stmt->fetch();

            if (!$pedido) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Pedido não encontrado'
                ]);
                return;
            }

            // Buscar itens do pedido
            $stmt = $db->prepare("
                SELECT
                    pi.*,
                    pr.mercadoria as Produto_Descricao
                FROM pedido_item pi
                LEFT JOIN produtos pr ON pi.CodigoProduto = pr.id AND pi.CodEmp = pr.codemp
                WHERE pi.Cod_Pedido = :pedidoId AND pi.CodEmp = :codEmp
            ");
            $stmt->execute([
                'pedidoId' => $id,
                'codEmp' => $pedido['CodEmp']
            ]);
            $itens = $stmt->fetchAll();

            $pedido['itens'] = $itens;

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'data' => $pedido
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao buscar pedido',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * Sincronizar pedidos pendentes (receber do app)
     * POST /api/pedidos/sync
     * 
     * MAPEAMENTO ENTRE TABELAS:
     * App (SQLite) → Nuvem (MySQL)
     * pedidos_sf → pedidos
     * pedidos_itens_sf → pedido_item
     */
    public function syncPendentes() {
        $rawInput = file_get_contents('php://input');
        $data = json_decode($rawInput, true);
        
        // Logs apenas em ambiente de desenvolvimento
        if (defined('ENVIRONMENT') && ENVIRONMENT === 'dev') {
            error_log("=== INICIO syncPendentes ===");
            error_log("Headers recebidos: " . json_encode(getallheaders()));
            error_log("Raw Input Length: " . strlen($rawInput));
            error_log("Raw Input (primeiros 1000 chars): " . substr($rawInput, 0, 1000));
            error_log("JSON decodificado com sucesso: " . (is_array($data) ? 'SIM' : 'NAO'));
            
            if (isset($data['pedidos'])) {
                error_log("Pedidos recebidos: " . count($data['pedidos']));
                if (count($data['pedidos']) > 0) {
                    error_log("Primeiro pedido (resumo): " . json_encode([
                        'Numero_Pedido' => $data['pedidos'][0]['Numero_Pedido'] ?? null,
                        'CodCliente' => $data['pedidos'][0]['CodCliente'] ?? null,
                        'CodEmp' => $data['pedidos'][0]['CodEmp'] ?? null,
                        'Valor_Total' => $data['pedidos'][0]['Valor_Total'] ?? null,
                        'itens_count' => count($data['pedidos'][0]['itens'] ?? [])
                    ]));
                }
            } else {
                error_log("ERRO: Campo 'pedidos' não encontrado em data");
            }
        }

        if (!isset($data['pedidos']) || !is_array($data['pedidos'])) {
            error_log("ERRO: Lista de pedidos inválida");
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'error' => 'Lista de pedidos inválida'
            ]);
            return;
        }

        $results = [
            'success' => [],
            'errors' => []
        ];

        $db = Database::getInstance()->getConnection();

        foreach ($data['pedidos'] as $index => $pedidoData) {
            try {
                error_log("=== Processando pedido index $index ===");
                error_log("Pedido Numero_Pedido: " . ($pedidoData['Numero_Pedido'] ?? 'null'));
                
                $db->beginTransaction();

                // GERAR PRÓXIMO Cod_Pedido (AUTO INCREMENT POR EMPRESA)
                // Usa COALESCE para retornar 1 se não houver pedidos ainda
                $stmt = $db->prepare("
                    SELECT COALESCE(MAX(Cod_Pedido), 0) + 1 as ProximoCodigo
                    FROM pedidos 
                    WHERE CodEmp = :codEmp
                ");
                $stmt->execute(['codEmp' => $pedidoData['CodEmp']]);
                $resultado = $stmt->fetch();
                $proximoCodPedido = $resultado['ProximoCodigo'];
                
                error_log("Próximo Cod_Pedido gerado: $proximoCodPedido para CodEmp: " . $pedidoData['CodEmp']);

                // BUSCAR NOME DO CLIENTE
                $stmtCliente = $db->prepare("
                    SELECT razao_nome FROM clientes 
                    WHERE codigo = :codigo AND codemp = :codemp 
                    LIMIT 1
                ");
                $stmtCliente->execute([
                    'codigo' => $pedidoData['CodCliente'],
                    'codemp' => $pedidoData['CodEmp']
                ]);
                $cliente = $stmtCliente->fetch();
                $nomeCliente = $cliente ? $cliente['razao_nome'] : 'Cliente Não Cadastrado';
                
                error_log("Cliente encontrado: " . $nomeCliente);

                // BUSCAR NOME DO VENDEDOR (se configurado)
                $nomeVendedor = 'Vendedor Mobile';
                if (!empty($pedidoData['CodVendedor'])) {
                    $stmtVendedor = $db->prepare("
                        SELECT nome FROM usuarios 
                        WHERE id = :id AND codemp = :codemp 
                        LIMIT 1
                    ");
                    $stmtVendedor->execute([
                        'id' => $pedidoData['CodVendedor'],
                        'codemp' => $pedidoData['CodEmp']
                    ]);
                    $vendedor = $stmtVendedor->fetch();
                    if ($vendedor) {
                        $nomeVendedor = $vendedor['nome'];
                    }
                }
                
                error_log("Vendedor: " . $nomeVendedor);

                // CALCULAR TOTAIS
                $totalProdutos = 0;
                $totalDescontos = 0;
                $vlrIPI = 0;
                
                if (isset($pedidoData['itens']) && is_array($pedidoData['itens'])) {
                    foreach ($pedidoData['itens'] as $item) {
                        $subtotal = ($item['Preco_Unitario'] ?? 0) * ($item['Quantidade'] ?? 0);
                        $desconto = $item['Desconto'] ?? 0;
                        $totalProdutos += $subtotal;
                        $totalDescontos += $desconto;
                    }
                }
                
                $totalPedido = $pedidoData['Valor_Total'] ?? ($totalProdutos - $totalDescontos);
                
                error_log("Totais calculados - Produtos: $totalProdutos, Descontos: $totalDescontos, Total: $totalPedido");

                // BUSCAR PLANO DE PAGAMENTO (se existir no pedido)
                $codPlg = $pedidoData['CodPlg'] ?? null;
                $nomePlg = null;
                
                if ($codPlg) {
                    $stmtPlg = $db->prepare("
                        SELECT descricao FROM condpgto 
                        WHERE id = :id AND codemp = :codemp 
                        LIMIT 1
                    ");
                    $stmtPlg->execute([
                        'id' => $codPlg,
                        'codemp' => $pedidoData['CodEmp']
                    ]);
                    $plg = $stmtPlg->fetch();
                    if ($plg) {
                        $nomePlg = $plg['descricao'];
                    }
                }

                // MONTAR OBSERVAÇÕES
                // Formato: "PED-1764344932189 - Observações do usuário"
                $numeroPedidoCelular = $pedidoData['Numero_Pedido'] ?? '';
                $obsUsuario = $pedidoData['Obs'] ?? '';
                
                if ($numeroPedidoCelular && $obsUsuario) {
                    $obsCompleta = $numeroPedidoCelular . ' - ' . $obsUsuario;
                } elseif ($numeroPedidoCelular) {
                    $obsCompleta = $numeroPedidoCelular;
                } elseif ($obsUsuario) {
                    $obsCompleta = $obsUsuario;
                } else {
                    $obsCompleta = null;
                }
                
                // Limitar ao tamanho máximo da coluna (250 chars)
                if ($obsCompleta) {
                    $obsCompleta = substr($obsCompleta, 0, 250);
                }
                
                error_log("Observações montadas: " . ($obsCompleta ?? 'null'));

                // INSERIR PEDIDO NA TABELA pedidos
                $stmt = $db->prepare("
                    INSERT INTO pedidos (
                        CodEmp, Data_Venda, Cod_Pedido, Cod_Cliente, NomeCliente,
                        Cod_Vendedor, Nome_Vendedor, Cod_Plg, Nome_Plg, Vlr_IPI,
                        Total_Produtos, Total_Descontos, MargemLucro, Total_Pedido,
                        ValorTotalSemDesconto, ValorTotalComDesconto, TipoDesconto, ValorDesconto,
                        Obs, Ind_Sinc
                    )
                    VALUES (
                        :codEmp, :data_venda, :cod_pedido, :cod_cliente, :nome_cliente,
                        :cod_vendedor, :nome_vendedor, :cod_plg, :nome_plg, :vlr_ipi,
                        :total_produtos, :total_descontos, :margem_lucro, :total_pedido,
                        :valor_total_sem_desconto, :valor_total_com_desconto, :tipo_desconto, :valor_desconto,
                        :obs, :ind_sinc
                    )
                ");

                // Buscar valores de desconto do pedido (se existirem)
                $valorTotalSemDesconto = $pedidoData['ValorTotalSemDesconto'] ?? $totalProdutos;
                $valorTotalComDesconto = $pedidoData['ValorTotalComDesconto'] ?? $totalPedido;
                $tipoDesconto = $pedidoData['TipoDesconto'] ?? null;
                $valorDesconto = $pedidoData['ValorDesconto'] ?? 0;

                $params = [
                    'codEmp' => $pedidoData['CodEmp'],
                    'data_venda' => isset($pedidoData['Data_Pedido']) 
                        ? date('Y-m-d', strtotime($pedidoData['Data_Pedido'])) 
                        : date('Y-m-d'),
                    'cod_pedido' => $proximoCodPedido, // Código gerado automaticamente
                    'cod_cliente' => $pedidoData['CodCliente'],
                    'nome_cliente' => substr($nomeCliente, 0, 180), // Limite da coluna
                    'cod_vendedor' => $pedidoData['CodVendedor'] ?? 0,
                    'nome_vendedor' => substr($nomeVendedor, 0, 60), // Limite da coluna
                    'cod_plg' => $codPlg ?? 0,
                    'nome_plg' => $nomePlg ? substr($nomePlg, 0, 60) : null,
                    'vlr_ipi' => $vlrIPI,
                    'total_produtos' => $totalProdutos,
                    'total_descontos' => $totalDescontos,
                    'margem_lucro' => 0, // Pode ser calculado depois
                    'total_pedido' => $totalPedido,
                    'valor_total_sem_desconto' => $valorTotalSemDesconto,
                    'valor_total_com_desconto' => $valorTotalComDesconto,
                    'tipo_desconto' => $tipoDesconto,
                    'valor_desconto' => $valorDesconto,
                    'obs' => $obsCompleta, // Inclui número do pedido do celular
                    'ind_sinc' => '1' // Marcar como sincronizado
                ];
                
                error_log("Params INSERT pedido: " . json_encode($params));

                $stmt->execute($params);

                error_log("Pedido inserido com Cod_Pedido: $proximoCodPedido");

                // INSERIR ITENS NA TABELA pedido_item
                if (isset($pedidoData['itens']) && is_array($pedidoData['itens'])) {
                    error_log("Inserindo " . count($pedidoData['itens']) . " itens");
                    
                    $stmtItem = $db->prepare("
                        INSERT INTO pedido_item (
                            CodEmp, Cod_Pedido, Seq, CodigoProduto, Descricao,
                            Vlr_Original, Vlr_Venda, Quantidade, Vlr_Total,
                            Embalagem, Id_embalagem
                        )
                        VALUES (
                            :codEmp, :cod_pedido, :seq, :codigo_produto, :descricao,
                            :vlr_original, :vlr_venda, :quantidade, :vlr_total,
                            :embalagem, :id_embalagem
                        )
                    ");

                    $seq = 1;
                    foreach ($pedidoData['itens'] as $itemIndex => $item) {
                        // BUSCAR DESCRIÇÃO DO PRODUTO
                        $stmtProd = $db->prepare("
                            SELECT mercadoria, um FROM produtos 
                            WHERE id = :id AND codemp = :codemp 
                            LIMIT 1
                        ");
                        $stmtProd->execute([
                            'id' => $item['CodProduto'],
                            'codemp' => $pedidoData['CodEmp']
                        ]);
                        $produto = $stmtProd->fetch();
                        
                        $descricaoProduto = $produto ? $produto['mercadoria'] : 'Produto Não Cadastrado';
                        $embalagem = $produto ? ($produto['um'] ?? 'UN') : 'UN';
                        
                        $itemParams = [
                            'codEmp' => $pedidoData['CodEmp'],
                            'cod_pedido' => $proximoCodPedido, // Mesmo código do pedido
                            'seq' => $seq++,
                            'codigo_produto' => $item['CodProduto'],
                            'descricao' => substr($descricaoProduto, 0, 60), // Limite da coluna
                            'vlr_original' => $item['Preco_Unitario'] ?? 0,
                            'vlr_venda' => $item['Preco_Unitario'] ?? 0,
                            'quantidade' => $item['Quantidade'] ?? 0,
                            'vlr_total' => $item['Valor_Total'] ?? 0,
                            'embalagem' => $embalagem,
                            'id_embalagem' => null // Pode ser configurado depois
                        ];
                        
                        error_log("Item $itemIndex params: " . json_encode([
                            'seq' => $itemParams['seq'],
                            'codigo_produto' => $itemParams['codigo_produto'],
                            'quantidade' => $itemParams['quantidade'],
                            'vlr_total' => $itemParams['vlr_total']
                        ]));
                        
                        $stmtItem->execute($itemParams);
                    }
                }

                $db->commit();
                error_log("Pedido $index commitado com sucesso! Cod_Pedido: $proximoCodPedido");

                $results['success'][] = [
                    'index' => $index,
                    'cod_pedido' => $proximoCodPedido, // Código gerado na nuvem
                    'numero_pedido' => $pedidoData['Numero_Pedido'] ?? null // Código do celular
                ];

            } catch (Exception $e) {
                $db->rollBack();
                error_log("ERRO ao processar pedido $index: " . $e->getMessage());
                error_log("Stack trace: " . $e->getTraceAsString());
                
                $results['errors'][] = [
                    'index' => $index,
                    'numero_pedido' => $pedidoData['Numero_Pedido'] ?? null,
                    'error' => $e->getMessage()
                ];
            }
        }

        error_log("=== RESULTADO FINAL ===");
        error_log("Sucessos: " . count($results['success']));
        error_log("Erros: " . count($results['errors']));
        if (count($results['errors']) > 0) {
            error_log("Detalhes dos erros: " . json_encode($results['errors']));
        }

        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => count($results['success']) . ' pedido(s) sincronizado(s)',
            'results' => $results
        ]);
    }

    public function getPendentes()
    {
        try {

            $db = Database::getInstance()->getConnection();
            
            // Pega codemp do header
            $codemp = $_GET['codemp'] ?? null;
            
            if (!$codemp) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Código da empresa não informado'
                ]);
                return;
            }

            // Buscar pedidos pendentes
            $stmtPedidos = $db->prepare("
                SELECT 
                    p.*,
                    c.razao_nome,
                    c.cpf_cnpj
                FROM pedidos p
                LEFT JOIN clientes c ON c.codigo = p.Cod_Cliente AND c.codemp = p.CodEmp
                WHERE p.CodEmp = :codemp 
                  AND p.Ind_Sinc = 'N'
                ORDER BY p.Data_Venda, p.Cod_Pedido
            ");
            $stmtPedidos->execute(['codemp' => $codemp]);
            $pedidos = $stmtPedidos->fetchAll(PDO::FETCH_ASSOC);

            // Para cada pedido, buscar os itens
            foreach ($pedidos as &$pedido) {
                $stmtItens = $db->prepare("
                    SELECT 
                        pi.*,
                        p.mercadoria as descricao_produto
                    FROM pedido_item pi
                    LEFT JOIN produtos p ON p.id = pi.CodigoProduto AND p.codemp = pi.CodEmp
                    WHERE pi.CodEmp = :codemp 
                      AND pi.Cod_Pedido = :cod_pedido
                    ORDER BY pi.Seq
                ");
                $stmtItens->execute([
                    'codemp' => $codemp,
                    'cod_pedido' => $pedido['Cod_Pedido']
                ]);
                $pedido['itens'] = $stmtItens->fetchAll(PDO::FETCH_ASSOC);
            }

            $this->sendSuccess([
                'total' => count($pedidos),
                'pedidos' => $pedidos
            ]);

        } catch (Exception $e) {
            error_log("Erro ao buscar pedidos pendentes: " . $e->getMessage());
            $this->sendError('Erro ao buscar pedidos pendentes: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /pedidos/{id}/sincronizado
     * Marca pedido como sincronizado
     */
    public function marcarSincronizado($codPedido)
    {
        try {
            $db = Database::getInstance()->getConnection();
            
            // Pega codemp do header
            $codemp = $_GET['codemp'] ?? null;
            
            if (!$codemp) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Código da empresa não informado'
                ]);
                return;
            }

            // Pega dados do corpo da requisição
            $data = $this->getJsonInput();
            $codigoLocal = $data['codigo_local'] ?? null;

            // Atualizar status do pedido
            $stmt = $db->prepare("
                UPDATE pedidos 
                SET Ind_Sinc = 'S',
                    Obs = CONCAT(COALESCE(Obs, ''), ' - Sincronizado (', COALESCE(:codigo_local, ''), ')')
                WHERE CodEmp = :codemp 
                  AND Cod_Pedido = :cod_pedido
            ");
            
            $stmt->execute([
                'codemp' => $codemp,
                'cod_pedido' => $codPedido,
                'codigo_local' => $codigoLocal
            ]);

            if ($stmt->rowCount() > 0) {
                $this->sendSuccess([
                    'message' => 'Pedido marcado como sincronizado',
                    'cod_pedido' => $codPedido,
                    'codigo_local' => $codigoLocal
                ]);
            } else {
                $this->sendError('Pedido não encontrado ou já sincronizado', 404);
            }

        } catch (Exception $e) {
            error_log("Erro ao marcar pedido como sincronizado: " . $e->getMessage());
            $this->sendError('Erro ao marcar pedido: ' . $e->getMessage(), 500);
        }
    }
}