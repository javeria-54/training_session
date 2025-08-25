#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

// ======================= Part 1: Pointer Basics and Arithmetic =======================

// Task 1.1: Basic pointer usage
void task1_1() {
    int x = 21;
    int *ptr = &x;
    
    printf("value of x: %d\n",x);
    printf("value pointed by ptr: %d\n" , *ptr);
    printf("address of x: %p\n", &x);
    printf("address of ptr: %p\n", &ptr);
    *ptr = 14;
    printf("new value of x: %d\n",x);
    printf("value pointed by ptr: %d\n" , *ptr);
    printf("address of x: %p\n", &x);
    printf("address of ptr: %p\n", &ptr);
}

// Task 1.2: Swap two integers using pointers
void swap(int *a, int *b) {
    printf("value of a: %d\n",*a);
    printf("value of b: %d\n",*b);
    int ptr = *a;
    *a = *b;
    *b = ptr;
    printf("value of a: %d\n",*a);
    printf("value of b: %d\n",*b);
}

// Task 1.3: Pointer arithmetic on array
void task1_3() {
    int numbers[5] = {1, 2, 3, 4, 5};
    int *ptr = numbers; 
    for (int i = 0; i < 5; i++){
        printf(" %d", *(ptr + i)); 
}
    printf("\n");
    int sum = 0; 
    for (int i = 0; i < 5; i++)
        sum += ptr[i];
        { printf("sum of elements in array : %d \n", sum);
}
    int start = 0, end = 4;
    while (start < end) {
        int ptr = numbers[start];
        numbers[start] = numbers[end];
        numbers[end] = ptr;
        start++;
        end--;
    }
    for (int i = 0; i < 5; i++){
        printf(" %d", numbers[i]);
    }    
    printf("\n");
}


// ======================= Part 2: Pointers and Arrays/Strings =======================

// Custom strlen using pointers
int my_strlen( char *s) {
    const char *p = s;
    while (*p){
        p++;
    }
    return p-s;
}

// Custom strcpy using pointers
void my_strcpy(char *dest, const char *src) {
    while (*src) {
        *dest++ = *src++; 
    }
    *dest = '\0';
}

// Custom strcmp using pointers
int my_strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {  
        s1++;
        s2++;
    }
    return (unsigned char)*s1 - (unsigned char)*s2;
}

// Task 2.2: Palindrome checker (case-insensitive)
int is_palindrome( char *s) {
    char *end = s + strlen(s) - 1;
    while (s < end) {
        if (*s != *end) {
            return 1;
        }
        char temp = *s;
        *s++ = *end;
        *end-- = temp;
}
    return 0;
}
// ======================= Part 3: Preprocessor & File I/O =======================

//Macros
#define SQUARE(x) ((x)*(x))      
#define MAX2(a,b)  ((a) > (b)?(a):(b))     
#define MAX3(a,b,c)  (MAX2(MAX2(a,b), (c)))   
#define MAX4(a,b,c,d) (MAX2(MAX3(a,b,c), (d)))  
#define TO_UPPER(c)  (((c) >= 'a' && (c) <= 'z') ? ((c) - 32) : (c))   

void task3_1_macros() {
    printf("SQUARE(5) = %d\n" , SQUARE(5));
    printf("SQUARE(2+3) = %d\n", SQUARE(2+3));

    printf("MAX2(10, 20) = %d \n", MAX2(10, 20));
    printf("MAX2(-5, -2) = %d \n", MAX2(-5, -2));

    printf("MAX3(3, 7, 5) = %d \n", MAX3(3, 7, 5));
    printf("MAX3(1, -1, 0) = %d \n", MAX3(1, -1, 0));

    printf("MAX4(1, 2, 3, 4) = %d \n", MAX4(1, 2, 3, 4));
    printf("MAX4(-10, -20, -5, -15) = %d \n", MAX4(-10, -20, -5, -15));

    printf("TO_UPPER('a') = %c \n", TO_UPPER('a'));
    printf("TO_UPPER('z') = %c \n", TO_UPPER('z'));
    printf("TO_UPPER('A') = %c \n", TO_UPPER('A'));
    printf("TO_UPPER('5') = %c \n", TO_UPPER('5'));    
}

struct Student {
    char name[50];
    int roll;
    float gpa;
};

// Task 3.2: File I/O
void task3_2_fileio() {
    struct Student students[5];
    FILE *fp;

    // Input 5 students
    printf("Enter details of 5 students:\n");
    for (int i = 0; i < 5; i++) {
        printf("\nStudent %d name: ", i + 1);
        scanf("%s", students[i].name);

        printf("Student %d roll: ", i + 1);
        scanf("%d", &students[i].roll);

        printf("Student %d GPA: ", i + 1);
        scanf("%f", &students[i].gpa);
    }

    int topIndex = 0;
    for (int i = 1; i < 5; i++) {
        if (students[i].gpa > students[topIndex].gpa) {
            topIndex = i;
        }
    }

    printf("\nTop student: %s (Roll: %d) with GPA %.2f\n",
           students[topIndex].name,
           students[topIndex].roll,
           students[topIndex].gpa);

    // Save to file
    fp = fopen("students.txt", "w");
    if (fp == NULL) {
        printf("Error opening file for writing!\n");
        return;
    }
    for (int i = 0; i < 5; i++) {
        fprintf(fp, "%s %d %.2f\n",
                students[i].name,
                students[i].roll,
                students[i].gpa);
    }
    fclose(fp);
    printf("\nData saved to students.txt\n");

    // Read back from file
    fp = fopen("students.txt", "r");
    if (fp == NULL) {
        printf("Error opening file for reading!\n");
        return;
    }

    printf("\nReading back from file:\n");
    struct Student temp;
    while (fscanf(fp, "%s %d %f",
                  temp.name,
                  &temp.roll,
                  &temp.gpa) == 3) {
        printf("Name: %s, Roll: %d, GPA: %.2f\n",
               temp.name, temp.roll, temp.gpa);
    }
    fclose(fp);
}


// ======================= Part 4: Advanced Challenge =======================

// Linked List Node
struct Node {
    int data;
    struct Node *next;
};

struct Node* insert_begin(struct Node *head, int value) {
    struct Node *newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = value;
    newNode->next = head;
    return newNode; 
}

struct Node* delete_value(struct Node *head, int value) {
    struct Node *temp = head,
            *prev = NULL;

    if (temp != NULL && temp->data == value) {
        head = temp->next;  
        free(temp);         
        return head;
    }
    while (temp != NULL && temp->data != value) {
        prev = temp;
        temp = temp->next;
    }
    if (temp == NULL) return head;

    prev->next = temp->next;
    free(temp);

    return head;
}

void print_list(struct Node *head) {
    struct Node *curr = head;
    while (curr != NULL) {
        printf("%d -> ", curr->data);
        curr = curr->next;
    }
    printf("NULL\n");
}

void task4_1_linkedlist() {
    struct Node *head = NULL;

    head = insert_begin(head, 10);
    head = insert_begin(head, 20);
    head = insert_begin(head, 30);

    printf("List after insertions: ");
    print_list(head);

    head = delete_value(head, 20);

    printf("List after deleting 20: ");
    print_list(head);

    head = delete_value(head, 100);

    printf("List after trying to delete 100: ");
    print_list(head);
}

// ======================= Part 5: Dynamic Memory Allocation =======================

// Task 5.1: Dynamic array, sum, average
void task5_1_dynamic_array() {
    int *ptr = (int *)malloc(5 * sizeof(int));

    if (ptr == NULL){
        printf("memory allocation failed \n");
    }
    printf("Enter 5 integers:\n");
    for (int i = 0; i < 5; i++) {
        scanf("%d", &ptr[i]);   
    }
    int sum = 0; 
    for (int i = 0; i < 5; i++)
        sum += ptr[i];
        { printf("sum of elements in array : %d \n", sum);
        }
    int avg ;
    avg = sum / 5;
    printf("average of elements in array : %d \n", avg); 

    free(ptr);
}


// Task 5.2: Extend array with realloc
void task5_2_realloc_array() {
    int *ptr = (int *)malloc(5 * sizeof(int)); 
    
    if (ptr == NULL) {
        printf("Initial memory allocation failed\n");
        return;
    }

    printf("Enter 5 integers:\n");
    for (int i = 0; i < 5; i++) {
        scanf("%d", &ptr[i]);   
    }

    printf("Original array: ");
    for (int i = 0; i < 5; i++) {
        printf("%d ", ptr[i]);
    }
    printf("\n");

    int *temp = (int *)realloc(ptr, 10 * sizeof(int));
    if (temp == NULL) {
        printf("Reallocation failed\n");
        free(ptr);
        return;
    }
    ptr = temp;

    printf("Enter 5 integers:\n");
    for (int i = 5; i < 10; i++) {
        scanf("%d", &ptr[i]);   
    }

    printf("Resized array: ");
    for (int i = 0; i < 10; i++) {
        printf("%d ", ptr[i]);
    }
    printf("\n");

    free(ptr); 
}


// Memory Leak Detector (simplified tracking)
#define MAX_PTRS 100
void* allocated_ptrs[MAX_PTRS];
int allocated_count = 0;

void* my_malloc(size_t size) {
    void *ptr = malloc(size);
    if (ptr != NULL) {
        if (allocated_count < MAX_PTRS) {
            allocated_ptrs[allocated_count++] = ptr; 
        } else {
            printf("Error: Too many allocations tracked!\n");
        }
    }
    return ptr;
}

void my_free(void *ptr) {
    if (ptr == NULL) return;

    for (int i = 0; i < allocated_count; i++) {
        if (allocated_ptrs[i] == ptr) {
            free(ptr);
            for (int j = i; j < allocated_count - 1; j++) {
                allocated_ptrs[j] = allocated_ptrs[j+1];
            }
            allocated_count--;
            return;
        }
    }
    printf("Warning: Tried to free untracked pointer %p\n", ptr);
}

void report_leaks() {
    if (allocated_count > 0) {
        printf("(Memory Leak Detected) %d block not freed:\n", allocated_count);
        for (int i = 0; i < allocated_count; i++) {
            printf("  Leak: pointer %p\n", allocated_ptrs[i]);
        }
    } else {
        printf("No memory leaks detected! \n");
    }
}

void task5_3_leak_detector() {
    int *a = (int*) my_malloc(sizeof(int));
    int *b = (int*) my_malloc(5 * sizeof(int));
    int *c;

    *a = 42;
    for (int i = 0; i < 5; i++) b[i] = i + 1;

    my_free(a);
    my_free(b);
    my_free(c);
    report_leaks();
}


// ======================= Final Task: Booth's Multiplication =======================

int add(int a, int b, int q, int q_1) {
    int sum, difference;

    sum = a + b;             
    difference = a - b;      

    if ((q & 1) == 1 && q_1 == 0) {
        a = difference;
    } else if ((q & 1) == 0 && q_1 == 1) {
        a = sum;
    }
    
    a &= 0xFF;
    q &= 0xFF;

    int combined = (a << 9) | (q << 1) | q_1;

    if (a & 0x80) { 
        combined = (combined >> 1) | (1 << 16);  
    } else {
        combined >>= 1;
    }

    a   = (combined >> 9) & 0xFF;
    q   = (combined >> 1) & 0xFF;
    q_1 = combined & 1;

    return (a << 16) | (q << 8) | q_1;
}

int booth_multiply(int multiplicand, int multiplier) {
    int a = 0;
    int b = multiplicand & 0xFF; 
    int q = multiplier & 0xFF;   
    int q_1 = 0;

    for (int count = 0; count < 8; count++) {
        int packed = add(a, b, q, q_1);
        a   = (packed >> 16) & 0xFF;
        q   = (packed >> 8) & 0xFF;
        q_1 = packed & 1;
    }

    int result = (a << 8) | q;
    return (int16_t)result;  
}

void test_booth() {
    int a = 13, b = -3;
    int product = booth_multiply(a, b);
    printf("%d × %d = %d\n", a, b, product);

    a = -7; b = 0;
    product = booth_multiply(a, b);
    printf("%d × %d = %d\n", a, b, product);

    a = 25; b = 4;
    product = booth_multiply(a, b);
    printf("%d × %d = %d\n", a, b, product);

    a = -27; b = -8;
    product = booth_multiply(a, b);
    printf("%d × %d = %d\n", a, b, product);

    a = -67; b = 1;
    product = booth_multiply(a, b);
    printf("%d × %d = %d\n", a, b, product);

    a = 259; b = 4;
    product = booth_multiply(a, b);
    printf("%d × %d = %d\n", a, b, product);

    a = -257; b = -4;
    product = booth_multiply(a, b);
    printf("%d × %d = %d\n", a, b, product);
}


// ======================= Main =======================
int main() {
    // Uncomment and run tasks as you implement

    // --- Part 1 ---
    // task1_1();
    // int a=5, b=10; swap(&a,&b);
    // task1_3();

    // --- Part 2 ---
    // printf("Len = %d\n", my_strlen("Hello"));
    // char buf[100]; my_strcpy(buf,"World");
    // printf("Copied: %s\n", buf);
    // printf("Palindrome? %s\n", is_palindrome("Madam") ? "Yes":"No");

    // --- Part 3 ---
    // task3_1_macros();
    // task3_2_fileio();

    // --- Part 4 ---
    // task4_1_linkedlist();

    // --- Part 5 ---
    // task5_1_dynamic_array();
    // task5_2_realloc_array();
    // task5_3_leak_detector();

    // --- Final Task ---
    // test_booth();

    return 0;
}
