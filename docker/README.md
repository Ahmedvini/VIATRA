# Docker Configuration

This directory contains Docker-related configuration files for the Viatra Health Platform local development environment.

## Structure

```
docker/
├── nginx/                 # Nginx reverse proxy configuration
│   ├── nginx.conf         # Main nginx configuration
│   ├── conf.d/           # Site-specific configurations
│   │   └── default.conf  # Default server configuration
│   └── ssl/              # SSL certificates for HTTPS
│       ├── server.crt    # Self-signed certificate
│       └── server.key    # Private key (excluded from git)
└── volumes/              # Docker volume mount points
    ├── postgres/         # PostgreSQL data
    ├── redis/           # Redis data
    └── pgadmin/         # pgAdmin configuration
```

## Nginx Configuration

The nginx service provides:

- **Reverse proxy** to backend API
- **HTTPS termination** with self-signed certificates
- **CORS support** for mobile development
- **Rate limiting** for security
- **Security headers** for enhanced protection
- **Gzip compression** for performance

### SSL Certificates

Self-signed certificates are generated automatically for local development. The private key (`server.key`) is excluded from version control for security.

To regenerate certificates:

```bash
cd docker/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout server.key -out server.crt \
    -subj '/CN=localhost'
```

### Customizing Nginx

1. **Modify main config**: Edit `nginx/nginx.conf`
2. **Add new sites**: Add files to `nginx/conf.d/`
3. **Update SSL**: Replace certificates in `nginx/ssl/`
4. **Restart service**: `docker-compose restart nginx`

### Troubleshooting

**Nginx won't start:**
- Check configuration syntax: `docker-compose exec nginx nginx -t`
- View logs: `docker-compose logs nginx`
- Ensure SSL certificates exist in `ssl/` directory

**SSL certificate warnings:**
- Normal for self-signed certificates in development
- Click "Advanced" → "Proceed to localhost (unsafe)" in browsers
- For production, use proper CA-signed certificates

**CORS issues:**
- Check origin configuration in `conf.d/default.conf`
- Ensure mobile app origin (`http://localhost:3000`) is allowed
- Restart nginx after configuration changes

## Security Notes

- SSL certificates are for **development only**
- Private keys are **excluded from git**
- Production should use proper CA-signed certificates
- Rate limiting is configured for basic protection
