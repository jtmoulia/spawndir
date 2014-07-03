# SpawnDir

Spawns commands from the file system. This exists to provide a simple
mechanism for spawning and managing processes: simply add an
executable, or a symbolic link to one, to a monitored directory. The config
allows arguments to be specified by file or directory.

While not as flexible as upstart, monit, et al., SpawnDir's use of the
filesystem provides a simpler UNIX-ish interface.

## Usage

To use the escript executable:

    ./spawndir DIR [ARGS ...]

where `DIR` is the directory to be monitored, and each command
will be started with the supplied `ARGS`

To run using mix:

    mix run --no-halt

You can configure what is watched via the `:spawndir` application
environment variables:

    :default_opts :: [opt]
    :watch        :: [cmd | {cmd, [opt]}]
      where opt :: string()
            cmd :: string()


## Future Additions

- Check for executable flag
- Package installation
- Monitor filesystem for commands being added/removed
