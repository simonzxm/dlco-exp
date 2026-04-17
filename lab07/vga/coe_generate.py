#!/usr/bin/python
import sys
from PIL import Image

# global parameters
coe_path = "image.coe"

def generate(pic_path, coe_path):
    '''
    parse a image to get the highest 4 bits of r,g,b
    :param path: picture path
    :return: array of pix, scanned by line
    '''
    try:
        im = Image.open(pic_path)
    except Exception as e:
        print("Error opening image:", e)
        return

    # Resize to exactly 640x480 and convert to RGB
    width = 640
    height = 480
    padding_height = 512
    im = im.convert("RGB")
    im = im.resize((width, height))
    pix = im.load()

    print("Image scaled to width=%d, height=%d, padding column to %d" % (width, height, padding_height))
    
    with open(coe_path, 'w') as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        for x in range(width):
            for y in range(padding_height):
                if y < height:
                    r, g, b = pix[x, y]
                    r = (r & 0xF0) >> 4
                    g = (g & 0xF0) >> 4
                    b = (b & 0xF0) >> 4
                    pixel_str = "%X%X%X" % (r, g, b)
                else:
                    # Padding elements to align with v_addr[8:0] space (512 entries per column)
                    pixel_str = "000"
                
                f.write(pixel_str)
                
                # Check if it's the last element
                if x == width - 1 and y == padding_height - 1:
                    f.write(";\n")
                else:
                    f.write(",")
                    # Add newline every 32 elements for readability (similar to original image.coe)
                    if (y + 1) % 32 == 0:
                        f.write("\n")
                        
    print("finish successful!!")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python coe_generate.py <path-to-picture-file>")
        sys.exit(1)
    pic_path = sys.argv[1]
    generate(pic_path, coe_path)
