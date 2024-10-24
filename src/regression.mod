param N;
set I := 1..N;

param x {i in I};
param y {i in I};

# Variables

var slope;
var intercept;

# Objective function
minimize sum_of_square_errors:
    sum{i in I} (y[i] - (x[i] * slope + intercept))^2;