# GitHub CLI Study Guide

Complete guide to mastering GitHub CLI for DevOps automation.

## Overview

This study guide provides hands-on labs and comprehensive documentation for learning GitHub CLI (`gh`) in the context of modern DevOps workflows.

## Labs

The labs directory contains 6 hands-on exercises:

1. **Lab 1: Setup & Authentication** (`lab1-setup.sh`)
   - Install and configure GitHub CLI
   - Authenticate with GitHub
   - Basic configuration

2. **Lab 2: Repository Management** (`lab2-repository.sh`)
   - Clone and fork repositories
   - Create new repositories
   - Repository settings and configuration

3. **Lab 3: Issue Management** (`lab3-issues.sh`)
   - Create and manage issues
   - Labels and milestones
   - Issue templates

4. **Lab 4: Pull Request Workflows** (`lab4-pull-requests.sh`)
   - Create pull requests
   - Review and merge workflows
   - PR automation

5. **Lab 5: GitHub Actions Management** (`lab5-actions.sh`)
   - Trigger workflows
   - View workflow runs
   - Manage artifacts

6. **Lab 6: Release Management** (`lab6-releases.sh`)
   - Create releases
   - Manage tags
   - Release automation

## Running Labs

```bash
cd gh-study/labs
./lab1-setup.sh       # Start with lab 1
./lab2-repository.sh  # Then lab 2, etc.
```

## Quick Reference

### Authentication
```bash
gh auth login         # Login to GitHub
gh auth status       # Check auth status
gh auth logout       # Logout
```

### Pull Requests
```bash
gh pr create         # Create new PR
gh pr list           # List PRs
gh pr view <number>  # View PR details
gh pr merge <number> # Merge PR
```

### Issues
```bash
gh issue create      # Create issue
gh issue list        # List issues
gh issue close <num> # Close issue
```

### Workflows
```bash
gh workflow list     # List workflows
gh run list          # List workflow runs
gh run watch         # Watch current run
```

## Documentation

For detailed command documentation, run:
```bash
gh --help
gh <command> --help
```

Or visit: https://cli.github.com/manual/

## Integration with Project

This project uses GitHub CLI in several automation scripts:
- `scripts/gh-doctor.sh` - Comprehensive diagnostics
- `scripts/gh-create-pr.sh` - Automated PR creation
- `scripts/gh-release.sh` - Release automation
- `scripts/gh-helpers.sh` - Reusable helper functions
