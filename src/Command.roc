interface Command
    exposes [exit, Command, CommandOutput, runCommand]
    imports [Task.{ Task }, InternalTask, Effect, Path.{ Path }]

## Represents an OS command that can be run with `runCommand`
Command : [ InternalCommand { executable: Str, args: List Str, workingDirectory: Result Path {} } ]
# TODO: Convert `workingDirectory` to use an optional record field. I'm not quite sure how to
# do this in type aliases.

## When something went wrong with a `Command`...


## Creates a `Command` from an executable which can then be built upon:
##     command "git"
##     |> withArgs ["clone", "https://github.com/roc-lang/basic-cli.git"]
##     |> inDir (Path.fromStr "~/develop")
##     |> run
command : Str -> Command
command = \executable ->
    InternalCommand {
        executable,
        args: [],
        workingDir: Err {},
    }

## Add arguments to a `Command`. Note that flags are seperate from their values:
##     command "sh"
##     |> withArgs ["-C", "'echo hello'"]
withArgs : Command, List Str -> Command
withArgs = \command, args ->
    when command is
        InternalCommand internals ->
            { internals & args: List.concat internals.args args }

## Sets the working directory of the `Command`:
inDir : Command, Path -> Command
inDir = \command, dir ->
    when command is
        InternalCommand internals ->
            { internals & workingDir: Ok dir }

## Spawns a `Command` process, inheriting
## `stdin`, `stdout` and `stderr` from your application:
##     main =
##         exitStatus <-
##             command "ls"
##             |> inDir "../examples"
##             |> spawn
##             |> Task.await
## Note that this task only fails if the process fails
## to start, not if the process is unexpectedly terminated
## or returns an error exit code.
spawn : Command -> Task ExitStatus {}
spawn = \command ->
    # TODO: Fix our C ABI codegen so that we don't have to perform this Box.box heap allocation
    Effect.runCommand (Box.box command)
    |> InternalTask.fromEffect