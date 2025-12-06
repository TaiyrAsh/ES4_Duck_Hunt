from PIL import Image
 
img = Image.open("6_Bit_Pin_Output.png").convert("RGB")
 
PALETTE_MAP = {
(192,   0, 192): 0,  # (11, 00, 11)
    (128, 128, 128): 1,  # (10, 10, 10)
    (128,  64,   0): 2,  # (10, 01, 00)
    (192,   0,   0): 3,  # (11, 00, 00)
    (  0,   0,   0): 4,  # (00, 00, 00)
    (192, 192, 192): 5,  # (11, 11, 11)
    (128,   0,   0): 6,  # (10, 00, 00)
    ( 64,  64,  64): 7,  # (01, 01, 01)
    (192, 128,   0): 8,  # (11, 10, 00)
    (192, 128,   0): 9,  # (11, 10, 00)
}



# w,h = img.size
 
w = 150
h = 50
print(img.size)
print()
 
 
# print(f"Image size: {img.size}")
 
out = open("pin_sprite.taiyr", "w")




for y in range(h):
    for x in range(w):
        r, g, b = img.getpixel((x, y))
        index = PALETTE_MAP[(r,g,b)]
        out.write(f"{index:X}\n")
        print(f"{index:X}")
    print("\n")
out.close()
 
print("ROM Complete\n")