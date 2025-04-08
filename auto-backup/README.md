# auto-backup
The program archives files and directories listed in a given text file, compresses them to `tar.gz` format and stores them in `$HOME/auto-backups/`. By default, only the latest 5 backups are kept, you can edit `maxKeep` variable to change it.

Run it with the command:

    $ ./auto-backup.sh <filePaths>

Write your paths in absolute path into a text file and provide it as the argument.
