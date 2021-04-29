# # Install packages
# install.packages("bnlearn")
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install()
# BiocManager::install(c("graph", "Rgraphviz"))

# Load packages
library("bnlearn")
library("bnviewer")
library("Rgraphviz")
library('ggplot2')

setwd('~/Projects/cics490e_research')
setwd('E:/Projects/cics490e_research')

# Compute f1 score given tp, fp, fn
f1 <- function(m) {
  tp <- m$tp
  fp <- m$fp
  fn <- m$fn

  return(tp / (tp + (fp + fn) / 2))
}

# Load Dataset
data('alarm')
head(alarm)

# Ground truth network
modelstring <- paste0("[HIST|LVF][CVP|LVV][PCWP|LVV][HYP][LVV|HYP:LVF][LVF]",
                      "[STKV|HYP:LVF][ERLO][HRBP|ERLO:HR][HREK|ERCA:HR][ERCA][HRSA|ERCA:HR][ANES]",
                      "[APL][TPR|APL][ECO2|ACO2:VLNG][KINK][MINV|INT:VLNG][FIO2][PVS|FIO2:VALV]",
                      "[SAO2|PVS:SHNT][PAP|PMB][PMB][SHNT|INT:PMB][INT][PRSS|INT:KINK:VTUB][DISC]",
                      "[MVS][VMCH|MVS][VTUB|DISC:VMCH][VLNG|INT:KINK:VTUB][VALV|INT:VLNG]",
                      "[ACO2|VALV][CCHL|ACO2:ANES:SAO2:TPR][HR|CCHL][CO|HR:STKV][BP|CO:TPR]")
dag_true <- model2network(modelstring)
graphviz.plot(dag_true)

# Given 1 incorrect edge to blacklist
n <- dim(dag_true$arcs)[1]
arcs <- dag_true$arcs
df_b1 <- data.frame(edge=character(), f1=numeric())

for (i in 1:n) {
  e <- arcs[i,]
  net <- hc(alarm, blacklist = e)

  df_b1[i,] <- c(paste(e, collapse = ' -> '), f1(compare(dag_true, net)))
}
df_b1$f1 = as.numeric(df_b1$f1)

gt_f1 = f1(compare(dag_true, hc(alarm)))

# Make the plot
ggplot(df_b1, aes(x=edge, y=f1, group=1)) +
  scale_x_discrete(limits=df_b1$edge) +
  scale_y_continuous(breaks = sort(c(seq(min(df_b1$f1), max(df_b1$f1), length.out=5), gt_f1))) +
  geom_point() +
  geom_hline(aes(yintercept=gt_f1, color='red')) +
  geom_text(aes(5,gt_f1,label = 'Without given prior knowedge', vjust = -0.5, color='red')) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title = "F1 score given 1 incorrect blacklist edge",
       x='Edge added to the blacklist', y='F1 Score') +
  theme(legend.position = "none")

# Given n random incorrect edge to blacklist
df_bn <- data.frame(f1=numeric())

for (i in 1:n) {
  e <- arcs[sample(1:n, i),]
  net <- hc(alarm, blacklist = e)

  df_bn[i,] <- f1(compare(dag_true, net))
}

# Make the plot
ggplot(df_bn, aes(x=(1:n), y=f1)) +
  #scale_x_discrete(limits=df_bn$edge) +
  scale_y_continuous(breaks = sort(c(seq(min(df_bn$f1), max(df_bn$f1), length.out=5), gt_f1))) +
  geom_point() +
  geom_hline(aes(yintercept=gt_f1, color='red')) +
  geom_text(aes(5,gt_f1,label = 'Without given prior knowedge', vjust = -0.5, color='red')) +
  labs(title = "F1 score given n random incorrect blacklist edge",
       x='Number of edges added to the blacklist', y='F1 Score') +
  theme(legend.position = "none")








net_true <- bn.fit(dag_true, alarm)


net <- hc(alarm)

bn <- bn.fit(net, alarm)
