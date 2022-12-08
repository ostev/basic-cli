interface Command
    exposes [ Command
            , ExitStatus
            , fromExecutable
            , withArgs
            , inDir
            , spawn
            ]
    imports [ Task.{ Task }
            , InternalTask
            , Effect
            , Path.{ Path }
            , InternalCommand ]


## Represents an OS command that can be run with `runCommand`
Command : InternalCommand.Command

ExitStatus : InternalCommand.ExitStatus

## Creates a `Command` from an executable which can then be built upon:
##     fromExecutable "git"
##     |> withArgs ["clone", "https://github.com/roc-lang/basic-cli.git"]
##     |> inDir (Path.fromStr "~/develop")
##     |> run
fromExecutable : Str -> Command
fromExecutable = \executable ->
    {
        executable,
        args: [],
        workingDir: Err {},
    }

## Add arguments to a `Command`. Note that flags are seperate from their values:
##     fromExecutable "sh"
##     |> withArgs ["-C", "'echo hello'"]
withArgs : Command, List Str -> Command
withArgs = \command, args ->
    { command & args: List.concat command.args args }

## Sets the working directory of the `Command`:
inDir : Command, Path -> Command
inDir = \command, dir ->
    { command & workingDir: Ok dir }

## Spawns a `Command` process, inheriting
## `stdin`, `stdout` and `stderr` from your application:
##     main =
##         exitStatus <-
##             fromExecutable "ls"
##             |> inDir "../examples"
##             |> spawn
##             |> Task.await
## Note that this task only fails if the process fails
## to start, not if the process is unexpectedly terminated
## or returns an error exit code.
spawn : Command -> Task ExitStatus {}
spawn = \command ->
    # TODO: Fix our C ABI codegen so that we don't have to perform this Box.box heap allocation
    Effect.spawnCommand (Box.box command)
    |> InternalTask.fromEffect