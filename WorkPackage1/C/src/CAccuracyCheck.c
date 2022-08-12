#include "CAccuracyCheck.h"
#define SAMPLE_COUNT 100000
int main(int argc, char** argv)
{

// for i in range(size):
//     k = 0
//     diff = float(cResults[i]) - float(pyResults[i])
//     while(k < 16 and int(diff) == 0):
//         k += 1
//         diff *= 10
//     total += k

// print(total/size)
    FILE *fp;
    FILE *fc;
    double pyVal, cVal;
    int total = 0;
    int r = 0;
    char c = ',';
    fc = fopen("../CCheck.txt", "r");
    fp = fopen("../PyCheck.txt", "r");
    for (int i = 0;i<SAMPLE_COUNT;i++ ){
        r = fscanf(fc,"%lf%c",&cVal, &c);
        r = fscanf(fp,"%lf%c",&pyVal, &c);
        double diff = cVal - pyVal;
        int k = 0;
        while(k < 16 && (int)(diff) == 0)
        {
            k++;
            diff *= 10;
        }
        total += k;
    }
    printf("%.6f\n",(double)(total)/SAMPLE_COUNT);
    fclose(fp);
    fclose(fc);
    return 0;
}