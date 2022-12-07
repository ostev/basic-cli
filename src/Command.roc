interface Command
    exposes [exit, Command, CommandOutput, runCommand]
    imports [Task.{ Task }, InternalTask, Effect, Path.{ Path }]

## Represents an OS command that can be run with `runCommand`
Command : [ InternalCommand { executable: Str, args: List Str, workingDirectory: Result Path {} } ]
# TODO: Convert `workingDirectory` to use an optional record field. I'm not quite sure how to
# do this in type aliases.

## When something went wrong with a `Command`...
Error : {  }

## Creates a `Command` from an executable which can then be built upon:
##     command "git"
##     |> withArgs ["clone", "https://github.com/roc-lang/basic-cli.git"]
##     |> inDir (Path.fromStr "~/develop")
##     |> toTask
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

runCommand : Command -> Task Str Error
runCommand = \command ->
    # TODO: Fix our C ABI codegen so that we don't this Box.box heap allocation
    Effect.runCommand (Box.box command)
    |> InternalTask.fromEffect