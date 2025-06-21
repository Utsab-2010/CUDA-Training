#include "cpu_bitmap.h"
#include <GL/glut.h>

void CPUBitmap::display_and_exit() {
    glClear(GL_COLOR_BUFFER_BIT);
    glDrawPixels(width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    glutSwapBuffers();
    glutMainLoop();  // show until window is closed
}

void CPUBitmap::save_to_file(const std::string& filename) {
    std::ofstream f(filename, std::ios::out | std::ios::binary);
    if (!f) return;

    int filesize = 54 + 3 * width * height;
    unsigned char bmpfileheader[14] = {
        'B','M',
        (unsigned char)(filesize),
        (unsigned char)(filesize >> 8),
        (unsigned char)(filesize >> 16),
        (unsigned char)(filesize >> 24),
        0,0,0,0,
        54,0,0,0
    };

    unsigned char bmpinfoheader[40] = {
        40,0,0,0,
        (unsigned char)(width),
        (unsigned char)(width >> 8),
        (unsigned char)(width >> 16),
        (unsigned char)(width >> 24),
        (unsigned char)(height),
        (unsigned char)(height >> 8),
        (unsigned char)(height >> 16),
        (unsigned char)(height >> 24),
        1,0,24,0
    };

    f.write((char*)bmpfileheader, 14);
    f.write((char*)bmpinfoheader, 40);

    for (int y = height - 1; y >= 0; y--) {
        for (int x = 0; x < width; x++) {
            int i = (y * width + x) * 4;
            f.put(pixels[i + 2]);
            f.put(pixels[i + 1]);
            f.put(pixels[i + 0]);
        }
    }

    f.close();
}
