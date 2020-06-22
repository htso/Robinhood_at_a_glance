# robintrack.R -- read and analyse robintrack popularity CSV files.
# Horace W. Tso (c)
# Jun 20, 2020

library(quantmod)
library(xtable)

home = "/mnt/WanChai/Dropbox/GITHUB_REPO/Robinhood_at_a_glance"
utils = "/mnt/WanChai/Dropbox/GITHUB_REPO/Robinhood_at_a_glance/utils"
plot_dir = "/mnt/WanChai/Dropbox/GITHUB_REPO/Robinhood_at_a_glance/plots"
dat_dir = "/mnt/WanChai/Dropbox/GITHUB_REPO/Robinhood_at_a_glance/robintrack_popularity_export"
dat_dir = "/mnt/WanChai/Dropbox/AlgoTrading/Robinhood/robintrack_popularity_export"
setwd(home)

source(paste(utils, "/Fun.R", sep=""))

# Get all CSV file names
nm = list.files(path=dat_dir, all.files=FALSE, include.dirs=FALSE)
nm = nm[3:length(nm)]
(N = length(nm))
# Build vector of ticker symbols 
tkr = sapply(strsplit(x=nm, split="\\."), parse_ticker)
# Check for issues
sum(is.na(tkr)) # expect 0
# Read CSV files, convert them to xts objects, save them to the data_env environment
setwd(dat_dir)
data_env = new.env()
res = sapply(nm, read_convert_save2env, data_env=data_env)
# Check : # tickers match # of time series
length(ls(envir=data_env)) == length(nm) # expect TRUE
# Check : time series lengths
X11();hist(res)
# Data issue : some time series are much longer than others. Duplicate entries. 
which(res > 18000)
# Need to talk to the robintrack guy.

setwd(home)
# Aggregate the hourly data to daily and weekly and put them in a list
ll = sweep_env(data_env, day_wk_aggregator)
# Check + statistics on each ticker dataset
cnt = table(sapply(ll, function(.s) nrow(.s[["y_daily"]])))
sum(cnt[which(as.integer(names(cnt)) > 365)]) / len(tkr)
# [1] 0.8450455
# ==> 84% of the tickers have more than 1 yr of data
table(sapply(ll, function(.s) nrow(.s[["dy_daily"]])))
cnt = table(sapply(ll, function(.s) nrow(.s[["y_wk"]])))
sum(cnt[which(as.integer(names(cnt)) > 52)]) / len(tkr)
# [1] 0.8488
# ==> 84% of the tickers have more than 52 wks of data
table(sapply(ll, function(.s) nrow(.s[["dy_wk"]])))

# ==== Basic statistics about the robintrack dataset =========================================
# 1. How many have more than 1 yr of data ?
# Ans : 84.8%
# 2. Top 10 holdings : 
# 3. Stocks with more than 100k accounts? show list 
# 4. Stocks with holding increased or decreased since Mar 20 ? and by how much in %, show top 5, plots
# 5. Stocks with holding increased or decreased since Jun 1 ? and by how much in %, show top 5, plots
# 6. Greatest variability in past three months, show top 5, plots

# 2. Top holdings
df = as.data.frame(t(sapply(ll, latest_stat, "2020-03-20")))
df[,"tkr"] = as.character(df[,"tkr"])
df[,"base_holding"] = as.numeric(df[,"base_holding"])
df[,"cur_holding"] = as.numeric(df[,"cur_holding"])
df[,"pct_change"] = 100*(df[,"cur_holding"] / df[,"base_holding"] - 1)
df = df[order(df[,"cur_holding"], decreasing = TRUE),]
top_nm = head(df, 10)[,"tkr"]

# 3. stocks with more than 100k accounts
df[which(df[,"cur_holding"] > 100000), "tkr"]

# 4. largest percentage increase since Mar 20
df1 = head(df, 100)
df1 = df1[order(df1[,"pct_change"], decreasing=TRUE),]
incr_nm = head(df1, 10)[,"tkr"]

# 4.1 largest percentage decrease since Mar 20
df2 = df[which(df[,"pct_change"] < 0 & df[,"base_holding"] > 10000),]
dim(df2)
df2 = df2[order(df2[,"pct_change"], decreasing =FALSE),]
decr_nm = head(df2, 10)[,"tkr"]

# 5. largest percentage increase since Jun 1
df3 = as.data.frame(t(sapply(ll, latest_stat, "2020-06-01")))
df3[,"tkr"] = as.character(df3[,"tkr"])
df3[,"base_holding"] = as.numeric(df3[,"base_holding"])
df3[,"cur_holding"] = as.numeric(df3[,"cur_holding"])
df3[,"pct_change"] = 100*(df3[,"cur_holding"] / df3[,"base_holding"] - 1)
df3 = df3[order(df3[,"cur_holding"], decreasing = TRUE),]
df4 = head(df3, 100)
df4 = df4[order(df4[,"pct_change"], decreasing=TRUE),]
incr_nm = head(df4, 10)[,"tkr"]


# 6. variability over time






# Get YF stock prices
for (s in top_nm) getSymbols(s, env=globalenv(), src="yahoo", from="1800-01-01")
for (s in incr_nm) getSymbols(s, env=globalenv(), src="yahoo", from="1800-01-01")
for (s in decr_nm) getSymbols(s, env=globalenv(), src="yahoo", from="1800-01-01")

# Time Series Plots (one yr)
setwd(plot_dir)
png("Top_10.png", width = 1080, height=640)
par(mfrow=c(3,4), mar=c(2,2,2,2))
for ( s in top_nm ) {
  ix = which(tkr == s)
  y = ll[[ix]]$y_daily["2019-06::"]
  df3 = data.frame(date=as.Date(index(y)), y=as.numeric(y))
  y1 = get(s)["2019-06::", 6]
  df4 = data.frame(date=index(y1), y1=as.numeric(y1))
  df5 = merge(x=df3, y=df4, by="date", all.x=FALSE, all.y=TRUE)
  tick.loc = as.integer(seq.int(from=1, to=nrow(df5), length.out=10))
  plot(y~date, data=df5, xlab="", ylab="", xaxt="n", type="l", lwd=5, col="red", main=s)
  par(new=TRUE)
  plot(y1~date, data=df5, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=1, col="blue" )
  axis(1, at=df5[tick.loc,"date"], labels=format(df5[tick.loc,"date"], "%b-%d"), cex.axis=0.6)
}
dev.off()

png("Largest_incr.png", width = 1080, height=640)
par(mfrow=c(3,4), mar=c(2,2,2,2))
for ( s in incr_nm ) {
  ix = which(tkr == s)
  y = ll[[ix]]$y_daily["2019-06::"]
  df3 = data.frame(date=as.Date(index(y)), y=as.numeric(y))
  y1 = get(s)["2019-06::", 6]
  df4 = data.frame(date=index(y1), y1=as.numeric(y1))
  df5 = merge(x=df3, y=df4, by="date", all.x=FALSE, all.y=TRUE)
  tick.loc = as.integer(seq.int(from=1, to=nrow(df5), length.out=10))
  plot(y~date, data=df5, xlab="", ylab="", xaxt="n", type="l", lwd=5, col="red", main=s)
  par(new=TRUE)
  plot(y1~date, data=df5, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=1, col="blue" )
  axis(1, at=df5[tick.loc,"date"], labels=format(df5[tick.loc,"date"], "%b-%d"), cex.axis=0.6)
}
dev.off()

png("Largest_decr.png", width = 1080, height=640)
par(mfrow=c(3,4), mar=c(2,2,2,2))
for ( s in decr_nm ) {
  ix = which(tkr == s)
  y = ll[[ix]]$y_daily["2019-06::"]
  df3 = data.frame(date=as.Date(index(y)), y=as.numeric(y))
  y1 = get(s)["2019-06::", 6]
  df4 = data.frame(date=index(y1), y1=as.numeric(y1))
  df5 = merge(x=df3, y=df4, by="date", all.x=FALSE, all.y=TRUE)
  tick.loc = as.integer(seq.int(from=1, to=nrow(df5), length.out=10))
  plot(y~date, data=df5, xlab="", ylab="", xaxt="n", type="l", lwd=5, col="red", main=s)
  par(new=TRUE)
  plot(y1~date, data=df5, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=1, col="blue" )
  axis(1, at=df5[tick.loc,"date"], labels=format(df5[tick.loc,"date"], "%b-%d"), cex.axis=0.6)
}
dev.off()

setwd(home)
save.image("Robintrack.RData")

