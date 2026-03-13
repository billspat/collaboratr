# remove line 2 from a csv file, used by data-entry for column directions/description.

this will read all lines of a test file (which can take a long
time/memory for a long file), remove some of the lines by number and
write those to disk. If no new_file_path param is sent, will overwrite
the original file which will be lost it will write a file with standard
POSIX (linux/mac) line endings for now

## Usage

``` r
remove_comment_line(local_file_path, line_numbers = 2, new_file_path = NULL)
```

## Arguments

- local_file_path:

  path to text file on your disk, relative or absolute

- line_numbers:

  default 2, 1 number or a vector, range of numbers to exclude (2:5)

- new_file_path:

  optional new name to write to, by default will use the local_file_path
  and overwrite
