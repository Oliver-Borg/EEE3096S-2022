size = 100000
correct = 100000

pyCheck = open("PyCheck.txt","r")
pyResults = pyCheck.read().split(",")
pyCheck.close()

cCheck = open("CCheck.txt", "r")
cResults = cCheck.read().split(",")
cCheck.close()

total = 0

for i in range(size):
    k = 0
    diff = float(cResults[i]) - float(pyResults[i])
    while(k < 16 and int(diff) == 0):
        k += 1
        diff *= 10
    total += k

print(total/size)
    
    