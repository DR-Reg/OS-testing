from PIL import Image

im = Image.open("scripts/micro-os.png")
dbg = open("scripts/output-dbg.txt", "w+")
out = open("src/logo-data.nasm", "w+")
w, h = im.size
# RLE:
# each byte is <1 bit: value> <7 bits: count>
curr_val = 0
curr_val_count = 0
byte_count = 0
skips = 0
out.write("logo_data: db")
for row in range(h):
    for col in range(0, w, (1+skips)):
        pix = im.getpixel((col, row))
        dbg.write("1" if pix[0] < 255 else "0")
        new_val = int(pix[0] < 255)
        if new_val != curr_val:
            to_write = (curr_val << 7) | curr_val_count
            out.write(" " + hex(to_write) + ",")
            byte_count += 1
            curr_val = new_val
            curr_val_count = 1
        else:
            curr_val_count += 1
            # prevent overflow
            if curr_val_count == 127:
                to_write = (curr_val << 7) | curr_val_count
                out.write(" " + hex(to_write) + ",")
                byte_count += 1
                curr_val_count = 0
    dbg.write("\n")

to_write = (curr_val << 7) | curr_val_count
out.write(" " + hex(to_write))
byte_count += 1
dbg.close()
out.close()
print("Output", str(byte_count), "bytes")