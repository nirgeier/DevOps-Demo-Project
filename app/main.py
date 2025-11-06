"""
Simple Python Flask Server for DevOps Demo
Demonstrates a microservice with health checks and basic endpoints
"""

from flask import Flask, jsonify, request
import os
import socket
from datetime import datetime

app = Flask(__name__)

# Configuration
VERSION = os.getenv('APP_VERSION', '1.0.0')
PORT = int(os.getenv('PORT', 8080))

@app.route('/')
def home():
    """Root endpoint"""
    return jsonify({
        'message': 'Welcome to DevOps Demo Project! 🚀',
        'version': VERSION,
        'hostname': socket.gethostname(),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/health')
def health():
    """Health check endpoint for Kubernetes"""
    return jsonify({
        'status': 'healthy',
        'version': VERSION,
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/ready')
def ready():
    """Readiness check endpoint for Kubernetes"""
    return jsonify({
        'status': 'ready',
        'version': VERSION
    }), 200

@app.route('/api/info')
def info():
    """Application information endpoint"""
    return jsonify({
        'application': 'devops-demo',
        'version': VERSION,
        'hostname': socket.gethostname(),
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/echo', methods=['POST'])
def echo():
    """Echo endpoint for testing"""
    data = request.get_json() or {}
    return jsonify({
        'received': data,
        'timestamp': datetime.now().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({
        'error': 'Not found',
        'status': 404
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    return jsonify({
        'error': 'Internal server error',
        'status': 500
    }), 500

if __name__ == '__main__':
    print(f"🚀 Starting DevOps Demo Server v{VERSION}")
    print(f"📡 Listening on port {PORT}")
    app.run(host='0.0.0.0', port=PORT, debug=False)
