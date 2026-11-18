<?php
header('Content-Type: application/json; charset=utf-8');
header('X-Powered-By: PHP/8.2.18');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if multipart upload triggered memory exhaustion / PHP2Shell exploit payload
    if (isset($_FILES['attachment'])) {
        $file = $_FILES['attachment'];
        $filename = basename($file['name']);
        
        // Check if an exploit payload was injected in filename or content
        $content = file_get_contents($file['tmp_name']);
        if (strpos($content, '<?php') !== false || strpos($filename, '.php') !== false) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Filtro de seguridad activado: Extensiones o scripts PHP directos bloqueados por WAF.'
            ]);
            exit;
        }

        echo json_encode([
            'status' => 'success',
            'filename' => htmlspecialchars($filename),
            'size' => $file['size'],
            'message' => 'Archivo recibido e indexado en el búfer temporal.'
        ]);
        exit;
    }

    echo json_encode(['status' => 'error', 'message' => 'No se recibió ningún archivo.']);
    exit;
}

header('Location: index.php');
exit;
