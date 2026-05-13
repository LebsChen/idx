# Firebase Studio SSH Workspace

This workspace automatically sets up an SSH reverse tunnel to a relay server.

## Connection

```bash
ssh -o 'ProxyCommand=ssh -i relay_ed25519 -p 2022 -W %h:%p idx-relay@117.31.178.161' user@default-13412936
```

## Bootstrap

The workspace automatically:
1. Fetches the relay SSH key from `https://idx.yaoshen.de5.net/bootstrap/relay_ed25519`
2. Starts a sish TCP alias tunnel to `117.31.178.161:2022`
3. Exposes local SSH (`127.0.0.1:2222`) as sish alias `default-13412936:22`

## Logs

Check tunnel status:
```bash
cat ~/.ssh/tunnel.log
ps aux | grep ssh
```
