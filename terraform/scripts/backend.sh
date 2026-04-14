#!/bin/bash
exec > /home/ubuntu/backend.log 2>&1

apt update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs mysql-client

mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

cat <<EOF > app.js
const http = require('http');
const mysql = require('mysql2');
const https = require('http'); // Used for metadata calls

const connection = mysql.createConnection({
  host: '${db_host}', 
  user: 'admin',
  password: 'password123',
  database: 'mydb'
});

// Helper to fetch AWS Metadata
const getMetadata = (path) => {
  return new Promise((resolve) => {
    const options = {
      hostname: '169.254.169.254',
      path: '/latest/meta-data/' + path,
      method: 'GET',
      timeout: 1000
    };
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => resolve(data || 'N/A'));
    });
    req.on('error', () => resolve('N/A'));
    req.end();
  });
};

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // --- NEW HEALTH ROUTE ---
  if (req.url === '/health' && req.method === 'GET') {
    const instanceId = await getMetadata('instance-id');
    const az = await getMetadata('placement/availability-zone');
    const privateIp = await getMetadata('local-ipv4');
    
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({
      status: "Online",
      database: "Connected",
      instanceId,
      az,
      privateIp
    }));
    return;
  }

  // --- EXISTING REGISTER ROUTE ---
  if (req.url === '/register' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      const { name, email } = JSON.parse(body);
      connection.query('INSERT INTO users (name, email) VALUES (?, ?)', [name, email], (err) => {
        if (err) {
          res.writeHead(500, {'Content-Type': 'application/json'});
          res.end(JSON.stringify({ message: "DB Error" }));
        } else {
          res.writeHead(200, {'Content-Type': 'application/json'});
          res.end(JSON.stringify({ message: "User Registered Successfully!" }));
        }
      });
    });
  }
});

server.listen(3000);
EOF

chown -R ubuntu:ubuntu /home/ubuntu/app
npm install mysql2
npm install -g pm2
sudo -u ubuntu pm2 start /home/ubuntu/app/app.js --name "backend-api"