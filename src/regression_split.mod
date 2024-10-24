# XY input
param N;
set I := 1..N;
param x {i in I};
param y {i in I};



# Variables: point-segment membership and segment line slope/intercept 
param S;
set J := 1..S;
var slope {j in J};
var intercept {j in J};

var membership {I, J} binary;


# constraints
subject to one_segment_per_point {i in I}:
	sum{j in J} membership[i, j] = 1;
	
subject to min_segment_size {j in J}:
	sum{i in I} membership[i, j] >= 2;
	
## enforce segments as contiguous points over the loop of I (N -> 1 is valid)
subject to contiguity {i in I, j in J}: 
	(membership[i, j] = 1 and membership[i mod N + 1, j] = 1 and membership[i mod N + 1, j mod S + 1] = 0) or
	(membership[i, j] = 1 and membership[i mod N + 1, j] = 0 and membership[i mod N + 1, j mod S + 1] = 1) or 
	(membership[i, j] = 0);
	
subject to non_looping {j in J}:
	membership[1, j] * membership[N, j] = 0; 

subject to reduce_symmetry: # reduces SCIP branching nodes by factor of S
	membership[1, 1] = 1;
	
minimize sum_of_square_errors:
    sum{i in I, j in J} (y[i] - (x[i] * slope[j] + intercept[j]))^2 * membership[i, j];