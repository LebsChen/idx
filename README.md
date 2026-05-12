# Firebase Studio SSH Template

Minimal Firebase Studio workspace with OpenSSH reverse tunnel for remote access.

## Usage

Create a new workspace:
```
https://idx.google.com/new?template=https://github.com/LebsChen/idx-ssh-template
```

The workspace will automatically:
1. Fetch SSH relay key from bootstrap server
2. Start reverse tunnel to relay server
3. Expose workspace SSH on relay port 2224

## Architecture

- **Relay server**: idx.yaoshen.de5.net:2222
- **Remote port**: 2224
- **Local SSH**: 127.0.0.1:22
- **Bootstrap fetch**: Downloads relay key at workspace creation

## Access

From client machine:
```bash
ssh -o ProxyCommand="ssh -i relay_key -W %h:%p -p 2222 app@idx.yaoshen.de5.net" \
    -i client_key -p 2224 user@127.0.0.1
```
