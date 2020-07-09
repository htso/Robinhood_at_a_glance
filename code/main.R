# robintrack.R -- read and analyse robintrack popularity CSV files.
# Horace W. Tso (c)
# Jun 20, 2020

library(quantmod)
library(gridExtra)

setwd("../")
home = getwd()
home1 = "/mnt/WanChai/Dropbox/AlgoTrading/Robinhood"
utils = paste(home, "/utils", sep="")
plot_dir = paste(home, "/plots", sep="")
dat_cur = paste(home, "/popularity_export", sep="")
dat_cur1 = "/mnt/WanChai/Dropbox/AlgoTrading/Robinhood/popularity_export"
dat_lastwk = "/mnt/WanChai/Dropbox/AlgoTrading/Robinhood/popularity_export_LASTWK"

# Get last wk's data for comparison
load(paste(home1, "/Robintrack_Jun27.RData", sep=""))
ll.old = ll
rm(data_env)

# NOTE : call fun.R *after* reading in the old data, never before !
source(paste(utils, "/Fun.R", sep=""))


# Get all CSV file names
nm = list.files(path=dat_cur1, all.files=FALSE, include.dirs=FALSE)
nm = nm[3:length(nm)]
(N = length(nm))
# 8508
# Build vector of ticker symbols 
tkr = sapply(strsplit(x=nm, split="\\."), parse_ticker)
# Check for issues
sum(is.na(tkr)) # expect 0
# Read CSV files, convert them to xts objects, save them to the data_env environment
setwd(dat_cur1)
data_env = new.env()
Len = sapply(nm, read_convert_save2env, data_env=data_env)
# Check : # tickers match # of time series
length(ls(envir=data_env)) == length(nm) # expect TRUE




setwd(home)
# Aggregate the hourly data to daily and weekly and put them in a list
ll = sweep_env(data_env, day_wk_aggregator)
# Check + statistics on each ticker dataset
cnt = table(sapply(ll, function(.s) nrow(.s[["y_daily"]])))
sum(cnt[which(as.integer(names(cnt)) > 365)]) / length(tkr)
# [1] 0.8450455
# ==> 84% of the tickers have more than 1 yr of data
table(sapply(ll, function(.s) nrow(.s[["dy_daily"]])))
cnt = table(sapply(ll, function(.s) nrow(.s[["y_wk"]])))
sum(cnt[which(as.integer(names(cnt)) > 52)]) / length(tkr)
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
# 7. Biggest increase since last week
# TO-DO : Which tickers have seen user holding falling to zero from at least 10k in Feb ?
# TO-DO : Which tickers have seen holding steadily rising ?
# ...
# ...


# 2. Top holdings
df = as.data.frame(t(sapply(ll, latest_stat, "2020-03-20")))
df[,"tkr"] = as.character(df[,"tkr"])
df[,"base_holding"] = as.numeric(df[,"base_holding"])
df[,"cur_holding"] = as.numeric(df[,"cur_holding"])
df[,"pct_change"] = 100*(df[,"cur_holding"] / df[,"base_holding"] - 1)
df = df[order(df[,"cur_holding"], decreasing = TRUE),]
top_nm = head(df, 10)[,"tkr"]
tmp = head(df, 10)
colnames(tmp) = c("Ticker", "Mar 20th", "This Week", "% Change")
tmp[,2] = format(tmp[,2], big.mark=",", digits=0, scientific=FALSE)
tmp[,3] = format(tmp[,3], big.mark=",", digits=0, scientific=FALSE)
tmp[,4] = format(tmp[,4], big.mark=",", digits=2, scientific=FALSE)
png("Top10_table.png", width=300, height=300, bg="white")
grid.table(tmp, rows=NULL)
dev.off()
  


# 3. stocks with more than 100k accounts
df[which(df[,"cur_holding"] > 100000), "tkr"]
[1] "F"    "GE"   "AAL"  "DIS"  "DAL"  "MSFT" "CCL"  "GPRO" "AAPL" "ACB"  "PLUG" "NCLH" "BAC"  "BA"   "UAL"  "FIT" 
[17] "SNAP" "TSLA" "AMZN" "HEXO" "CGC"  "INO"  "RCL"  "UBER" "FB"   "TWTR" "AMD"  "SAVE" "CRON" "BABA" "GRPN" "ZNGA"
[33] "MRNA" "KO"   "SBUX" "LUV"  "T"    "MRO"  "MGM"  "TOPS" "APHA" "JBLU" "GNUS" "OGI"  "MFA"  "NIO"  "XOM"  "USO" 
[49] "UCO"  "HTZ"  "NFLX" "NKLA" "IVR"  "SPCE" "GM"   "AMC"  "LK"   "NOK"  "NVDA" "VOO"  "CTST" "NRZ"  "IDEX" "CPE" 
[65] "DKNG" "WKHS" "PLAY" "PENN" "CPRX" "TLRY" "SPY"  "SIRI" "OAS"  "NKE"  "WORK"


# 4. largest percentage increase since Mar 20
df1 = head(df, 100)
df1 = df1[order(df1[,"pct_change"], decreasing=TRUE),]
incr_nm = head(df1, 10)[,"tkr"]
head(df1, 10)
# for github display
tmp = head(df1, 10)
colnames(tmp) = c("Ticker", "Mar 20th", "This Week", "% Change")
tmp[,2] = format(tmp[,2], big.mark=",", digits=0, scientific=FALSE)
tmp[,3] = format(tmp[,3], big.mark=",", digits=0, scientific=FALSE)
tmp[,4] = format(tmp[,4], big.mark=",", digits=2, scientific=FALSE)
png("LargestIncr.png", width=480, height = 480, bg="white")
grid.table(tmp, rows=NULL)
dev.off()


# 4.1 largest percentage decrease since Mar 20
df2 = df[which(df[,"pct_change"] < 0 & df[,"base_holding"] > 10000),]
dim(df2)
df2 = df2[order(df2[,"pct_change"], decreasing =FALSE),]
decr_nm = head(df2, 10)[,"tkr"]
# for github display
tmp = head(df2, 10)

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
# TO-DO

# 7. biggest change since last week
df.old = as.data.frame(t(sapply(ll.old, latest_stat, "2020-03-20")))
df.old[,"tkr"] = as.character(df.old[,"tkr"])
df.old[,"base_holding"] = as.numeric(df.old[,"base_holding"])
df.old[,"cur_holding"] = as.numeric(df.old[,"cur_holding"])
df.old = df.old[order(df.old[,"cur_holding"], decreasing = TRUE),]
df.comb = merge(df[,1:3], df.old[,1:3], by="tkr", all.x=FALSE, all.y=TRUE, suffixes=c(".cur", ".lastwk"))
df.comb[,"delta"] = df.comb[,"cur_holding.cur"] - df.comb[,"cur_holding.lastwk"]
df.comb[,"delta.pct"] = ifelse( df.comb[,"cur_holding.lastwk"] > 0, 100*df.comb[,"delta"] / df.comb[,"cur_holding.lastwk"], NA)
tmp = df.comb[which(df.comb[,"cur_holding.lastwk"] > 100000),]
tmp = tmp[order(tmp[,"delta.pct"], decreasing=TRUE),]
tmp = tmp[,c("tkr", "cur_holding.cur", "cur_holding.lastwk", "delta", "delta.pct")]

incr = head(tmp, 10)
decr = tail(tmp, 10)

colnames(incr) = c("Ticker", "Current", "Last Week", "Net Change", "% Change")
incr[,2] = format(incr[,2], big.mark=",", digits=0, scientific=FALSE)
incr[,3] = format(incr[,3], big.mark=",", digits=0, scientific=FALSE)
incr[,4] = format(incr[,4], big.mark=",", digits=0, scientific=FALSE)
incr[,5] = format(incr[,5], big.mark=",", digits=3, scientific=FALSE)

colnames(decr) = c("Ticker", "Current", "Last Week", "Net Change", "% Change")
decr[,2] = format(decr[,2], big.mark=",", digits=0, scientific=FALSE)
decr[,3] = format(decr[,3], big.mark=",", digits=0, scientific=FALSE)
decr[,4] = format(decr[,4], big.mark=",", digits=0, scientific=FALSE)
decr[,5] = format(decr[,5], big.mark=",", digits=3, scientific=FALSE)

png("Incr_since_lastwk.png", width=400, height=300, bg="white")
grid.table(incr, rows=NULL)
dev.off()

png("Decr_since_lastwk.png", width=400, height=300, bg="white")
grid.table(decr, rows=NULL)
dev.off()






# Get YF stock prices
sapply(top_nm, function(.k) getSymbols(.k, env=globalenv(), src="yahoo", from="1800-01-01"))
sapply(incr_nm, function(.k) getSymbols(.k, env=globalenv(), src="yahoo", from="1800-01-01"))
sapply(decr_nm, function(.k) getSymbols(.k, env=globalenv(), src="yahoo", from="1800-01-01"))


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

