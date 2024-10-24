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

set J2 := 1..(S+1);
var splitters {J2} integer;
subject to sorted_splitters {j in J}:
	splitters[j] <= splitters[j+1] - 1; # avoid strict inequality warning
 
subject to pinned_start:
	splitters[1] = 1;
	
subject to pinned_end:
	splitters[S+1] = N;
	
subject to membership_between_splitters {i in I, j in J}:
	(membership[i, j] = 0) or
	(membership[i, j] = 1 and splitters[j] <= i and i <= splitters[j+1]);


# without this, membership stays zero


subject to at_least_one_segment_per_point {i in I}:
	sum{j in J} membership[i, j] >= 1;
	

subject to not_more_than_two_segments_per_point {i in I}:
	sum{j in J} membership[i, j] <= 2;
	
	
# What I want is to constrain sum(membership[i, :]) = 2 iff i is a splitter.
# I really don't like this, but this is what makes sure segments overlap/"meet" at a point
# it works only because the error from these points is zero, and we're doing decimation not regression
# It may be possible to get >2 in a row... jk we can constraint that too lol
subject to total_sum {I, J}:
	sum{i in I, j in J} membership[i, j] = N + S - 1;



# calculate segment line equations
var x1 {j in J};
var x2 {j in J};
var y1 {j in J};
var y2 {j in J};

	
subject to specify_x1 {j in J}:
	x1[j] = sum{i in I} if i == splitters[j] then x[i] else 0;
subject to specify_x2 {j in J}:
	x2[j] = sum{i in I} if i == splitters[j+1] then x[i] else 0;
subject to specify_y1 {j in J}:
	y1[j] = sum{i in I} if i == splitters[j] then y[i] else 0;
subject to specify_y2 {j in J}:
	y2[j] = sum{i in I} if i == splitters[j+1] then y[i] else 0;

subject to specify_slope {j in J}:
	slope[j] = (y2[j] - y1[j]) / (x2[j] - x1[j]);
	
subject to specify_intercept {j in J}:
	intercept[j] = y2[j] - slope[j] * x2[j];

minimize sum_of_square_errors:
    sum{i in I, j in J} (y[i] - (x[i] * slope[j] + intercept[j])) ^ 2 * membership[i, j];