# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_mc_global_optspecs
    string join \n v/verbose q/quiet color= h/help V/version
end

function __fish_mc_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_mc_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_mc_using_subcommand
    set -l cmd (__fish_mc_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c mc -n "__fish_mc_needs_command" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_needs_command" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_needs_command" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_needs_command" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_needs_command" -s V -l version -d 'Print version'
complete -c mc -n "__fish_mc_needs_command" -f -a "java" -d 'Manage Java versions'
complete -c mc -n "__fish_mc_needs_command" -f -a "minecraft" -d 'Manage minecraft versions'
complete -c mc -n "__fish_mc_needs_command" -f -a "init" -d 'Create a new mc package in an existing directory'
complete -c mc -n "__fish_mc_needs_command" -f -a "run" -d 'Run the Minecraft instance'
complete -c mc -n "__fish_mc_needs_command" -f -a "add" -d 'Add mods to a manifest file'
complete -c mc -n "__fish_mc_needs_command" -f -a "remove" -d 'Remove mods from a manifest file'
complete -c mc -n "__fish_mc_needs_command" -f -a "update" -d 'Update all mods to their latest version for the configured Minecraft version'
complete -c mc -n "__fish_mc_needs_command" -f -a "backup" -d 'Start a backup of the world files'
complete -c mc -n "__fish_mc_needs_command" -f -a "restore" -d 'Restore a backup'
complete -c mc -n "__fish_mc_needs_command" -f -a "completions" -d 'Generate a shell completion script'
complete -c mc -n "__fish_mc_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c mc -n "__fish_mc_using_subcommand java; and not __fish_seen_subcommand_from install list help" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand java; and not __fish_seen_subcommand_from install list help" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand java; and not __fish_seen_subcommand_from install list help" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand java; and not __fish_seen_subcommand_from install list help" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand java; and not __fish_seen_subcommand_from install list help" -f -a "install" -d 'Install a specific Java version'
complete -c mc -n "__fish_mc_using_subcommand java; and not __fish_seen_subcommand_from install list help" -f -a "list" -d 'List all available Java versions'
complete -c mc -n "__fish_mc_using_subcommand java; and not __fish_seen_subcommand_from install list help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from install" -s p -l platform -d 'Select a specific platform' -r
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from install" -s a -l architecture -d 'Select a specific architecture' -r
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from install" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from install" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from install" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from list" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from list" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from list" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from help" -f -a "install" -d 'Install a specific Java version'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from help" -f -a "list" -d 'List all available Java versions'
complete -c mc -n "__fish_mc_using_subcommand java; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and not __fish_seen_subcommand_from install list list-loaders help" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand minecraft; and not __fish_seen_subcommand_from install list list-loaders help" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and not __fish_seen_subcommand_from install list list-loaders help" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and not __fish_seen_subcommand_from install list list-loaders help" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and not __fish_seen_subcommand_from install list list-loaders help" -f -a "install" -d 'Install a specific Minecraft version'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and not __fish_seen_subcommand_from install list list-loaders help" -f -a "list" -d 'List all available Minecraft version'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and not __fish_seen_subcommand_from install list list-loaders help" -f -a "list-loaders" -d 'List all available Minecraft loader versions'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and not __fish_seen_subcommand_from install list list-loaders help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from install" -s l -l loader -d 'Specify a mod loader, defaults to vanilla' -r
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from install" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from install" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from install" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list" -l all -d 'show all available versions'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list" -s s -l snapshots -d 'show snapshot versions'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list" -s b -l betas -d 'show beta versions'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list" -s a -l alphas -d 'show alpha versions'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list-loaders" -s l -l loader -d 'List versions for a specific loader' -r
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list-loaders" -s m -l minecraft-version -d 'List loader versions for a specific game version' -r
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list-loaders" -l limit -d 'Limit the number of results' -r
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list-loaders" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list-loaders" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list-loaders" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from list-loaders" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from help" -f -a "install" -d 'Install a specific Minecraft version'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from help" -f -a "list" -d 'List all available Minecraft version'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from help" -f -a "list-loaders" -d 'List all available Minecraft loader versions'
complete -c mc -n "__fish_mc_using_subcommand minecraft; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c mc -n "__fish_mc_using_subcommand init" -l name -d 'Set the resulting instance name, defaults to the directory name' -r
complete -c mc -n "__fish_mc_using_subcommand init" -l preset -r -f -a "vanilla\t''
optimized\t''
technical\t''"
complete -c mc -n "__fish_mc_using_subcommand init" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand init" -l eula -d 'Automatically agree to the Minecraft EULA (https://aka.ms/MinecraftEULA)'
complete -c mc -n "__fish_mc_using_subcommand init" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand init" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand init" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand run" -l manifest-path -d 'Path to mc.toml' -r -F
complete -c mc -n "__fish_mc_using_subcommand run" -l lockfile-path -d 'Path to mc.lock' -r -F
complete -c mc -n "__fish_mc_using_subcommand run" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand run" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand run" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand run" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand add" -l manifest-path -d 'Path to mc.toml' -r -F
complete -c mc -n "__fish_mc_using_subcommand add" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand add" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand add" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand add" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand remove" -l manifest-path -d 'Path to mc.toml' -r -F
complete -c mc -n "__fish_mc_using_subcommand remove" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand remove" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand remove" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand remove" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand update" -l manifest-path -d 'Path to mc.toml' -r -F
complete -c mc -n "__fish_mc_using_subcommand update" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand update" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand update" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand update" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand backup" -l manifest-path -d 'Path to mc.toml' -r -F
complete -c mc -n "__fish_mc_using_subcommand backup" -l name -d 'Name the backup instead of timestamping it; named backups are kept forever, exempt from the retention limit' -r
complete -c mc -n "__fish_mc_using_subcommand backup" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand backup" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand backup" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand backup" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand restore" -l manifest-path -d 'Path to mc.toml' -r -F
complete -c mc -n "__fish_mc_using_subcommand restore" -l backup -d 'Filename of the backup to restore (defaults to the most recent backup)' -r
complete -c mc -n "__fish_mc_using_subcommand restore" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand restore" -l list -d 'List the available backups instead of restoring'
complete -c mc -n "__fish_mc_using_subcommand restore" -l undo -d 'Put the world set aside by the last restore back in place, swapping it with the current world'
complete -c mc -n "__fish_mc_using_subcommand restore" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand restore" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand restore" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand completions" -l color -d 'Coloring: auto, always, never' -r -f -a "auto\t''
always\t''
never\t''"
complete -c mc -n "__fish_mc_using_subcommand completions" -s v -l verbose -d 'Use verbose output (-v info, -vv debug, -vvv trace)'
complete -c mc -n "__fish_mc_using_subcommand completions" -s q -l quiet -d 'Do not print mc log messages'
complete -c mc -n "__fish_mc_using_subcommand completions" -s h -l help -d 'Print help'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "java" -d 'Manage Java versions'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "minecraft" -d 'Manage minecraft versions'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "init" -d 'Create a new mc package in an existing directory'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "run" -d 'Run the Minecraft instance'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "add" -d 'Add mods to a manifest file'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "remove" -d 'Remove mods from a manifest file'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "update" -d 'Update all mods to their latest version for the configured Minecraft version'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "backup" -d 'Start a backup of the world files'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "restore" -d 'Restore a backup'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "completions" -d 'Generate a shell completion script'
complete -c mc -n "__fish_mc_using_subcommand help; and not __fish_seen_subcommand_from java minecraft init run add remove update backup restore completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c mc -n "__fish_mc_using_subcommand help; and __fish_seen_subcommand_from java" -f -a "install" -d 'Install a specific Java version'
complete -c mc -n "__fish_mc_using_subcommand help; and __fish_seen_subcommand_from java" -f -a "list" -d 'List all available Java versions'
complete -c mc -n "__fish_mc_using_subcommand help; and __fish_seen_subcommand_from minecraft" -f -a "install" -d 'Install a specific Minecraft version'
complete -c mc -n "__fish_mc_using_subcommand help; and __fish_seen_subcommand_from minecraft" -f -a "list" -d 'List all available Minecraft version'
complete -c mc -n "__fish_mc_using_subcommand help; and __fish_seen_subcommand_from minecraft" -f -a "list-loaders" -d 'List all available Minecraft loader versions'
