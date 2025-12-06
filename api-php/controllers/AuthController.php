<?php
// Garantir que o autoload está carregado
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    require_once __DIR__ . '/../vendor/autoload.php';
}

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

/**
 * AuthController
 * 
 * Gerencia autenticação e autorização
 * 
 * NOTA: O método validateLicense() foi REMOVIDO deste controller (estava duplicado).
 *       Agora ele existe apenas em LicenseController.php
 */
class AuthController {
    // AuthController está disponível para futuras funcionalidades de autenticação
}
