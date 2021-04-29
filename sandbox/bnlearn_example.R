# If bnlearn and bnviewer packages are not installed. Install them using below lines
# install.packages(c("bnlearn", "bnviewer"))
library("bnlearn") #load bnlearn package
library("bnviewer") # load package to view bayesian networks

# set base project directory
base <- "~/Projects/cics490e_research"
setwd(base)

# variables for which we want to learn the structure
cols = c("action", "reward", "taxi_x_t", "taxi_y_t", "pass_x_t", "pass_y_t", "pass_in_taxi",
         "taxi_x_t1", "taxi_y_t1", "pass_x_t1", "pass_y_t1", "pass_in_taxi_t1")

# variables at time t+1
t2.variables = c("taxi_x_t1", "taxi_y_t1", "pass_x_t1", "pass_y_t1","pass_in_taxi_t1", "reward")

# variables ar time t
t1.variables = c("taxi_x_t", "taxi_y_t", "pass_x_t", "pass_y_t", "pass_in_taxi")


# sample dataset for which we want to learn the structure
data <- read.csv("sample_bayesian_network_data.csv")

# blacklist 1 which restricts arrows from t+1 to t variables (from future to past)
blacklist_1 = tiers2blacklist(list(t1.variables, t2.variables))

# blacklist 2 which restricts arrows from within  variables at time t(intra-step variables)
blacklist_2 = set2blacklist(t1.variables)

# blacklist 2 which restricts arrows from within  variables at time t + 1 (intra-step variables)
blacklist_3 = set2blacklist(t2.variables)

# exclude action from t variables.
var_excl_action = setdiff(t1.variables, c("action"))

# blacklist 4 which restricts arrow from action variable to variables at time t (excluding action)
blacklist_4 = expand.grid(from = "action", to = var_excl_action)

# exclude reward from t+1 variables.
var_excl_reward = setdiff(t2.variables, c("reward"))

# blaklist 5 which restricts arrows from reward variable to variables at time t+1 (excluding reward)
blacklist_5 = expand.grid(from = "reward", to = var_excl_reward)


# combine all blacklists into 1 list.
bl = rbind(blacklist_1, blacklist_2)
bl = rbind(bl, blacklist_3)
bl = rbind(bl, blacklist_4)
bl = rbind(bl, blacklist_5)


# NOTE: To add constraint about edges which should be in graph, use whitelists. 
# https://www.bnlearn.com/examples/whitelist/

# view blacklist which contains constraints about edges which should not be in the graph.
# cross-check id all constraints are included.
print(bl)

# only include columns in cols
df = data[cols]

# convert data type from numeric to factor (catgorical)
df[] <-lapply(df, as.factor)

# learn structure of the bayesian network with given prior knowledge in blacklist
net <- hc(df, blacklist = bl)

# fit parameters for the bayesian network
bn = bn.fit(net, df)

# view the bayesian network structure
viewer(net, bayesianNetwork.width = "100%",
       bayesianNetwork.height = "80vh",
       bayesianNetwork.layout = "layout_with_sugiyama",
       bayesianNetwork.title="Discrete Bayesian Network - Taxi",
       bayesianNetwork.subtitle = "Structural Relationships in Taxi Domain using random policy",
       bayesianNetwork.footer = "Fig. 1 - Structural Relationships in Taxi Domain")

