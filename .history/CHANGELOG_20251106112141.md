# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Add metrics endpoint for Prometheus
- Implement distributed tracing
- Add caching layer
- Database integration example

## [1.0.0] - 2025-11-06

### Added
- Initial release of DevOps Demo Project
- Python Flask application with RESTful API
- Health and readiness endpoints
- Docker multi-stage build configuration
- Kubernetes Helm charts
- ArgoCD GitOps configuration
- GitHub Actions CI/CD pipelines
- GitFlow branch management automation
- Comprehensive documentation
- Automated installation scripts
- Unit tests with pytest
- Code coverage reporting

### Features
- `/` - Welcome endpoint
- `/health` - Health check endpoint
- `/ready` - Readiness check endpoint
- `/api/info` - Application information
- `/api/echo` - Echo test endpoint

### Infrastructure
- Multi-platform Docker images (amd64, arm64)
- Kubernetes deployment with HPA
- ArgoCD GitOps deployment
- GitHub Container Registry integration
- Automated testing in CI/CD
- GitFlow workflow enforcement

### Documentation
- Main README with quick start guide
- API documentation
- Deployment guide
- GitFlow branching strategy guide
- Installation scripts for all tools

[Unreleased]: https://github.com/nirgeier/DevOps-Demo-Project/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/nirgeier/DevOps-Demo-Project/releases/tag/v1.0.0
