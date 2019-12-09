/******************************************************************************
 * Purpose                                                                    *
 *   This file contains the functionality and algorithm for merging text or   *
 *   images within another image.                                             *
 *                                                                            *
 * Resources                                                                  *
 *   Algorithm: https://tinyurl.com/y7hrhfxo                                  *
 *                                                                            *
 * Date          Issue No.   Author     Description                           *
 * -------------------------------------------------------------------------- *
 * 26 Aug 2018               BJC        Initial commit.                       *
 *                                                                            *
 *****************************************************************************/

void hide_image(const char* destination, const char* source);
void unhide_image(const char* destination);
void hide_text (const char* image, const char* text);
void unhide_text(const char* image);
