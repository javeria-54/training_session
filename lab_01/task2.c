# include <stdio.h>

void task02_calculator () {
    int a, b;
    char op;

    printf("Enter two integers: ");
    scanf("%d %d", &a, &b);

    printf("Choose operation (+ - * / %%): ");
    scanf(" %c", &op);   

    switch (op) {
        case '+':
            printf("Result: %d\n", a + b);
            break;
        case '-':
            printf("Result: %d\n", a - b);
            break;
        case '*':
            printf("Result: %d\n", a * b);
            break;
        case '/':
            if (b != 0)
                printf("Result: %d\n", a / b);
            else
                printf("Error We canot Division by zero\n");
            break;
        case '%':
            if (b != 0)
                printf("Result: %d\n", a % b);
            else
                printf("Error We cannot take Modulus by zero\n");
            break;
        default:
            printf("Invalid operator\n");
    }
}
int main() {
    task02_calculator();
    return 0 ;
}

