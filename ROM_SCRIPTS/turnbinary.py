from PIL import Image
 
img = Image.open("6_Bit_numbers_Output.png").convert("RGB")
 
PALETTE_MAP = {
    (192,   0, 192): 0,  # (11, 00, 11)
    (  0,   0,   0): 1,  # (00, 00, 00)
}



# w,h = img.size
 
w = 60
h = 10
print(img.size)
print()
 
 
# print(f"Image size: {img.size}")
 
out = open("numbers_sprite.samuel", "w")




for y in range(h):
    for x in range(w):
        r, g, b = img.getpixel((x, y))
        index = PALETTE_MAP[(r,g,b)]
        out.write(f"{index:X}\n")
        print(f"{index:X}")
    print("\n")
out.close()
 
print("ROM Complete\n")