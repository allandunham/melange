/*****************************************************************************
 * Purpose                                                                   *
 *   This file contains the functionality relating to reading, writing, and  *
 *   access to the images.                                                   *
 *                                                                           *
 * Resources                                                                 *
 *   Initial source code for this file provided by                           *
 *          http://zarb.org/%7Egc/html/libpng.html                           *
 *   LibPNG                                                                  *
 *                                                                           *
 * Date          Issue No.   Author     Description                          *
 * --------------------------------------------------------------------------*
 * 26 Aug 2018               BJC        Initial commit.                      *
 *                                                                           *
 *****************************************************************************/

#define PNG_DEBUG 3
#include <stdbool.h>
#include "lodepng.h"
typedef struct RGB_t{
    int r;
    int g;
    int b;
} RGB;

typedef struct Image_t{
    unsigned width;
    unsigned height;
    unsigned char* image;
} Image;

bool read_png_file(char* filename, Image* image);
void write_png_file(char* filename, Image* image);
void get_RGB_value(Image* image, RGB* rgb, int x, int y);
void set_RGB_value(Image* image, RGB* rgb, int x, int y);
