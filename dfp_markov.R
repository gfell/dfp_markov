## Given a panel of observations for a variable y, the program estimates
## a first-order Markov chain approximation to the stochastic data 
## generating process.
##
## The Markov chain has a (time/age)-indendependent number of states but
## both the values of the state space and the transition matrices are allowed
## to change with time/age.
## 
## The state vectors and transitions matrices are saved in the files y_space.csv
## and y_tranmatrices.csv in the working directory
##
## The following variables have to be set:
## 1. Age range: min_t, max_t
## 2. Working directory: e.g. "Path"
## 3. Dataset file name: e.g. sample.txt
## 4. The vector of time/age-invariant probability mass associated
##    with each state: bin.sizes
##
## Lines 67-69 can be changed to select whether the points of the state space
## are computed as the mean or median in each bin

# setwd("Path")

rm(list=ls())

###### INPUTS ######

# Load data
# Set age range
min_t <- 25 # Minimum age
max_t <- 60 # Maximum age


# Read data from file (first line) or generate an artificial dataset (following four lines)
# Columns have to be named as id (household identifier), age, y (variable to discretize) 
#eta <- as.data.table(read.table("sample.txt",sep=","))

N_id <- 10000 # Number of agents 
N <- (max_t-min_t+1)*N_id
set.seed(123)
eta <- as.data.table(cbind(id=rep(seq(1,N),each=max_t-min_t+1),age=rep(seq(min_t,max_t),N_id),y=rnorm(N)))

names(eta) <- c("id","age","y")

eta <- subset(eta,age>(min_t-1) & age<(max_t+1))


###### Computations ######

# Load some libraries
if (!require(data.table)) install.packages("data.table")
if (!require(statar)) install.packages("statar")

library(plyr)
library(data.table)

# Bin sizes (the length of this vector is the number of bins)
# They must add up to one
bin.sizes <- c(0.025,0.025,0.05,0.4,0.4,0.05,0.025,0.025)


# Add a zero to the binning vectors
# This is necessary to use .bincode and group earnings in bins
  
binning <- cumsum(c(0,bin.sizes))

# Create a variable bin that indicates, for each y observation
# the corresponding bin number. 
# fut_bin is the equivalent for next period's bin

eta[, bin:=.bincode(y,breaks=quantile(y,probs=binning),right=TRUE,include.lowest=TRUE),by=age]

# Export state space

# Kennan: construct state vectors using bin-specific medians
dfp_vector <- eta[,median(y),by=list(age,bin)]
# Adda-Cooper: construct state vectors using bin-specific means
#dfp_vector <- eta[,mean(y),by=list(age,bin)]

setkeyv(dfp_vector,c("age","bin"))
fname <- "y_space.csv"
write.csv(dfp_vector,file=fname,row.names=F)

# Next period bin
eta <- subset(eta,select=c("id","age","bin"))
setkeyv(eta, c("id","age"))
eta[, fut_bin:= shift(bin, type="lead")]
eta <- subset(eta,age<max(eta$age)) # no count for last age


# Export transition matrices.  These are counts of observations that
# move from a certain bin (at age) to a certain fut_bin (age+1),
# divided by the number of observations in (age)

# count how many observations move from a given bin to each fut_bin
totr <- eta[,list(ct=length(id)),keyby=c("age","bin","fut_bin")]

rm(eta)

# expand the grid so that the count is zero for the cases in which nobody moves
# from some bin to some fut_bin
dat2 <- with(totr,expand.grid(age=min(age):max(age),bin=1:max(bin),fut_bin=1:max(bin)))
totr <- merge(totr,dat2,all.y=TRUE)
totr$ct[is.na(totr$ct)] <- 0

# find total number of individuals in each bin (age,bin)
dat3 <- totr[,sum(ct),by=c("age","bin")]
totr <- merge(totr,dat3)

# divide to find probability of transitioning
totr$ct <- totr$ct/totr$V1
totr$V1 <- NULL

# export matrix
fname3 <- "y_tranmatrices.csv"
write.csv(totr,file=fname3,row.names=F)
