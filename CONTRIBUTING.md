# Contributing to 5G Network Slicing Project

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Respect differing viewpoints and experiences

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Environment details** (OS, Docker version, etc.)
- **Logs** if applicable

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- **Use case**: Why is this enhancement useful?
- **Proposed solution**: How would it work?
- **Alternatives considered**: Other approaches you've thought about

### Pull Requests

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**:
   - Follow existing code style
   - Add comments for complex logic
   - Update documentation if needed
4. **Test your changes**:
   - Ensure all containers build successfully
   - Test the complete workflow
   - Verify no regressions
5. **Commit your changes**:
   ```bash
   git commit -m "Add: Description of your changes"
   ```
   Use conventional commit messages:
   - `Add:` for new features
   - `Fix:` for bug fixes
   - `Update:` for improvements
   - `Docs:` for documentation
   - `Refactor:` for code refactoring
6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** with:
   - Clear description of changes
   - Reference to related issues
   - Screenshots/logs if applicable

## Development Setup

1. Clone your fork:

   ```bash
   git clone https://github.com/your-username/5g-network-slicing.git
   cd 5g-network-slicing
   ```

2. Build and test:

   ```bash
   # Build all images
   docker build -f dockerimages/Dockerfile -t baseimage:nova .
   docker build -f dockerimages/Dockerfile.5GC -t 5gcimg:nova .
   docker build -f dockerimages/Dockerfile.gnb -t gnb:nova .
   docker build -f dockerimages/Dockerfile.GNU -t gnu:nova .
   docker build -f dockerimages/Dockerfile.UE -t ue:nova .

   # Test deployment
   docker compose up -d
   ```

## Coding Standards

### Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -euo pipefail`
- Add comments for complex operations
- Use meaningful variable names

### Docker

- Multi-stage builds where applicable
- Minimize layer count
- Use `.dockerignore` to exclude unnecessary files
- Pin base image versions

### Configuration Files

- Use YAML for configuration
- Add comments explaining parameters
- Validate syntax before committing

### Documentation

- Use Markdown for all documentation
- Keep line length under 100 characters
- Include code examples where helpful
- Update README when adding features

## Testing Guidelines

Before submitting a PR, ensure:

1. **Build Test**:

   ```bash
   docker compose build
   ```

2. **Deployment Test**:
   - Start all containers
   - Verify 5G Core starts successfully
   - Test UE registration
   - Verify slice assignment

3. **Cleanup Test**:
   ```bash
   docker compose down
   docker compose up -d  # Should work cleanly
   ```

## Areas for Contribution

### High Priority

- [ ] Automated testing framework
- [ ] CI/CD pipeline integration
- [ ] Performance benchmarking tools
- [ ] Enhanced monitoring and visualization

### Medium Priority

- [ ] Additional network slice types
- [ ] Configuration validation scripts
- [ ] Troubleshooting automation
- [ ] Documentation improvements

### Low Priority

- [ ] Code refactoring
- [ ] Additional examples
- [ ] Performance optimizations

## Questions?

If you have questions:

1. Check existing issues and documentation
2. Open a new issue with the "question" label
3. Be patient and respectful when seeking help

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🎉
