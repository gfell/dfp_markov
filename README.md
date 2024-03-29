#  Non-stationary, non-parametric Markov-chain Approximation in **R**

Given a panel of observations for a variable y, the program estimates
a first-order Markov chain approximation to the stochastic data
generating process, as described in the paper "Nonlinear Household
Earnings Dynamics, Self-Insurance, and Welfare" by Mariacristina De
Nardi, Giulio Fella and Gonzalo Paz-Pardo, Journal of the European
Economic Association, ([https://doi.org/10.1093/jeea/jvz010.to](https://doi.org/10.1093/jeea/jvz010.to))

The estimated Markov chain has a (time/age)-independent **number** of
states but both the points of the state space and the transition
matrices are allowed to change with time/age.

The points of the state space are obtained by discretizing the
marginal distribution at each age/time into a finite number of bins
and assigning to each bin the average or median of observations
falling into it. The transitions matrices are obtained as the fraction
of observations in each bin at age/time *t* transiting to each bin at
age/time *t+1*.  

The method does not hinge on a parametric specification of the data
generating process or require the process to be stationary, though it
requires a finite horizon. The dataset should have a large
cross-sectional (> 1 million) dimension to keep sampling error under
control.

 

