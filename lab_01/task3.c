#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void task03_fibonacci() {
    int i, n;

    int t1 = 0, t2 = 1;

    int nextTerm = t1 + t2;

    printf("Enter the number of terms: ");
    scanf("%d", &n);

    printf("Fibonacci Series: %d, %d, ", t1, t2);

    for (i = 3; i <= n; ++i) {
        printf("%d, ", nextTerm);
        t1 = t2;
        t2 = nextTerm;
        nextTerm = t1 + t2;
    }
}

void task03_guessing_game() {
    
    int secretNumber, guess;

    srand(time(0));
    secretNumber = rand() % 100 + 1; 

    printf("Guess the number (between 1 and 100)!\n");

    while (1) {
        printf("Enter your guess: ");
        scanf("%d", &guess);

        if (guess < secretNumber) {
            printf("Too Low! Try again.\n");
        } else if (guess > secretNumber) {
            printf("Too High! Try again.\n");
        } else {
            printf(" Correct! You guessed the number.\n");
            break;
        }
    }
}

int main (){
    task03_fibonacci();
    task03_guessing_game();
    return 0;
}

