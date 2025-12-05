from PIL import Image
 
img = Image.open("6_Bit_Output.png").convert("RGB")
 
PALETTE_MAP = {
    ( 64, 128,  64): 0, # (01, 10, 01)
    (  0,  64,   0): 1, # (00, 01, 00)
    (  0,   0,   0): 2, # (00, 00, 00)
    (  0, 192, 192): 3, # (00, 11, 11)
    ( 64,   0,   0): 4, # (01, 00, 00)
    (128, 192,   0): 5  # (10, 11, 00)
}


# w,h = img.size
 
w = 160
h = 120
print(img.size)
print()
 
 
# print(f"Image size: {img.size}")
 
out = open("output.bin", "w")




for y in range(h):
    for x in range(w):
        r, g, b = img.getpixel((x, y))
        index = PALETTE_MAP[(r,g,b)]
        out.write(f"{index:X}\n")
        print(f"{index:X}")
    print("\n")
out.close()
 
print("ROM Complete\n")