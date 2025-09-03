#include <stdio.h>
#include <stdint.h>
#include <string.h>

// Function to count number of set bits
int countBits(int32_t a) {
    int count = 0;
    while (a) {
        count += (a & 1);
        a >>= 1;
    }
    return count;
}

// Function to reverse bits
uint32_t reverseBits(uint32_t a) {
    uint32_t result = 0;
    for (int i = 0; i < 32; i++) {
        result <<= 1;
        result |= (a & 1);
        a >>= 1;
    }
    return result;
}

// Function to check if power of 2
int isPowerOf2(int32_t a) {
    return (a > 0) && ((a & (a - 1)) == 0);
}

// Function to set a bit
uint32_t setBit(uint32_t a, int pos) {
    return (a | (1U << pos));
}

// Function to clear a bit
uint32_t clearBit(uint32_t a, int pos) {
    return (a & ~(1U << pos));
}

// Function to toggle a bit
uint32_t toggleBit(uint32_t a, int pos) {
    return (a ^ (1U << pos));
}

void bitops() {
    int32_t a;
    char op[20];
    int pos;

    printf("Enter an integer:\n ");
    scanf("%d", &a);

    printf("Enter the operation:\n ");
    scanf("%19s", op);

   if (strcmp(op, "countbit") == 0) {
        printf("Number of set bits: %d\n", countBits(a));
    }
    else if (strcmp(op, "reverse") == 0) {
        printf("Reversed bits: %u\n", reverseBits(a));
    }
    else if (strcmp(op, "pow_2") == 0) {
        if (isPowerOf2(a)) 
            printf("%d is a power of 2.\n", a);
        else 
            printf("%d is not a power of 2.\n", a);
    }
    else if (strcmp(op, "set") == 0) {
        printf("Enter bit position (0-31): \n");
        scanf("%d", &pos);
        printf("After setting bit %d: %u\n", pos, setBit(a, pos));
    }
    else if (strcmp(op, "clear") == 0) {
        printf("Enter bit position (0-31): \n");
        scanf("%d", &pos);
        printf("After clearing bit %d: %u\n", pos, clearBit(a, pos));
    }
    else if (strcmp(op, "toggle") == 0) {
        printf("Enter bit position (0-31): \n");
        scanf("%d", &pos);
        printf("After toggling bit %d: %u\n", pos, toggleBit(a, pos));
    }
    else {
        printf("Invalid operator!\n");
    }
}
int main() {
    bitops();
    return 0;
}
