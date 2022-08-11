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
    while(k < len(str(cResults[i])) and k < len(str(pyResults[i])) and str(pyResults[i])[k] == str(cResults[i])[k] ):
        k += 1
    k -= str(pyResults[i]).index('.') - 1
    total += k

print(total/size)
    
    