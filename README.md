# summer-school-debugging

Exercises and dev container environment for Debugging workshop at ICCS Summer School 2025

# Intoduction

This repo provides a devcontainer template which will setup the environment we need to run mdb.

## Installing `mdb`

```bash
uv tool install git+https://github.com/TomMelt/mdb.git
```

## Installing `bplot`

```bash
uv tool install git+https://github.com/TomMelt/bplot.git
```

## bash completion

```bash
eval "$(_MDB_COMPLETE=bash_source mdb)"
eval "$(_BPLOT_COMPLETE=bash_source bplot)"
```
