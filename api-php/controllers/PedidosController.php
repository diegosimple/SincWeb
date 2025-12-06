<?php
/**
 * controllers/PedidosController.php
 */

class PedidosController extends BaseController
{
    /**
     * Listar todos os pedidos
     * GET /api/pedidos
     */
    public function getAll()
    {
        $codEmp = $this->getCodemp(); // ✅ Método herdado

        try {
            $db = $this->getDb(); // ✅ Método herdado

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

            $this->sendSuccess([ // ✅ Método herdado
                'data' => $pedidos,
                'count' => count($pedidos)
            ]);

        } catch (Exception $e) {
            $this->sendError('Erro ao buscar pedidos', 500, $e->getMessage()); // ✅ Método herdado
        }
    }

    /**
     * Buscar pedido por ID com itens
     * GET /api/pedidos/{id}
     */
    public function getById($id)
    {
        try {
            $db = $this->getDb();

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
                $this->sendError('Pedido não encontrado', 404);
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

            $this->sendSuccess(['data' => $pedido]);

        } catch (Exception $e) {
            $this->sendError('Erro ao buscar pedido', 500, $e->getMessage());
        }
    }

    /**
     * Sincronizar pedidos pendentes (receber do app)
     * POST /api/pedidos/sync
     */
    public function syncPendentes()
    {
        $rawInput = file_get_contents('php://input');
        $data = json_decode($rawInput, true);
        
        // Logs de desenvolvimento usando método herdado
        $this->devLog("=== INICIO syncPendentes ===");
        $this->devLog("Headers recebidos: ", getallheaders());
        $this->devLog("Raw Input Length: " . strlen($rawInput));
        $this->devLog("JSON decodificado: " . (is_array($data) ? 'SIM' : 'NAO'));
        
        if (isset($data['pedidos'])) {
            $this->devLog("Pedidos recebidos: " . count($data['pedidos']));
            if (count($data['pedidos']) > 0) {
                $this->devLog("Primeiro pedido (resumo): ", [
                    'Numero_Pedido' => $data['pedidos'][0]['Numero_Pedido'] ?? null,
                    'CodCliente' => $data['pedidos'][0]['CodCliente'] ?? null,
                    'CodEmp' => $data['pedidos'][0]['CodEmp'] ?? null,
                    'Valor_Total' => $data['pedidos'][0]['Valor_Total'] ?? null,
                    'itens_count' => count($data['pedidos'][0]['itens'] ?? [])
                ]);
            }
        } else {
            $this->devLog("ERRO: Campo 'pedidos' não encontrado");
        }

        if (!isset($data['pedidos']) || !is_array($data['pedidos'])) {
            $this->sendError('Lista de pedidos inválida', 400);
        }

        $results = [
            'success' => [],
            'errors' => []
        ];

        $db = $this->getDb();

        foreach ($data['pedidos'] as $index => $pedidoData) {
            try {
                $this->devLog("=== Processando pedido index $index ===");
                $this->devLog("Numero_Pedido: " . ($pedidoData['Numero_Pedido'] ?? 'null'));
                
                $db->beginTransaction();

                // GERAR PRÓXIMO Cod_Pedido
                $stmt = $db->prepare("
                    SELECT COALESCE(MAX(Cod_Pedido), 0) + 1 as ProximoCodigo
                    FROM pedidos 
                    WHERE CodEmp = :codEmp
                ");
                $stmt->execute(['codEmp' => $pedidoData['CodEmp']]);
                $resultado = $stmt->fetch();
                $proximoCodPedido = $resultado['ProximoCodigo'];
                
                $this->devLog("Próximo Cod_Pedido: $proximoCodPedido para CodEmp: " . $pedidoData['CodEmp']);

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
                
                $this->devLog("Cliente: " . $nomeCliente);

                // BUSCAR NOME DO VENDEDOR
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
                
                $this->devLog("Vendedor: " . $nomeVendedor);

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
                
                $this->devLog("Totais - Produtos: $totalProdutos, Descontos: $totalDescontos, Total: $totalPedido");

                // BUSCAR PLANO DE PAGAMENTO
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
                
                if ($obsCompleta) {
                    $obsCompleta = substr($obsCompleta, 0, 250);
                }
                
                $this->devLog("Observações: " . ($obsCompleta ?? 'null'));

                // INSERIR PEDIDO
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

                $valorTotalSemDesconto = $pedidoData['ValorTotalSemDesconto'] ?? $totalProdutos;
                $valorTotalComDesconto = $pedidoData['ValorTotalComDesconto'] ?? $totalPedido;
                $tipoDesconto = $pedidoData['TipoDesconto'] ?? null;
                $valorDesconto = $pedidoData['ValorDesconto'] ?? 0;

                $params = [
                    'codEmp' => $pedidoData['CodEmp'],
                    'data_venda' => isset($pedidoData['Data_Pedido']) 
                        ? date('Y-m-d', strtotime($pedidoData['Data_Pedido'])) 
                        : date('Y-m-d'),
                    'cod_pedido' => $proximoCodPedido,
                    'cod_cliente' => $pedidoData['CodCliente'],
                    'nome_cliente' => substr($nomeCliente, 0, 180),
                    'cod_vendedor' => $pedidoData['CodVendedor'] ?? 0,
                    'nome_vendedor' => substr($nomeVendedor, 0, 60),
                    'cod_plg' => $codPlg ?? 0,
                    'nome_plg' => $nomePlg ? substr($nomePlg, 0, 60) : null,
                    'vlr_ipi' => $vlrIPI,
                    'total_produtos' => $totalProdutos,
                    'total_descontos' => $totalDescontos,
                    'margem_lucro' => 0,
                    'total_pedido' => $totalPedido,
                    'valor_total_sem_desconto' => $valorTotalSemDesconto,
                    'valor_total_com_desconto' => $valorTotalComDesconto,
                    'tipo_desconto' => $tipoDesconto,
                    'valor_desconto' => $valorDesconto,
                    'obs' => $obsCompleta,
                    'ind_sinc' => '0' // ✅ Já marcar como sincronizado
                ];
                
                $this->devLog("INSERT pedido params: ", $params);
                $stmt->execute($params);
                $this->devLog("Pedido inserido: $proximoCodPedido");

                // INSERIR ITENS
                if (isset($pedidoData['itens']) && is_array($pedidoData['itens'])) {
                    $this->devLog("Inserindo " . count($pedidoData['itens']) . " itens");
                    
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
                        // Buscar descrição do produto
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
                            'cod_pedido' => $proximoCodPedido,
                            'seq' => $seq++,
                            'codigo_produto' => $item['CodProduto'],
                            'descricao' => substr($descricaoProduto, 0, 60),
                            'vlr_original' => $item['Preco_Unitario'] ?? 0,
                            'vlr_venda' => $item['Preco_Unitario'] ?? 0,
                            'quantidade' => $item['Quantidade'] ?? 0,
                            'vlr_total' => $item['Valor_Total'] ?? 0,
                            'embalagem' => $embalagem,
                            'id_embalagem' => null
                        ];
                        
                        $stmtItem->execute($itemParams);
                    }
                }

                $db->commit();
                $this->devLog("✅ Pedido $index commitado! Cod_Pedido: $proximoCodPedido");

                $results['success'][] = [
                    'index' => $index,
                    'cod_pedido' => $proximoCodPedido,
                    'numero_pedido' => $pedidoData['Numero_Pedido'] ?? null
                ];

            } catch (Exception $e) {
                $db->rollBack();
                $this->devLog("❌ ERRO pedido $index: " . $e->getMessage());
                $this->devLog("Stack trace: " . $e->getTraceAsString());
                
                $results['errors'][] = [
                    'index' => $index,
                    'numero_pedido' => $pedidoData['Numero_Pedido'] ?? null,
                    'error' => $e->getMessage()
                ];
            }
        }

        $this->devLog("=== RESULTADO FINAL ===");
        $this->devLog("Sucessos: " . count($results['success']));
        $this->devLog("Erros: " . count($results['errors']));

        $this->sendSuccess([
            'message' => count($results['success']) . ' pedido(s) sincronizado(s)',
            'results' => $results
        ]);
    }

    /**
     * GET /pedidos/pendentes
     * Buscar pedidos não sincronizados
     */
    public function getPendentes()
    {
        try {
            $db = $this->getDb();
            $codemp = $this->getCodemp();
            
            if (!$codemp) {
                $this->sendError('Código da empresa não informado', 400);
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
                  AND p.Ind_Sinc in ( 'N', '0')
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
            $this->sendError('Erro ao buscar pedidos pendentes', 500, $e->getMessage());
        }
    }

    /**
     * POST /pedidos/{id}/sincronizado
     * Marca pedido como sincronizado
     */
    public function marcarSincronizado($codPedido)
    {
        try {
            $db = $this->getDb();
            $codemp = $this->getCodemp();
            
            if (!$codemp) {
                $this->sendError('Código da empresa não informado', 400);
            }

            // Pega dados do corpo
            $data = $this->getJsonInput();
            $codigoLocal = $data['codigo_local'] ?? null;

            // Atualizar status //0 É FOI OK - S OU 1 É DISPONIVEL PARA SINCRONIZAÇÃO
            $stmt = $db->prepare("
                UPDATE pedidos 
                SET Ind_Sinc = '1',
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
            error_log("Erro ao marcar pedido: " . $e->getMessage());
            $this->sendError('Erro ao marcar pedido', 500, $e->getMessage());
        }
    }
}