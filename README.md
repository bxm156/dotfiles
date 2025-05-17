# Generate install.sh for VSCode / CodeSpaces
You can use chezmoi to manage your dotfiles in GitHub Codespaces, Visual Studio Codespaces, and Visual Studio Code Remote - Containers.

https://www.chezmoi.io/user-guide/machines/containers-and-vms/


```
chezmoi generate install.sh > install.sh
chmod a+x install.sh
echo install.sh >> .chezmoiignore
git add install.sh .chezmoiignore
git commit -m "Add install.sh"
```