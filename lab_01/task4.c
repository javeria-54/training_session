#include <stdio.h>

int isPrime(int n) {
    if (n <= 1) return 0; 
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0)
            return 0; 
    }
    return 1; 
}

void task04_prime_numbers() {
    printf("Prime numbers between 1 and 100:\n");
    for (int i = 1; i <= 100; i++) {
        if (isPrime(i)) {
            printf("%d ", i);
        }
    }
    printf("\n");
}

int factorial(int n) {
    if (n == 0 || n == 1) 
        return 1;
    return n * factorial(n - 1); 
}

int main() {
    
    task04_prime_numbers();

    int num = 5;
    printf("Factorial of %d = %d\n", num, factorial(num));

    num = 7;
    printf("Factorial of %d = %d\n", num, factorial(num));

    return 0;
}
