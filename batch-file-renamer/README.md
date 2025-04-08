# batch-file-renamer
The program renames all regular files pointed by `dirPath` including files within nested directories. Files will be renamed as `filename`_`num` where `num` begins counting from `start`. <br> e.g. cat_1.png, cat_2.png, ...

Run it with the command:

    $ ./batch_file_renamer.sh <dirPath> <filename> <start?=1>

> [!WARNING]
> Backup your files before proceeding. The renaming processes cannot be undone.

### Reflections
My first bash script. It is quite difficult as many of the syntaxes are still new to me. Command-wise, it is not too difficult as I have used many of them before for everyday tasks like `ls`, `echo`, and `mv`.

In this project, I learned about string manipulation with parameter expansion `${}` and `awk`, command substitution `$()` for creating variables using outputs from commands, and syntaxes for test, if statement, for loop, and array.