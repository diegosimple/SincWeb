<?php
/**
 * ===============================================
 *  DEFINIÇÃO DE ROTAS (PRD)
 *  - Organizado por módulos
 *  - Fácil manutenção
 * ===============================================
 */

$request_uri = strtok($_SERVER['REQUEST_URI'], '?');
$request_method = $_SERVER['REQUEST_METHOD'];

// Remoção de prefixos (caso esteja em subpastas)
$uri = str_replace(['/api-php', '/public', '/api'], '', $request_uri);

// Debug SEMPRE (para rastrear problemas)
error_log('=== routes.php INICIO ===');
error_log('routes.php: REQUEST_URI = ' . $_SERVER['REQUEST_URI']);
error_log('routes.php: URI processada = ' . $uri);
error_log('routes.php: REQUEST_METHOD = ' . $request_method);

// Garantir que o autoload do Composer está carregado (para JWT)
if (file_exists(__DIR__ . '/vendor/autoload.php')) {
    require_once __DIR__ . '/vendor/autoload.php';
}

// Middlewares
require_once __DIR__ . '/middleware/AuthMiddleware.php'; // Para TUDO (Mobile e Web)
// MobileAuthMiddleware e WebAuthMiddleware - REMOVIDOS (voltando ao AuthMiddleware original)
require_once __DIR__ . '/controllers/BaseController.php';
// Controllers
require_once __DIR__ . '/controllers/LicenseController.php';
require_once __DIR__ . '/controllers/EmpresaController.php';
require_once __DIR__ . '/controllers/ClientesController.php';
require_once __DIR__ . '/controllers/ProdutosController.php';
require_once __DIR__ . '/controllers/PedidosController.php';
require_once __DIR__ . '/controllers/SyncController.php';

/**
 * ======================================
 *              AUTH (ROTAS PÚBLICAS)
 * ======================================
 */
// Rotas públicas que NÃO passam por autenticação
$publicRoutes = ['/auth/login', '/auth/validate-license', '/auth/token'];

if ($uri === '/auth/token' && $request_method === 'POST') {
    (new LicenseController())->tokenSimple();   // nova função
    return;
}

if ($uri === '/auth/login' && $request_method === 'POST') {
    (new LicenseController())->login();
    return;
}





if ($uri === '/auth/validate-license' && $request_method === 'POST') {
    if (defined('ENVIRONMENT') && ENVIRONMENT === 'dev') {
        error_log('routes.php: Rota /auth/validate-license detectada, chamando validateLicense()');
    }
    (new LicenseController())->validateLicense();
    exit; // Usar exit ao invés de return para garantir que não continue processando
}

/**
 * ======================================
 *      AUTENTICAÇÃO (AuthMiddleware original)
 * ======================================
 * 
 * Todas as rotas (mobile e web) usam o AuthMiddleware original
 * Ele detecta automaticamente se é API Key (mobile) ou JWT (web)
 */
if (!in_array($uri, $publicRoutes)) {
    error_log("routes.php: Rota: $uri - Usando AuthMiddleware (original)");
    AuthMiddleware::authenticate();
}

/**
 * ======================================
 *             EMPRESAS
 * ======================================
 */
if ($uri === '/empresa' && $request_method === 'POST') {
    (new EmpresaController())->create();
    return;
}

if ($uri === '/empresa/sync' && $request_method === 'POST') {
    (new EmpresaController())->syncEmpresa();
    return;
}

if ($uri === '/empresa/vendedores' && $request_method === 'POST') {
    (new EmpresaController())->insertVendedores();
    return;
}

if ($uri === '/empresa' && $request_method === 'GET') {
    (new EmpresaController())->getAll();
    return;
}

if (preg_match('/^\/empresa\/(\d+)$/', $uri, $m) && $request_method === 'GET') {
    (new EmpresaController())->get($m[1]);
    return;
}

/**
 * ======================================
 *             CLIENTES (WEB)
 * ======================================
 */
if ($uri === '/clientes' && $request_method === 'GET') {
    (new ClientesController())->getAll();
    return;
}

if (preg_match('/^\/clientes\/(\d+)$/', $uri, $m) && $request_method === 'GET') {
    (new ClientesController())->getById($m[1]);
    return;
}

if ($uri === '/clientes' && $request_method === 'POST') {
    (new ClientesController())->create();
    return;
}

if ($uri === '/clientes/sync' && $request_method === 'POST') {
    (new ClientesController())->syncClientes();
    return;
}

if (preg_match('/^\/clientes\/(\d+)$/', $uri, $m) && $request_method === 'PUT') {
    (new ClientesController())->update($m[1]);
    return;
}

if ($uri === '/clientes/download' && $request_method === 'GET') {
    (new ClientesController())->download();
    return;
}

/**
 * ======================================
 *             PRODUTOS (WEB)
 * ======================================
 * 
 */
   // POST /produtos/sync - Sincronizar produtos do Delphi
if ($uri === '/produtos/sync' && $request_method === 'POST') {
    (new ProdutosController())->syncProdutos();
    return;
}

if ($request_method === 'PUT' && preg_match('#^/produtos/(\d+)/imagem$#', $uri, $matches)) {
    (new ProdutosController())->    updateImagem($matches[1]);
    return;
}

if ($uri === '/produtos' && $request_method === 'GET') {
    (new ProdutosController())->getAll();
    return;
}

if (preg_match('/^\/produtos\/(\d+)$/', $uri, $m) && $request_method === 'GET') {
    (new ProdutosController())->getById($m[1]);
    return;
}

if (preg_match('/^\/produtos\/barcode\/(.+)$/', $uri, $m) && $request_method === 'GET') {
    (new ProdutosController())->getByBarcode($m[1]);
    return;
}

/**
 * ======================================
 *             PEDIDOS
 * ======================================
 */
if ($uri === '/pedidos' && $request_method === 'GET') {
    (new PedidosController())->getAll();
    return;
}

if ($uri === '/pedidos' && $request_method === 'POST') {
    (new PedidosController())->create();
    return;
}

if (preg_match('/^\/pedidos\/(\d+)$/', $uri, $m) && $request_method === 'PUT') {
    (new PedidosController())->update($m[1]);
    return;
}

if ($uri === '/pedidos/sync' && $request_method === 'POST') {
    (new PedidosController())->syncPendentes();
    return;
}

if ($uri === '/pedidos/pendentes' && $request_method === 'GET') {
    (new PedidosController())->getPendentes();
    return;
}

if (preg_match('/^\/pedidos\/(\d+)\/sincronizado$/', $uri, $m) && $request_method === 'POST') {
    (new PedidosController())->marcarSincronizado($m[1]);
    return;
}

/**
 * ======================================
 *      SINCRONIZAÇÃO MOBILE (API_KEY)
 * ======================================
 */
if ($uri === '/sync/last' && $request_method === 'GET') {
    (new SyncController())->getLastSync();
    return;
}

if ($uri === '/sync/download' && $request_method === 'GET') {
    (new SyncController())->download();
    return;
}

if ($uri === '/sync/download-batch' && $request_method === 'GET') {
    (new SyncController())->downloadBatch();
    return;
}

/**
 * ======================================
 *             ROOT
 * ======================================
 */
if ($uri === '/' || $uri === '/api') {
    echo json_encode([
        'service' => 'Force API',
        'version' => API_VERSION,
        'status' => 'Online',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    return;
}

// Rota não encontrada
http_response_code(404);
echo json_encode([
    'success' => false,
    'error' => 'Rota não encontrada',
    'uri' => $uri
]);
