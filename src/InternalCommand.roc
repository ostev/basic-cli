interface InternalCommand
    exposes [ Command
            , ExitStatus ]
    imports [ Path.{ Path } ]

# TODO: Convert `workingDirectory` to use an optional record field. I'm not quite sure how to
# do this in type aliases.
Command : { executable: Str, args: List Str, workingDir: Result Path {} }

ExitStatus : [ SignalTerminated, ExitCode I32 ]