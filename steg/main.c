/*
 * Name:
 *     main.c
 *
 * Description:
 *     This file executes the Lodepng library functions
 *
 */
#include <argp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "include/steganography.h"
#include "include/util.h"

typedef struct args_t
{
  char *encodedFile;
  int decode;

  union Input
  {
    char *image;
    char *string;
  } input;

} args;

void handle_options(int argc, char ** argv, args *a)
{
  int opt;

  while ((opt = getopt(argc, argv, "e:s:d:")) != -1)
  {
    switch(opt)
    {
      case 'e':
        a->encodedFile = malloc(strlen(optarg) + 1);
        strcpy(a->encodedFile, optarg);
        break;

      case 's':
        a->input.string = malloc(strlen(optarg) + 1);
        strcpy(a->input.string, optarg);
        break;

      case 'd':
        a->decode = 1;
        a->encodedFile = malloc(strlen(optarg) + 1);
        strcpy(a->encodedFile, optarg);
        break;

      default:
        fprintf(stderr,
            "Usage: %s -e {filename.png} -s {string-to-encode}\n", argv[0]);
        fprintf(stderr,
            "   or: %s -d {filename.png}\n", argv[0]);
        exit(EXIT_FAILURE);
    }
  }

  return;
}

int main(int argc, char ** argv)
{
    args a;
    a.encodedFile   = NULL;
    a.decode        = 0;

    handle_options(argc, argv, &a);

    if (is_valid_name(&a.encodedFile))
    {
        if (a.decode)
        {
          unhide_text(a.encodedFile);
          free(a.encodedFile);
        }
        else
        {
          hide_text(a.encodedFile, a.input.string);
          free(a.encodedFile);
          free(a.input.string);
        }
    }
    else
    {
      fprintf(stderr, "Invalid name %s\n", a.encodedFile);
    }

    return 0;
}

