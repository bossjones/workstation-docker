# workstation-docker
Dev work station w/ nvim correctly installed among other things


# ppa backports

```
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
```


# symlink ~/bin

```
ln -s `pyenv which flake8` ~/bin/flake8

my_array=(black flake8 chardetect cmakelint conan conan_build_info conan_server cpplint isort monkeytype mypy mypyc pbr pip-compile pipdeptree pip-sync pre-commit pre-commit-validate-config pre-commit-validate-manifest pycodestyle pydoc pyflakes pygmentize pyjwt pylint retype stubgen yapf)

for i in "${my_array[@]}"; do ln -s `pyenv which $i` ~/bin/$i; done


black blackd bottle.py chardetect cmakelint conan conan_build_info conan_server cpplint distro dmypy easy_install easy_install-3.7 epylint flake8 futurize identify-cli inv invoke iptest iptest3 ipython ipython3 isort monkeytype mypy mypyc nodeenv pasteurize pbr pip pip3 pip3.7 pip-compile pipdeptree pip-sync pre-commit pre-commit-validate-config pre-commit-validate-manifest __pycache__ pycodestyle pydoc pyflakes pygmentize pyjwt pylint pyls pyreverse python python3 python3.7 python-config retype stubgen symilar tox tox-quickstart tqdm vint virtualenv virtualenv-clone virtualenvwrapper_lazy.sh virtualenvwrapper.sh wheel yapf

```
