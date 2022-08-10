with open("results.txt", 'r') as f:
    a = f.readlines()
headings = ['Language', 'Threads', 'Optimisation', 'Bit Width', 'Time', 'Run', 'Unroll']
with open("results.csv", 'w') as f:
    f.write(','.join(headings))
    i = 0
    run = 1
    flags = ''
    optimiser = ''
    unroll = False
    width = ''
    thread_index = -1
    threads = [2, 4, 8, 16, 32, 1]
    while(i < len(a)):
        if 'Elapsed time' in a[i]:
            f.write('\nPython, 0, None, float, ' + str(float(a[i][22:].strip())/1000) + f', {run}, False')
            run+=1
        if 'CFLAGS' in a[i]:
            if 'unthreaded' not in a[i-1]:
                thread_index = (thread_index+1)%6
            flags = a[i][a[i].index('-O'):]
            optimiser = flags[flags.index('-O'):flags.index(' ')]
            unroll = 'unroll' in flags[flags.index(' '):] 
            run = 1
            width = a[i+1].strip()
        if 'Time:' in a[i]:
            f.write(f'\nC, 0, {optimiser}, {width}, ' + a[i][6:14].strip() + f', {run}, {unroll}')
            run+=1
        elif 'Time taken' in a[i]:
            f.write(f'\nC, {threads[thread_index]}, {optimiser}, {width}, ' + a[i].split(' ')[7].strip() + f', {run}, {unroll}')
            run+=1

        i+=1

