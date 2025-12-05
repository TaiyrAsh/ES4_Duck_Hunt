from PIL import Image
 
img = Image.open("../images/background.png").convert("RGB")
 
w = 640
h = 480
TILE_SIZE = 4
TILE = 16
out_img = Image.new("RGB",(w//TILE_SIZE,h//TILE_SIZE))
# w,h = img.size
 

print(img.size)
 
addr = 0
 
tiles_x = w // TILE_SIZE
tiles_y = h // TILE_SIZE
 
def to6Bit(r,g,b):
    r_new = r >> 6
    g_new = g >> 6
    b_new = b >> 6
 
    val = (r_new << 4) | (g_new << 2) | b_new
    return val
 
for Ty in range(tiles_y):
    for Tx in range(tiles_x):
        rsum = 0
        gsum = 0
        bsum = 0
        for py in range(TILE_SIZE):
            for px in range(TILE_SIZE):
                y = Ty * TILE_SIZE + py
                x = Tx * TILE_SIZE + px
 
                r, g, b = img.getpixel((x,y))
                rsum += r
                gsum += g
                bsum += b
               
        ravg = rsum // TILE
        gavg = gsum // TILE
        bavg = bsum // TILE
        r6, g6, b6 = (ravg >> 6) * 85, (gavg >> 6) * 85, (bavg >> 6) * 85
        # for py2 in range(TILE_SIZE):
        #     for px2 in range(TILE_SIZE):
        out_img.putpixel((Tx, Ty), (r6, g6, b6))
 
       
        val = to6Bit(ravg,gavg,bavg)
       
out_img.save("compressed.png")
print("Color Compression Complete\n")