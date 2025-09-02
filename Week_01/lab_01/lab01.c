#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>


// ======================= Task 0.1 =======================
void task01_datatypes() {
    int age = 21;
    float pi = 3.14;
    double precise_pi = 3.14159265359;
    char grade = 'A';
    
    printf("Size of int: %zu bytes\n", sizeof(int));
    printf("Size of float: %zu bytes\n", sizeof(float));
    printf("Size of double: %zu bytes\n", sizeof(double));
    printf("Size of char: %zu bytes\n", sizeof(char));
    
    printf("Original values:\n");
    printf("Age = %d\n", age);
    printf("Pi = %f\n", pi);
    printf("Precise Pi = %lf\n", precise_pi);
    printf("Grade = %c\n", grade);
    
    printf("\n");

    int pi_to_int = (int)pi;
    printf("Casting float pi=%.2f to int: %d\n", pi, pi_to_int);
    
    float age_to_float = (float)age;
    printf("Casting int age=%d to float: %.2f\n", age, age_to_float);
    
    int precise_to_int = (int)precise_pi;
    printf("Casting double precise_pi=%.5lf to int: %d\n", precise_pi, precise_to_int);
    
    int grade_ascii = (int)grade;
    printf("Casting char grade='%c' to int (ASCII): %d\n", grade, grade_ascii);
    
    char int_to_char = (char)66;  
    printf("Casting int 66 to char: %c\n", int_to_char);
}

// ======================= Task 0.2 =======================
void task02_calculator() {
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
// ======================= Task 0.3 =======================
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
    printf("Guess the number (between 1 and 100)\n");
    while (1) {
        printf("Enter your guess: ");
        scanf("%d", &guess);
        if (guess < secretNumber) {
            printf("Too Low \n");
        } else if (guess > secretNumber) {
            printf("Too High \n");
        } else {
            printf(" Correct You guessed the number\n");
            break;
        }
    }
}

// ======================= Task 0.4 =======================
int isPrime(int n) {
    if (n <= 1) return 0; 
    for (int i = 2;  i < n; i++) {
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
    n = n * factorial(n - 1); 
    return n;
}

// ======================= Task 0.5 =======================
void task05_reverse_string() {
    int length = 0;
    char str[100];
    printf("Enter a string: ");
    scanf("%s", str);
    while (str[length] != '\0') {
        length++;
    }
    int start = 0, end = length - 1;
    char temp;
    while (start < end) {      
        temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        start++;
        end--;
    }
    printf("Reversed string: %s\n", str);
}

void task05_second_largest() {
    int second, largest, i;
    
    int size;
    printf("\nEnter size of array: ");
    scanf("%d", &size);

    int arr[size];
    printf("Enter %d elements:\n", size);
    for (int i = 0; i < size; i++) {
        scanf("%d", &arr[i]);
    }

    if (size < 2) {
        printf("Invalid length! Array must have at least 2 elements.\n");
        return;
    }
    if (arr[0] > arr[1]) {
        largest = arr[0];
        second  = arr[1];
    } else {
        largest = arr[1];
        second  = arr[0];
    }
    for (i = 2; i < size; i++) {
        if (arr[i] > largest) {
            second = largest;
            largest = arr[i];
        } else if (arr[i] > second && arr[i] != largest) {
            second = arr[i];
        }
    }
    if (largest == second) {
        printf("All elements are equal, no 2nd largest.\n");
    } else {
        printf("Second largest element: %d\n", second);
    }
}

// ======================= Task 0.6 =======================
void task06_file_io() {
    int numbers[5];
    
    printf("Enter 5 integers:\n");
    for (int i = 0; i < 5; i++) {
        scanf("%d", &numbers[i]);
    }

    FILE *file = fopen("numbers.txt", "w");  
    if (file == NULL) {
        printf("Error opening file for writing.\n");
    }
    for (int i = 0; i < 5; i++) {
        fprintf(file, "%d ", numbers[i]);
    }
    fclose(file);

    file = fopen("numbers.txt", "r");
    if (file == NULL) {
        printf("Error opening file for reading.\n");

    }

    printf("\nNumbers read from file:\n");
    for (int i = 0; i < 5; i++) {
        fscanf(file, "%d", &numbers[i]);
        printf("%d ", numbers[i]);
    }
    printf("\n");
    fclose(file);
}

// ======================= Task 0.7 =======================
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

// ======================= Task 0.8 =======================
void task08_enum_weekday() {
    enum Weekday { MONDAY = 1, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY };
    int num;
    printf("Enter a number (1 _ 7): ");
    scanf("%d", &num);

    enum Weekday day = num;   

    switch (day) {
        case MONDAY: 
            printf("Monday\n"); 
            break;
        case TUESDAY: 
            printf("Tuesday\n"); 
            break;
        case WEDNESDAY: 
            printf("Wednesday\n"); 
            break;
        case THURSDAY: 
            printf("Thursday\n"); 
            break;
        case FRIDAY: 
            printf("Friday\n"); 
            break;
        case SATURDAY: 
            printf("Saturday\n"); 
            break;
        case SUNDAY: 
            printf("Sunday\n"); 
            break;
        default:  printf("Invalid input! Please enter 1 _ 7.\n");
    }
}

// ======================= Task 0.9 =======================
struct Point {
    int x;
    int y;
};

void task09_struct_distance() {
    struct Point p1, p2;
    float distance;

    printf("Enter first point (x y): ");
    scanf("%d %d", &p1.x, &p1.y);

    printf("Enter second point (x y): ");
    scanf("%d %d", &p2.x, &p2.y);

    distance = sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));

    printf("Euclidean distance = %.2f\n", distance);
}

// ======================= Task 0.10 =======================
int task10_cmd_args(int argc, char *argv[]) {
     if (argc != 3) {
        printf("Usage: %s <number1> <number2>\n", argv[0]);
        return 1; 
    }

    int num1 = atoi(argv[1]);
    int num2 = atoi(argv[2]);

    int sum = num1 + num2;

    printf("The sum of %d and %d is %d\n", num1, num2, sum);
    return 0;
}

// ======================= Main =======================
int main(int argc, char *argv[]) {
    srand(time(NULL)); // Seed random numbers

    // Uncomment tasks as you implement them
     task01_datatypes();
     task02_calculator();
     task03_fibonacci();
     task03_guessing_game();
     task04_prime_numbers();
     printf("Factorial of 5 = %d\n", factorial(5));
     task05_reverse_string();
     task05_second_largest();
     task06_file_io();
     task07_bitwise_ops();
     task08_enum_weekday();
     task09_struct_distance();
     task10_cmd_args(argc, argv);

    return 0;
}
