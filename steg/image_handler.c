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

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "include/image_handler.h"

bool read_png_file(char* filename, Image* im)
{
    unsigned error = lodepng_decode32_file(&im->image, 
                                           &im->width, 
                                           &im->height,
                                           filename);
    if(error){
        printf("error %u: %s\n", error, lodepng_error_text(error));
        return false;
    }
    
    return true;
}

/******************************************************************************
 *                                                                            *
 * Writes the PNG image out to a file.                                        *
 *                                                                            *
 * @param[in]  file_name  Name of the file to create.                         *
 * @param[in]  image      Image to save to the file.                          *
 *                                                                            *
 * Date          Issue No.   Author     Description                           *
 * -------------------------------------------------------------------------- *
 * 26 Aug 2018               BJC        Initial commit.                       *
 *                                                                            *
 *****************************************************************************/
void write_png_file(char* filename, Image* im)
{
    unsigned error = lodepng_encode32_file(filename, 
                                           im->image, 
                                           im->width, 
                                           im->height);
    if(error) printf("error %u: %s\n", error, lodepng_error_text(error));
}
/******************************************************************************
 *                                                                            *
 * Returns the pixel of an image at the coordinates x and y.                  *
 *                                                                            *
 * @param[in]  image  Image to retrieve the pixel.                            *
 * @param[out] rgb    RGB values of the pixel.                                *
 * @param[in]  x      X coordinate of the pixel.                              *
 * @param[in]  y      Y coordinate of the pixel.                              *
 *                                                                            *
 * Date          Issue No.   Author     Description                           *
 * -------------------------------------------------------------------------- *
 * 26 Aug 2018               BJC        Initial commit.                       *
 *                                                                            *
 *****************************************************************************/
void get_RGB_value(Image* im, RGB* rgb, int x, int y)
{
    rgb->r = im->image[4 * (y%im->height) * im->width + 4 * (x%im->width) + 0];
    rgb->g = im->image[4 * (y%im->height) * im->width + 4 * (x%im->width) + 1]; 
    rgb->b = im->image[4 * (y%im->height) * im->width + 4 * (x%im->width) + 2];
}

void set_RGB_value(Image* im, RGB* rgb, int x, int y)
{
    im->image[4 * (y%im->height) * im->width + 4 * (x%im->width) + 0] = rgb->r;
    im->image[4 * (y%im->height) * im->width + 4 * (x%im->width) + 1] = rgb->g; 
    im->image[4 * (y%im->height) * im->width + 4 * (x%im->width) + 2] = rgb->b;
}

