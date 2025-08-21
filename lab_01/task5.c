#include <stdio.h>

void task05_reverse_string(char str[]) {
    int length = 0;
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
}

void task05_second_largest(int arr[], int size) {
    int second, largest, i;
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

int main() {

    char str[100];
    printf("Enter a string: ");
    scanf("%s", str); 
    task05_reverse_string(str);
    printf("Reversed string: %s\n", str);
    
    int size;
    printf("\nEnter size of array: ");
    scanf("%d", &size);

    int arr[size];
    printf("Enter %d elements:\n", size);
    for (int i = 0; i < size; i++) {
        scanf("%d", &arr[i]);
    }

    task05_second_largest(arr, size);

    return 0;
}
