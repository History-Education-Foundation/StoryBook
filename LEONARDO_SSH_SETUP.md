# Leonardo SSH Auto-Setup

This setup provides automatic SSH access to the Leonardo server when opening VSCode terminals.

## Quick Start

### Option 1: Using the Setup Script (Recommended)

1. Run the setup script:
   ```bash
   ./setup-leonardo-ssh.sh
   ```

2. Copy the public key that's displayed

3. On Leonardo server (3.133.157.176), add the key:
   ```bash
   echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

4. Open a new terminal in VSCode - it will auto-connect!

### Option 2: Building with Docker

1. Build the VSCode image with SSH pre-configured:
   ```bash
   docker build -f Dockerfile.vscode -t kody06/llamabot-vscode:ssh .
   ```

2. Update `docker-compose.yml` to use the new image:
   ```yaml
   code:
     image: kody06/llamabot-vscode:ssh
   ```

3. Restart the container:
   ```bash
   docker-compose up -d code
   ```

4. Open a terminal in VSCode and run:
   ```bash
   setup-leonardo-ssh
   ```

5. Follow the instructions to add your key to Leonardo

## How It Works

- **SSH Key**: Generates an ED25519 key pair in `/config/.ssh/`
- **SSH Config**: Creates `~/.ssh/config` with Leonardo server details
- **Quick Alias**: Adds `leo` command for quick SSH access
- **Auto-connect**: Optional - only enabled when `AUTO_SSH_LEONARDO=1` is set
- **Persistence**: All keys are stored in the `code_config` Docker volume

## Connecting to Leonardo

### Manual Connection (Default)
```bash
leo              # Quick alias
ssh leonardo     # Full command
```

### Auto-Connect (Optional)

Auto-connect is **disabled by default**. Enable it with one of these methods:

**Method 1 - Permanent (Recommended)**
Add to `/config/.bashrc`:
```bash
export AUTO_SSH_LEONARDO=1
```

**Method 2 - Docker Environment Variable**
In `docker-compose.yml`:
```yaml
code:
  image: kody06/llamabot-vscode:ssh
  environment:
    - AUTO_SSH_LEONARDO=1  # Add this line
```

**Method 3 - Per-Session**
```bash
export AUTO_SSH_LEONARDO=1
# Now open new terminals - they'll auto-connect
```

**To disable auto-connect temporarily:**
```bash
unset AUTO_SSH_LEONARDO
# Or
export AUTO_SSH_LEONARDO=0
```

## Configuration

Edit these values in the setup script or Dockerfile:

```bash
LEONARDO_IP="3.133.157.176"
LEONARDO_USER="ubuntu"
```

## Troubleshooting

### Permission denied (publickey)
- Ensure you've added the public key to Leonardo's `~/.ssh/authorized_keys`
- Check the username matches (default: `ubuntu`)

### Want local shell instead of auto-connect
- Auto-connect is disabled by default - just don't set `AUTO_SSH_LEONARDO=1`
- If it's enabled and you need local shell, unset it: `unset AUTO_SSH_LEONARDO`

### Key already exists
- The script won't overwrite existing keys
- To regenerate, delete `/config/.ssh/id_ed25519*` first

## Files

- `setup-leonardo-ssh.sh` - One-time setup script
- `Dockerfile.vscode` - Dockerfile with SSH pre-configuration
- `/config/.ssh/id_ed25519` - Private SSH key (persisted in volume)
- `/config/.ssh/config` - SSH client configuration
- `/config/.bashrc` - Auto-connect configuration
