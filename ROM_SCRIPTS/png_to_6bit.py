from PIL import Image
 
IMAGE = "titleCard.png"
OUTPUT = "6BIT_Title_Output.png"
 
img = Image.open(IMAGE).convert("RGB")
 
pixel_data = list(img.getdata())
unique_colors = set()
new_img_data = []
for r, g, b in pixel_data:
    # shifting 6 bits to the right to convert to 6bit RGB then 6 bitd to the left
    # to get back to standard 8 bit rgb for png
    # appending data
    new_img_data.append(((r >> 6) << 6,(g >>6) << 6 ,(b >> 6) << 6))
    unique_colors.add(((r >> 6),(g >>6) ,(b >> 6)))
 
# saving image
new_img = Image.new(img.mode, img.size)
new_img.putdata(new_img_data)
new_img.save(OUTPUT)
 
print("Unique colors:", len(unique_colors))
for r, g, b in unique_colors:
    print(f"({r:02b}, {g:02b}, {b:02b})")