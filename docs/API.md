# API Documentation

## DevOps Demo Application API

Base URL: `http://localhost:8080`

## Endpoints

### Root Endpoint

**GET** `/`

Returns welcome message and basic application information.

**Response:**
```json
{
  "message": "Welcome to DevOps Demo Project! 🚀",
  "version": "1.0.0",
  "hostname": "devops-demo-abc123",
  "timestamp": "2025-11-06T10:30:00.000000"
}
```

**Status Codes:**
- `200 OK` - Success

---

### Health Check

**GET** `/health`

Kubernetes liveness probe endpoint. Indicates if the application is running.

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2025-11-06T10:30:00.000000"
}
```

**Status Codes:**
- `200 OK` - Application is healthy

**Usage:**
```bash
curl http://localhost:8080/health
```

---

### Readiness Check

**GET** `/ready`

Kubernetes readiness probe endpoint. Indicates if the application is ready to serve traffic.

**Response:**
```json
{
  "status": "ready",
  "version": "1.0.0"
}
```

**Status Codes:**
- `200 OK` - Application is ready

**Usage:**
```bash
curl http://localhost:8080/ready
```

---

### Application Info

**GET** `/api/info`

Returns detailed application information.

**Response:**
```json
{
  "application": "devops-demo",
  "version": "1.0.0",
  "hostname": "devops-demo-abc123",
  "environment": "production",
  "timestamp": "2025-11-06T10:30:00.000000"
}
```

**Status Codes:**
- `200 OK` - Success

**Usage:**
```bash
curl http://localhost:8080/api/info
```

---

### Echo Endpoint

**POST** `/api/echo`

Echoes back the JSON data sent in the request body. Useful for testing.

**Request Body:**
```json
{
  "message": "Hello, World!",
  "value": 123
}
```

**Response:**
```json
{
  "received": {
    "message": "Hello, World!",
    "value": 123
  },
  "timestamp": "2025-11-06T10:30:00.000000"
}
```

**Status Codes:**
- `200 OK` - Success

**Usage:**
```bash
curl -X POST http://localhost:8080/api/echo \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "value": 123}'
```

---

## Error Responses

### 404 Not Found

When accessing a non-existent endpoint:

```json
{
  "error": "Not found",
  "status": 404
}
```

### 500 Internal Server Error

When an unexpected error occurs:

```json
{
  "error": "Internal server error",
  "status": 500
}
```

---

## Configuration

### Environment Variables

- `APP_VERSION` - Application version (default: "1.0.0")
- `PORT` - Server port (default: 8080)
- `ENVIRONMENT` - Deployment environment (default: "development")

---

## Examples

### Python

```python
import requests

# Health check
response = requests.get('http://localhost:8080/health')
print(response.json())

# Echo endpoint
data = {"message": "test", "value": 42}
response = requests.post('http://localhost:8080/api/echo', json=data)
print(response.json())
```

### cURL

```bash
# Get application info
curl http://localhost:8080/api/info

# Echo with data
curl -X POST http://localhost:8080/api/echo \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

### JavaScript (fetch)

```javascript
// Get health status
fetch('http://localhost:8080/health')
  .then(response => response.json())
  .then(data => console.log(data));

// Post to echo endpoint
fetch('http://localhost:8080/api/echo', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({message: 'Hello'})
})
  .then(response => response.json())
  .then(data => console.log(data));
```

---

## Rate Limiting

Currently, no rate limiting is implemented. In production environments, consider implementing rate limiting using:

- NGINX ingress controller
- API Gateway
- Application-level rate limiting (Flask-Limiter)

---

## Authentication

This demo application does not implement authentication. For production use, consider:

- JWT tokens
- OAuth 2.0
- API keys
- mTLS (mutual TLS)

---

## Monitoring

The application exposes Prometheus-compatible metrics annotations:

```yaml
prometheus.io/scrape: "true"
prometheus.io/port: "8080"
prometheus.io/path: "/health"
```

---

## Support

For issues or questions, please open an issue on GitHub.
