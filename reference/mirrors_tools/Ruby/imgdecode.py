import io
import math
import struct
import sys
import PIL
from PIL import Image

if (len(sys.argv) < 3):
    print("Usage: imgdecode file type hSize vSize");
    exit(1);
imageformat = sys.argv[2];
palettedata = [0, 0, 0, 32, 32, 32, 64, 64, 64, 96, 96, 96, 128, 128, 128, 160, 160, 160, 192, 192, 192, 224, 224, 224];
try:
    with open(sys.argv[1], "rb") as file:
        buf = file.read();
        if (imageformat == "raw"):
            hSize = int(sys.argv[3]);   
            vSize = int(sys.argv[4]);   
            hOff = 6;
            imgBytes = bytearray(vSize*hSize);
            
            vPost = vSize // 8;
            hPost = math.ceil(hSize / 8);
        
            h = 0;
            for i in range (0, 8):
                for j in range (0, vPost):
                    for k in range (0, 3):
                        for l in range (0, hPost):
                            b = struct.unpack_from("B", buf, hOff + i*(vPost*hPost*3) + j*(hPost*3) + k*hPost + l);
                            for m in range(0, 8):
                                x = l*8 + m;
                                y = j*8 + i;
                            
                                if (x >= hSize):
                                    break;
                                imgBytes[y*hSize + x] |= ((b[0] >> (7-m)) & 0x01) << k;
                                #print (x, " ", y, " ", imgBytes[y*hSize + x]);
        elif (imageformat == "rle"):
            header = struct.unpack_from("BBHHHBBB", buf, 0);
            fSize = header[3];
            hPost = header[5];
            vPost = header[6];
            maxK =  1 if header[7] == 7 else 3;
            hSize = hPost*8;
            vSize = vPost;
            imgBytes = bytearray(vSize*hSize);
            c = 0x0b;
            k = 0;
            exit = False;
            destC = 0;
            while not exit:     
                command = struct.unpack_from("B", buf, c);
                #print("%4d"% command[0], " ", vSize*hSize, " " , destC, " ", hex(c), " ", hex(fSize));
                c += 1; 
                
                if (command[0] & 0x80 > 0):
                    repeat = command[0] - 0x80;
                    for i in range(0, repeat):
                        pattern = struct.unpack_from("B", buf, c);
                        c += 1;
                        for m in range(0, 8):
                            imgBytes[destC] |= ((pattern[0] >> (7-m)) & 0x01) << k;
                            destC += 1;
                            if (destC >= vSize*hSize):
                                k += 1;
                                destC = 0;
                                if (k >= maxK):
                                    exit = True;
                                    break;
                        if (exit):
                            break;
                else:
                    pattern = struct.unpack_from("B", buf, c);
                    c += 1;
                    for i in range(0, command[0]):
                        for m in range(0, 8):
                            imgBytes[destC] |= ((pattern[0] >> (7-m)) & 0x01) << k;
                            destC += 1;
                            if (destC >= vSize*hSize):
                                k += 1;
                                destC = 0;
                                if (k >= maxK):
                                    exit = True;
                                    break;
                        if (exit):
                            break;
        im = Image.frombytes("P", (hSize, vSize), bytes(imgBytes));
        im.putpalette(palettedata*32)
        im.save(sys.argv[1]+"conv.png", format="png");
except FileNotFoundError:
    print("Failed to open " + sys.argv[1]);
