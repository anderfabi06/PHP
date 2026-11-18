<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP2Shell Cloud Platform - Enterprise Core</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <div class="logo">
                <span class="shield">🛡️</span>
                <h1>PHP2Shell <span>Cloud Enterprise</span></h1>
            </div>
            <div class="server-status">
                <span class="status-dot"></span>
                <span>PHP Core Engine: <strong><?= htmlspecialchars(PHP_VERSION) ?></strong></span>
            </div>
        </header>

        <section class="hero">
            <h2>High Performance Enterprise Infrastructure</h2>
            <p>Plataforma corporativa de gestión de microservicios y telemetría interna bajo Apache y PHP.</p>
        </section>

        <div class="grid">
            <div class="card">
                <h3>⚙️ Estado del Motor PHP</h3>
                <ul class="specs-list">
                    <li><strong>Versión PHP:</strong> <?= htmlspecialchars(PHP_VERSION) ?></li>
                    <li><strong>Zend Engine:</strong> <?= htmlspecialchars(zend_version()) ?></li>
                    <li><strong>SAPI:</strong> <?= htmlspecialchars(php_sapi_name()) ?></li>
                    <li><strong>Memory Limit:</strong> <?= htmlspecialchars(ini_get('memory_limit')) ?></li>
                    <li><strong>Max Execution Time:</strong> <?= htmlspecialchars(ini_get('max_execution_time')) ?>s</li>
                </ul>
                <a href="api.php?action=diagnostic" class="btn btn-secondary">Ver Diagnóstico de Memoria</a>
            </div>

            <div class="card">
                <h3>🔍 Endpoints de la API</h3>
                <p>Módulos de consulta interna y monitorización de peticiones activas:</p>
                <ul class="specs-list">
                    <li><code>GET /status.php</code> - Healthcheck del servicio</li>
                    <li><code>GET /api.php?action=diagnostic</code> - Telemetría del worker y proceso</li>
                    <li><code>GET /api.php?action=pools</code> - Estado del pool de servidores</li>
                </ul>
            </div>

            <div class="card">
                <h3>📋 Documentación de Mantenimiento</h3>
                <p>Las tareas de mantenimiento y auditoría interna se gestionan a través de la API administrativa.</p>
                <p style="margin-top: 1rem; font-size: 0.85rem; color: #94a3b8;">
                    Consulte las políticas y directivas de acceso en los recursos públicos antes de realizar pruebas de conectividad.
                </p>
                <a href="status.php" class="btn">Comprobar Servicio</a>
            </div>
        </div>

        <footer>
            <p>Dockerlabs.es CTF Machine &bull; Host: <code>php2shell.dl</code> &bull; Diseñado para fines educativos.</p>
        </footer>
    </div>
</body>
</html>
