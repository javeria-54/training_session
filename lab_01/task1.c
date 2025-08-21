#include <stdio.h>

void task01_datatypes() {
    int age = 21;
    float pi = 3.14;
    double precise_pi = 3.14159265359;
    char grade = 'A';
    
    printf("Size of int: %zu bytes\n", sizeof(int));
    printf("Size of float: %zu bytes\n", sizeof(float));
    printf("Size of double: %zu bytes\n", sizeof(double));
    printf("Size of char: %zu bytes\n", sizeof(char));
    
    printf("\nOriginal values:\n");
    printf("Age = %d\n", age);
    printf("Pi = %f\n", pi);
    printf("Precise Pi = %lf\n", precise_pi);
    printf("Grade = %c\n", grade);
    
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

int main() {
    task01_datatypes();
    return 0;
}

