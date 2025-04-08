# file-renamer
The program renames all regular files within `dirPath` including files within nested directories. <br> Files will be renamed to `filename`_`num` where `num` begins counting from `start`. <br> e.g. cat_1.png, cat_2.png, ...

Run it with the command:

    $ ./file_renamer.sh <dirPath> <filename> <start?=1>

> [!WARNING]
> Renaming cannot be undone.

### Reflections