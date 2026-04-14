#!/bin/bash
apt update -y
apt install -y nginx
rm -f /etc/nginx/sites-enabled/default

cat <<EOF > /etc/nginx/sites-available/app
server {
    listen 80;
    root /var/www/html;
    index index.html;

    location / { try_files \$uri \$uri/ =404; }

    location /api/ {
        proxy_pass http://${backend_ip}:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }
}
EOF

ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/
systemctl restart nginx

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Cloud Health Monitor</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); width: 380px; }
        .stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 20px; background: #fafafa; padding: 15px; border-radius: 8px; border: 1px solid #eee; }
        .stat-item { font-size: 12px; color: #666; }
        .stat-value { font-weight: bold; color: #333; display: block; font-size: 14px; }
        input { width: 100%; padding: 12px; margin: 8px 0; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; }
        .status-pill { padding: 2px 8px; border-radius: 10px; font-size: 11px; background: #d4edda; color: #155724; }
    </style>
</head>
<body>
    <div class="card">
        <h2 style="margin-top:0; text-align:center;">Cloud Health Dashboard</h2>
        
        <div class="stats-grid">
            <div class="stat-item">Backend Status <span id="s-status" class="status-pill">Checking...</span></div>
            <div class="stat-item">Region/AZ <span id="s-az" class="stat-value">-</span></div>
            <div class="stat-item">Instance ID <span id="s-id" class="stat-value">-</span></div>
            <div class="stat-item">Private IP <span id="s-ip" class="stat-value">-</span></div>
        </div>

        <h4 style="margin-bottom:10px;">Register New Node</h4>
        <input type="text" id="name" placeholder="Node Name">
        <input type="email" id="email" placeholder="Admin Email">
        <button onclick="register()">Submit to RDS</button>
        <p id="msg" style="text-align:center; font-weight:bold;"></p>
    </div>

    <script>
        async function fetchHealth() {
            try {
                const res = await fetch('/api/health');
                const data = await res.json();
                document.getElementById('s-status').innerText = data.status;
                document.getElementById('s-az').innerText = data.az;
                document.getElementById('s-id').innerText = data.instanceId;
                document.getElementById('s-ip').innerText = data.privateIp;
            } catch (e) { document.getElementById('s-status').innerText = "Offline"; }
        }

        async function register() {
            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const res = await fetch('/api/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, email })
            });
            const data = await res.json();
            document.getElementById('msg').innerText = data.message;
            document.getElementById('msg').style.color = "green";
        }

        fetchHealth();
    </script>
</body>
</html>
EOF