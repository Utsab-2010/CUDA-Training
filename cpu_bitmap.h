#ifndef __CPU_BITMAP_H__
#define __CPU_BITMAP_H__

#include <iostream>
#include <fstream>
#include <string>
#include <GL/glut.h>

struct CPUBitmap {
    unsigned char* pixels;
    int width, height;

    CPUBitmap(int w, int h) : width(w), height(h) {
        pixels = new unsigned char[width * height * 4]; // RGBA
    }

    ~CPUBitmap() {
        delete[] pixels;
    }

    unsigned char* get_ptr() const {
        return pixels;
    }

    void display_and_exit();
    void save_to_file(const std::string& filename);
};

#endif
