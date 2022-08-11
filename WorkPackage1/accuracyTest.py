size = 100000
correct = 100000

pyCheck = open("PyCheck.txt","r")
pyResults = pyCheck.read().split(",")
pyCheck.close()

cCheck = open("CCheck.txt", "r")
cResults = cCheck.read().split(",")
cCheck.close()

for i in range(size):
    if round(float(pyResults[i]),16) != round(float(cResults[i]),16):
        correct -= 1

print(correct/size)
    
    