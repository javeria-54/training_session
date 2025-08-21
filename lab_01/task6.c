#include <stdio.h>

void task06_file_io(){
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

int main() {
    task06_file_io();
    return 0;
}
