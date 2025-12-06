from PIL import Image
 
img = Image.open("6_Bit_DUCK_Output.png").convert("RGB")
 
PALETTE_MAP = {
    (192,   0, 192): 0,  # (11, 00, 11)
    (  0,  64,   0): 1,  # (00, 01, 00)
    (128, 128, 128): 2,  # (10, 10, 10)
    (  0,   0,   0): 3,  # (00, 00, 00)
    (192, 192, 192): 4,  # (11, 11, 11)
    ( 64,   0,   0): 5,  # (01, 00, 00)
    ( 64,  64,  64): 6,  # (01, 01, 01)
    (192, 128,   0): 7,  # (11, 10, 00)
}



# w,h = img.size
 
w = 150
h = 50
print(img.size)
print()
 
 
# print(f"Image size: {img.size}")
 
out = open("duck_sprite.mem", "w")




for y in range(h):
    for x in range(w):
        r, g, b = img.getpixel((x, y))
        index = PALETTE_MAP[(r,g,b)]
        out.write(f"{index:X}\n")
        print(f"{index:X}")
    print("\n")
out.close()
 
print("ROM Complete\n")