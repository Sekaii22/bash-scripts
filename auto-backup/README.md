# auto-backup
The program archives files and directories listed in a given text file, compresses them to `tar.gz` format and stores them in `$HOME/auto-backups/`. By default, only the latest 5 backups are kept, you can edit `maxKeep` variable to change it.

Run it with the command:

    $ ./auto-backup.sh <filePaths> <backupLocation?=$HOME> <maxKeep?=5>

Write your paths in absolute into a text file and provide it as the `<filePaths>` argument. `backupLocation` (optional) is where the auto-backups folder will be created, default is home directory. `maxKeep` (optional) is the number of backups to keep, default is 5.

### Reflections
This is my second attempt at writing a bash script and I still feel quite unfamiliar with it. Many of the commands have so many options that sometimes I feel completely overwhelmed with them. The unintuitive name of some of the commands also doesn't help with remembering it. This took embarrassingly long for me to write despite being a very simple script.

Even though it is slow, I do feel that I am progressing and learning new things as I go along. From this project, I learned about how to a run cron job for automating the backup script, using `tar` for bundling and compression, and storage strategies like naming files with timestamps and rotating backups, keeping only the last X backups.
