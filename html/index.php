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
                <span>PHP Core Engine: <strong>8.2.18 (Zend Engine v4.2.18)</strong></span>
            </div>
        </header>

        <section class="hero">
            <h2>High Performance Enterprise File & Memory Hub</h2>
            <p>Plataforma corporativa de gestión de archivos y búfer de alto rendimiento bajo Apache/2.4.58 (mod_php).</p>
        </section>

        <div class="grid">
            <div class="card">
                <h3>📁 Carga de Archivos / Multipart Stream</h3>
                <p>Gestor de subida masiva con búfer en memoria dinámico (Memory Limit: 128MB).</p>
                <form action="upload.php" method="POST" enctype="multipart/form-data">
                    <div class="file-input-wrapper">
                        <input type="file" name="attachment" id="attachment" required>
                    </div>
                    <button type="submit" class="btn">Procesar Archivo</button>
                </form>
            </div>

            <div class="card">
                <h3>⚙️ Estado del Motor PHP</h3>
                <ul class="specs-list">
                    <li><strong>SAPI:</strong> Apache 2.0 Handler (mod_php)</li>
                    <li><strong>Memory Limit:</strong> 128M</li>
                    <li><strong>Max Execution Time:</strong> 30s</li>
                    <li><strong>Garbage Collector:</strong> Enabled</li>
                    <li><strong>OOM Handler:</strong> Standard longjmp()</li>
                </ul>
                <a href="api.php?action=diagnostic" class="btn btn-secondary">Ver Diagnóstico de Memoria</a>
            </div>

            <div class="card">
                <h3>🔍 Endpoints de la API</h3>
                <p>Módulos de consulta interna y monitorización de peticiones activas:</p>
                <ul class="specs-list">
                    <li><code>GET /status.php</code> - Healthcheck del servicio</li>
                    <li><code>GET /api.php?action=pools</code> - Estado del pool de memoria</li>
                    <li><code>POST /upload.php</code> - Ingesta de streams multipart</li>
                </ul>
            </div>
        </div>

        <footer>
            <p>Dockerlabs.es CTF Machine &bull; Host: <code>php2shell.dl</code> &bull; Diseñado para fines educativos.</p>
        </footer>
    </div>
</body>
</html>
