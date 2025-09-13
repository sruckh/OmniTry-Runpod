# GitHub Secrets Configuration Guide

This document outlines the required GitHub secrets for the OmniTry-Runpod CI/CD pipeline.

## Required Secrets

The following secrets must be configured in your GitHub repository settings:

### 1. SSH_PRIVATE_KEY
- **Purpose**: SSH key for secure git operations
- **Type**: Private SSH key (RSA, Ed25519, or ECDSA)
- **Usage**: Used by GitHub Actions to authenticate git operations via SSH
- **Security**: Never expose this key in code or logs

**To generate a new SSH key:**
```bash
# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "github-actions@omnitry-runpod"

# Or generate RSA key (if Ed25519 not supported)
ssh-keygen -t rsa -b 4096 -C "github-actions@omnitry-runpod"
```

**To add to GitHub:**
1. Copy the **private key** content to GitHub Secrets as `SSH_PRIVATE_KEY`
2. Add the **public key** to your GitHub account's SSH keys
3. Test the connection: `ssh -T git@github.com`

### 2. DOCKER_USERNAME
- **Purpose**: DockerHub username for pushing containers
- **Type**: Plain text string
- **Usage**: Login to DockerHub registry
- **Value**: Your DockerHub username

### 3. DOCKER_PASSWORD
- **Purpose**: DockerHub password or access token
- **Type**: Sensitive string
- **Usage**: Authentication for DockerHub pushes
- **Recommendation**: Use DockerHub Access Token instead of password

**To create DockerHub Access Token:**
1. Login to DockerHub
2. Go to Account Settings → Security
3. Create new Access Token with "Read, Write, Delete" permissions
4. Use this token as `DOCKER_PASSWORD`

## Security Best Practices

### SSH Key Security
- ✅ Generate dedicated keys for GitHub Actions (don't reuse personal keys)
- ✅ Use Ed25519 keys when possible (more secure than RSA)
- ✅ Store only the private key in GitHub Secrets
- ✅ Add the public key to your GitHub account
- ❌ Never commit private keys to repository
- ❌ Never log or expose private keys in Actions output

### DockerHub Security
- ✅ Use DockerHub Access Tokens instead of passwords
- ✅ Limit token permissions to minimum required
- ✅ Regularly rotate access tokens
- ✅ Monitor DockerHub for unauthorized pushes
- ❌ Never use personal DockerHub password for automation

## Workflow Security Features

The GitHub Actions workflow includes several security features:

1. **Conditional SSH**: SSH keys only used for non-PR events
2. **Minimal Permissions**: Workflow uses least-privilege permissions
3. **Secure Checkout**: Different checkout methods for PRs vs pushes
4. **Host Key Verification**: Validates GitHub SSH host keys
5. **Secret Protection**: Secrets never logged or exposed in output

## Testing the Configuration

After configuring secrets, test the workflow by:

1. **Push to main branch**: Should trigger build and push to DockerHub
2. **Create PR**: Should build without pushing (test-only)
3. **Check DockerHub**: Verify image appears with correct tags
4. **Check Logs**: Ensure no secrets are exposed in GitHub Actions logs

## Troubleshooting

### SSH Connection Issues
```
Error: Host key verification failed
```
- Check that SSH host keys in workflow are up-to-date
- Verify SSH_PRIVATE_KEY is correctly formatted

### DockerHub Authentication Issues
```
Error: authentication required
```
- Verify DOCKER_USERNAME and DOCKER_PASSWORD are correct
- Ensure DockerHub account has push permissions to gemneye/omnitry-runpod

### Permission Issues
```
Error: insufficient permissions
```
- Check GitHub repository permissions
- Verify DockerHub access token permissions
- Ensure SSH key is added to correct GitHub account

## Repository Configuration

Ensure the following repository settings:

1. **Actions Permissions**: Allow GitHub Actions to run
2. **Secret Access**: Secrets accessible to Actions
3. **Branch Protection**: Optional branch protection rules
4. **Webhook Settings**: Ensure push webhooks are enabled

---

**Security Note**: This file contains documentation only. Never commit actual secret values to the repository.