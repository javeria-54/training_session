#!/bin/bash
echo "running_test"

# Test 1: countbit
echo "total test: 1:"
./bitops <<EOF
5
countbit
EOF

# Test 2: pow_2
echo "total test: 2:"
./bitops <<EOF
16
pow_2
EOF

# Test 3: reverse
echo "total test: 3:"
./bitops <<EOF
7
reverse
EOF

# Test 4: set
echo "total test: 4:"
./bitops <<EOF
8
set
3
EOF

# Test 5: clear
echo "total test: 5:"
./bitops <<EOF
15
clear
2
EOF

# Test 6: toggle
echo "total test: 6:"
./bitops <<EOF
10
toggle
1
EOF

echo "total tests run: 6"

