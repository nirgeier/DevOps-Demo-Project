# Contributing to DevOps Demo Project

Thank you for considering contributing to the DevOps Demo Project! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and collaborative environment for all contributors.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/nirgeier/DevOps-Demo-Project/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Python version, etc.)
   - Screenshots if applicable

### Suggesting Features

1. Check [Issues](https://github.com/nirgeier/DevOps-Demo-Project/issues) for similar suggestions
2. Create a new issue with:
   - Clear feature description
   - Use case and benefits
   - Possible implementation approach

### Pull Requests

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   git clone https://github.com/YOUR_USERNAME/DevOps-Demo-Project.git
   cd DevOps-Demo-Project
   ```

2. **Create a feature branch following GitFlow**
   ```bash
   git checkout develop
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Write clean, readable code
   - Follow existing code style
   - Add tests for new features
   - Update documentation

4. **Test your changes**
   ```bash
   # Run tests
   pytest tests/ -v --cov=app
   
   # Check code style
   flake8 app/ tests/
   black --check app/ tests/
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```
   
   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `test:` Adding tests
   - `refactor:` Code refactoring
   - `chore:` Build process updates

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill in the PR template
   - Link related issues

## Development Setup

### Prerequisites

- Python 3.11+
- Docker
- Git

### Setup Development Environment

```bash
# Clone repository
git clone https://github.com/nirgeier/DevOps-Demo-Project.git
cd DevOps-Demo-Project

# Run initialization script
./scripts/init.sh

# Or manual setup
uv venv
source .venv/bin/activate
uv pip install -e ".[dev]"
```

### Running Tests

```bash
# All tests
pytest tests/

# With coverage
pytest tests/ --cov=app --cov-report=html

# Specific test file
pytest tests/test_main.py -v

# Specific test
pytest tests/test_main.py::test_health_endpoint -v
```

### Code Style

```bash
# Check formatting
black --check app/ tests/

# Apply formatting
black app/ tests/

# Linting
flake8 app/ tests/

# Type checking
mypy app/
```

### Running Locally

```bash
# Development server
python app/main.py

# Production-like (with gunicorn)
gunicorn --bind 0.0.0.0:8080 app.main:app
```

## GitFlow Workflow

This project uses GitFlow. See [GITFLOW.md](docs/GITFLOW.md) for details.

### Branch Naming

- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Critical fixes
- `release/x.y.z` - Release preparation

### Branch Targets

- Features → `develop`
- Bugfixes → `develop`
- Releases → `main`
- Hotfixes → `main`

## Pull Request Guidelines

### PR Title Format

```
[Type] Brief description

Examples:
[Feature] Add JWT authentication
[Bugfix] Fix memory leak in health endpoint
[Docs] Update API documentation
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Feature (new functionality)
- [ ] Bugfix (fixes an issue)
- [ ] Hotfix (critical production fix)
- [ ] Documentation
- [ ] Refactoring
- [ ] Performance improvement

## Related Issues
Closes #123

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally
- [ ] Dependent changes merged
```

### Review Process

1. Automated checks must pass (CI/CD)
2. At least one approval required
3. No unresolved comments
4. Branch up to date with target

## Documentation

### Code Comments

- Use docstrings for functions and classes
- Comment complex logic
- Keep comments up to date

Example:
```python
def process_data(data: dict) -> dict:
    """
    Process incoming data and return formatted result.
    
    Args:
        data: Input data dictionary
        
    Returns:
        Processed data dictionary
        
    Raises:
        ValueError: If data format is invalid
    """
    # Implementation
```

### Documentation Updates

- Update README.md for new features
- Update API.md for API changes
- Update DEPLOYMENT.md for infrastructure changes
- Keep CHANGELOG.md updated

## Testing Requirements

### Unit Tests

- Test all new functions
- Test edge cases
- Test error handling
- Aim for >80% code coverage

### Integration Tests

- Test API endpoints
- Test database interactions
- Test external service integrations

## Project Structure

```
DevOps-Demo-Project/
├── app/                  # Application code
├── tests/               # Test files
├── docker/              # Docker configuration
├── helm/                # Kubernetes Helm charts
├── argocd/              # ArgoCD configuration
├── scripts/             # Utility scripts
├── .github/workflows/   # CI/CD pipelines
└── docs/                # Documentation
```

## Questions?

- Open an issue for questions
- Check existing documentation
- Review closed PRs for examples

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🎉
