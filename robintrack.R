# robintrack.R -- read robintrack popularity CSV files.
# Horace W. Tso (c)
# Jun 20, 2020

library(quantmod)
library(xtable)


home = "/mnt/WanChai/Dropbox/GITHUB_REPO/Robinhood_at_a_glance"
utils = "/mnt/WanChai/Dropbox/GITHUB_REPO/Robinhood_at_a_glance/utils"
plot_dir = "/mnt/WanChai/Dropbox/GITHUB_REPO/Robinhood_at_a_glance/plots"
dat_dir = "/mnt/WanChai/Dropbox/AlgoTrading/Robinhood/robintrack_popularity_export"
setwd(home)

source(paste(utils, "/Fun.R", sep=""))

nm = list.files(path=dat_dir, all.files=FALSE, include.dirs=FALSE)
nm = nm[3:length(nm)]
(N = length(nm))

tkr = sapply(strsplit(x=nm, split="\\."), parse_ticker)
# Check
sum(is.na(tkr)) # expect 0

setwd(dat_dir)
data_env = new.env()
res = sapply(nm, read_convert_save2env, data_env=data_env)
# Check
len(ls(envir=data_env)) == len(nm) # expect TRUE
setwd(home)


ll = sweep_env(data_env, day_wk_aggregator)
# Check + statistics on each ticker dataset
cnt = table(sapply(ll, function(.s) nrow(.s[["y_daily"]])))
sum(cnt[which(as.integer(names(cnt)) > 365)]) / len(tkr)
# [1] 0.8450455
# 84% of the tickers have more than 1 yr of data
table(sapply(ll, function(.s) nrow(.s[["dy_daily"]])))
cnt = table(sapply(ll, function(.s) nrow(.s[["y_wk"]])))
sum(cnt[which(as.integer(names(cnt)) > 52)]) / len(tkr)
# [1] 0.8488
# 84% of the tickers have more than 52 wks of data
table(sapply(ll, function(.s) nrow(.s[["dy_wk"]])))

# ==== Basic statistics about the robintrack dataset =========================================
# 1. How many have more than 1 yr of data ?
# Ans : 84.8%
# 2. Top 10 holdings : 
# 3. Stocks with more than 100k accounts? show list 
# 4. Stocks with holding increased or decreased since Mar 20 ? and by how much in %, show top 5, plots
# 5. Stocks with holding increased or decreased since Jun 1 ? and by how much in %, show top 5, plots
# 6. Greatest variability in past three months, show top 5, plots
# 7. 
# 

# 2. Top holdings
df = as.data.frame(t(sapply(ll, latest_stat)))
df[,"tkr"] = as.character(df[,"tkr"])
df[,"base_holding"] = as.numeric(df[,"base_holding"])
df[,"cur_holding"] = as.numeric(df[,"cur_holding"])
df = df[order(df[,"cur_holding"], decreasing = TRUE),]
top_nm = head(df, 10)[,"tkr"]

# 3. stocks with more than 100k accounts
df[which(df[,"cur_holding"] > 100000), "tkr"]

# 4. largest percentage increase since Mar 20
df[,"pct_change"] = 100*(df[,"cur_holding"] / df[,"base_holding"] - 1)
df1 = head(df, 100)
df1 = df1[order(df1[,"pct_change"], decreasing=TRUE),]
head(df1, 10)

# 4.1 largest percentage decrease since Mar 20
df2 = df[which(df[,"pct_change"] < 0 & df[,"base_holding"] > 10000),]
dim(df2)
df2 = df2[order(df2[,"pct_change"], decreasing =FALSE),]
head(df2, 10)

# 6. variability over time


# Time Series Plots (one yr)
setwd(plot_dir)
png("Top_10.png", width = 1080, height=480)
par(mfrow=c(2,5), mar=c(2,2,2,2))
for ( s in top_nm ) {
  y = get(s, envir=data_env)["2019-06::"]
  tick.loc = as.integer(seq.int(from=1, to=nrow(y), length.out=10))
  df3 = data.frame(date=index(y), y=as.numeric(y))
  ix = which(as.Date(df3[,"date"]) == as.Date("2020-03-20") )
  plot(y~date, data=df3, xlab="", ylab="", xaxt="n", type="l", main=s)
  abline(v=ix)
  axis(1, at=df3[tick.loc,"date"], labels=format(df3[tick.loc,"date"], "%b-%d"), cex.axis=0.6)
}
dev.off()

save.image("Robintrack.RData")


