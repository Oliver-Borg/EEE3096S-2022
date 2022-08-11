with open("results/results1660247500.txt", 'r') as f:
    a = f.readlines()
headings = ['Language', 'Threads', 'Optimisation', 'Bit Width', 'Time', 'Run', 'Unroll', 'Accuracy']
with open("results.csv", 'w') as f:
    f.write(','.join(headings))
    i = 0
    run = 1
    flags = ''
    optimiser = ''
    unroll = False
    width = ''
    threads = ''
    acc = ''
    while(i < len(a)):
        if 'Elapsed time' in a[i]:
            f.write('\nPython, 0, None, float, ' + str(float(a[i][22:].strip())/1000) + f', {run}, False, 16')
            run+=1
        if 'CFLAGS' in a[i]:
            flags = a[i][a[i].index('-O'):]
            optimiser = flags[flags.index('-O'):flags.index(' ')]
            unroll = 'unroll' in flags[flags.index(' '):] 
            run = 1
            width = a[i+1].strip()
            if "Thread_Count" in a[i+2]:
                threads = a[i+2].split(' ')[2].strip()
        if 'Accuracy' in a[i]:
            acc = a[i+1].strip()
        if 'Time:' in a[i]:
            f.write(f'\nC, 0, {optimiser}, {width}, ' + a[i][6:14].strip() + f', {run}, {unroll}, {acc}')
            run+=1
        elif 'Time taken' in a[i]:
            f.write(f'\nC, {threads}, {optimiser}, {width}, ' + a[i].split(' ')[7].strip() + f', {run}, {unroll}, {acc}')
            run+=1

        i+=1

