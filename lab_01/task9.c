#include <stdio.h>
#include <math.h>

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

int main() {
    task09_struct_distance();  
    return 0;
}
