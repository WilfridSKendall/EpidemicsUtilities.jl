# Using `github`
Change the remote URL to use SSH:
```bash
git remote set-url origin git@github.com:WilfridSKendall/EpidemicsUtilities.jl.git
```
and then try 
```bash
git push
```
which should succeed without user-interaction.

Public key is in `~/.ssh/id_ed25519.pub` and is already accepted by `git`.
