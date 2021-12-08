file = open('ootx0.txt', "r")
lines = file.readlines()
file.close()

print(repr(lines[0]))
line0 = lines[0]
shaped = ""
for line in lines:
    tmp = ""
    blank_nb = 0
    for i in line:
        if i not in [' ', '-']:
            tmp += i
            blank_nb = 0
        elif i == '-':
            pass
        elif blank_nb > 2:
            tmp += '\n'
            break
        else:
            blank_nb += 1

    shaped += "[[0x" + tmp[:6] + ", 0x" + tmp[8:14] + "], [0x" + tmp[16:22] + ", 0x" + tmp[24:30] + "]],\n"

file = open("ootx_shaped.txt", "a")
file.write(shaped)
file.close()
