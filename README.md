# Firebase Studio SSH Workspace

This workspace automatically sets up an SSH reverse tunnel to a relay server.

## Connection

```bash
ssh -J idx-relay@idx.yaoshen.de5.net:2022 user@default-13412936
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

## Optional SSH config

Add this to `~/.ssh/config` if you want the short form `ssh -J idx.yaoshen.de5.net default-13412936`. The Host alias is named `idx.yaoshen.de5.net`, but it currently points to the working sish IP `117.31.178.161:2022`.

```sshconfig
Host idx.yaoshen.de5.net
  HostName 117.31.178.161
  Port 2022
  User idx-relay
  IdentityFile ~/.ssh/idx_relay_ed25519
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host default-13412936
  User user
  IdentityFile ~/.ssh/idx_client_ed25519
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

Then connect with:

```bash
ssh -J idx.yaoshen.de5.net default-13412936
```

Without SSH config, use the explicit form:

```bash
ssh -J idx-relay@117.31.178.161:2022 user@default-13412936
```
