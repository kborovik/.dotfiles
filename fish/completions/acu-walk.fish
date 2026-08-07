function _acu_walk_completion;
    set -l response (env _ACU_WALK_COMPLETE=fish_complete COMP_WORDS=(commandline -cp) COMP_CWORD=(commandline -t) acu-walk);

    for completion in $response;
        set -l metadata (string split "," $completion);

        if test $metadata[1] = "dir";
            __fish_complete_directories $metadata[2];
        else if test $metadata[1] = "file";
            __fish_complete_path $metadata[2];
        else if test $metadata[1] = "plain";
            echo $metadata[2];
        end;
    end;
end;

complete --no-files --command acu-walk --arguments "(_acu_walk_completion)";
