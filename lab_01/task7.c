#include <stdio.h>

void task07_bitwise_ops() {

    int a,b;
    char op;

    printf("Enter two integers: ");
    scanf("%d %d", &a, &b);

    printf("Choose operation (&, |, ^, ~, r, l): ");
    scanf(" %c", &op);   

    switch (op) {
        case '&':
            printf("Result: %d\n", a & b);
            break;
        case '|':
            printf("Result: %d\n", a | b);
            break;
        case '^':
            printf("Result: %d\n", a ^ b);
            break;
        case '~':
            printf("Result a: %d, Result b: %d,\n", ~a , ~b);
            break;
        case 'r':
                printf("Result a: %d, Result b: %d\n", a << 1 , b << 1);
            break;
        case 'l':
                printf("Result a: %d , Result b: %d\n", a >> 1 , b >> 1);
            break;
        default:
            printf("Invalid operator!\n");
    }
}
void task07_power_2(){ 

    int num;

    printf("Enter an integer: ");
    scanf("%d", &num);

    if (num > 0 && (num & (num - 1)) == 0) {
        printf("%d is a power of 2.\n", num);
    } else {
        printf("%d is not a power of 2.\n", num);
    }
}

int main() {
    task07_power_2();
    return 0;
}
   
