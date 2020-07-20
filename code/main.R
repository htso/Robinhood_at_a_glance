# robintrack.R -- read and analyse robintrack popularity CSV files.
# Horace W. Tso (c)
# Jun 20, 2020

library(quantmod)
library(gridExtra)
library(tidyverse)

datetm = Sys.time()
today = as.Date(datetm)

private_dir = "/mnt/WanChai/Dropbox/AlgoTrading/Robinhood"
dat_private = "/mnt/ClearWaterBay/popularity_export"
dat_lastwk = "/mnt/ClearWaterBay/popularity_export_LASTWK"
# Get last wk's data for comparison
#load(paste(private_dir, "/Robintrack_Jul5.RData", sep=""))
#ll.old = ll
rm(data_env, df, df1, df2, df.comb, N, top_nm, tkr, tmp)

setwd("../")
home = getwd()
utils = paste(home, "/utils", sep="")
plot_dir = paste(home, "/plots", sep="")
dat_cur = paste(home, "/popularity_export", sep="")

# NOTE : call fun.R *after* reading in the old data, never before !
source(paste(utils, "/Fun.R", sep=""))

# Get all CSV file names
nm = list.files(path=dat_private, all.files=FALSE, include.dirs=FALSE)
nm = nm[3:length(nm)] # bug
(N = length(nm))
# 4310
# Build vector of ticker symbols 
tkr = sapply(strsplit(x=nm, split="\\."), parse_ticker)
# Check for issues
sum(is.na(tkr)) # expect 0
# Read CSV files, convert them to xts objects, save them to the data_env environment
setwd(dat_private)
data_env = new.env()
Len = sapply(nm, read_convert_save2env, data_env=data_env) # ...takes few minutes
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
# 8. Estimate RH's total account position time series
# ...


# 2. Top holdings
base.ch = "2020-03-20"
today.ch = as.character(today-2)
df = compare_time_pts(ll, base.ch, today.ch) 
df = df[order(df[,"laterT"], decreasing = TRUE),]
top_nm = head(df, 10)[,"tkr"]

tmp = head(df, 10)
colnames(tmp) = c("Ticker", "Mar 20th", "Today", "% Change")
tmp[,2] = format(tmp[,2], big.mark=",", digits=0, scientific=FALSE)
tmp[,3] = format(tmp[,3], big.mark=",", digits=0, scientific=FALSE)
tmp[,4] = format(tmp[,4], big.mark=",", digits=2, scientific=FALSE)
png("Top10_table.png", width=300, height=300, bg="white")
grid.table(tmp, rows=NULL)
dev.off()
  
# 3. stocks with more than 100k accounts
df[which(df[,"laterT"] > 100000), "tkr"]
"F"    "GE"   "AAL"  "DIS"  "DAL"  "AAPL" "MSFT" "CCL"  "GPRO" "TSLA" "ACB" 
"PLUG" "AMZN" "NCLH" "BAC"  "SNAP" "FIT"  "BA"   "UAL"  "MRNA" "NIO"  "HEXO"
"UBER" "BABA" "CGC"  "FB"   "RCL"  "TWTR" "AMD"  "CRON" "INO"  "ZNGA" "NFLX"
"SAVE" "KO"   "T"    "TOPS" "SBUX" "APHA" "LUV"  "MRO"  "JBLU" "MGM"  "GNUS"
"OGI"  "XOM"  "MFA"  "USO"  "SPCE" "UCO"  "HTZ"  "IVR"  "NVDA" "AMC"  "GM"  
"WKHS" "NOK"  "VOO"  "PFE"  "NRZ"  "SQ"   "PLAY" "CPRX" "SPY"  "CPE"  "WORK"
"SIRI" "TLRY" "PENN" "NKE"  "VSLR"


"F"    "GE"   "AAL"  "DIS"  "DAL"  "AAPL" "MSFT" "CCL"  "GPRO" "ACB"  "TSLA" "PLUG" "NCLH" "AMZN" "BAC" 
"SNAP" "BA"   "FIT"  "UAL"  "NIO"  "UBER" "HEXO" "CGC"  "BABA" "RCL"  "FB"   "TWTR" "INO"  "AMD"  "CRON"
"SAVE" "ZNGA" "KO"   "MRNA" "T"    "TOPS" "SBUX" "LUV"  "APHA" "MRO"  "GNUS" "JBLU" "MGM"  "OGI"  "NFLX"
"MFA"  "XOM"  "USO"  "UCO"  "HTZ"  "IVR"  "SPCE" "AMC"  "NVDA" "GM"   "WKHS" "NOK"  "VOO"  "NRZ"  "CPE" 
"PLAY" "PFE"  "PENN" "CPRX" "SQ"   "SPY"  "TLRY" "SIRI" "NKE"  "WORK" "IDEX" "VSLR"


# 4. largest percentage increase since Mar 20
df1 = head(df, 100)
df1 = df1[order(df1[,"pct_change"], decreasing=TRUE),]
incr_nm = head(df1, 10)[,"tkr"]
head(df1, 10)
# for github display
tmp = head(df1, 10)
colnames(tmp) = c("Ticker", "Mar 20th", "Today", "% Change")
tmp[,2] = format(tmp[,2], big.mark=",", digits=0, scientific=FALSE)
tmp[,3] = format(tmp[,3], big.mark=",", digits=0, scientific=FALSE)
tmp[,4] = format(tmp[,4], big.mark=",", digits=2, scientific=FALSE)
png("LargestIncr_since_Mar20.png", width=480, height = 480, bg="white")
grid.table(tmp, rows=NULL)
dev.off()

# 4.1 largest percentage decrease since Mar 20
df2 = df[which(df[,"pct_change"] < 0 & df[,"laterT"] > 10000),]
dim(df2)
df2 = df2[order(df2[,"pct_change"], decreasing =FALSE),]
decr_nm = head(df2, 10)[,"tkr"]


# 7. biggest change since last week (7 days ago)
lastwk.ch = as.character(today - 9)
today.ch = as.character(today-2)
df3 = compare_time_pts(ll, lastwk.ch, today.ch) 
df3 = df3[which(df3[,"laterT"] > 20000),]
df3 = df3[order(df3[,"pct_change"], decreasing = TRUE),]
incr = head(df3, 10)
decr = tail(df3, 10)

incr = cbind(Name=NA, incr)
colnames(incr) = c("Name", "Ticker", "Last Week", "Today", "% Change")
incr[,3] = format(incr[,3], big.mark=",", digits=0, scientific=FALSE)
incr[,4] = format(incr[,4], big.mark=",", digits=0, scientific=FALSE)
incr[,5] = format(incr[,5], big.mark=",", digits=0, scientific=FALSE)
incr[1,"Name"] = ""
incr[2,"Name"] = ""
incr[3,"Name"] = ""
incr[4,"Name"] = ""
incr[5,"Name"] = ""
incr[6,"Name"] = ""
incr[7,"Name"] = ""
incr[8,"Name"] = ""
incr[9,"Name"] = ""
incr[10,"Name"] = ""

decr = cbind(Name=NA, decr)
colnames(decr) = c("Name", "Ticker", "Last Week", "Today", "% Change")
decr[,3] = format(decr[,3], big.mark=",", digits=0, scientific=FALSE)
decr[,4] = format(decr[,4], big.mark=",", digits=0, scientific=FALSE)
decr[,5] = format(decr[,5], big.mark=",", digits=0, scientific=FALSE)
decr[1,"Name"] = "Digital Ally"
decr[2,"Name"] = "Wynn Resorts"
decr[3,"Name"] = "Ideanomics"
decr[4,"Name"] = "Seanergy Maritime"
decr[5,"Name"] = "Globalstar"
decr[6,"Name"] = "Urban One D"
decr[7,"Name"] = "Kitov Pharma"
decr[8,"Name"] = "Urban One A"
decr[9,"Name"] = "Bed Bath Beyond"
decr[10,"Name"] = "Electrameccanica"


png("Incr_since_lastwk.png", width=400, height=300, bg="white")
grid.table(incr, rows=NULL)
dev.off()

png("Decr_since_lastwk.png", width=400, height=300, bg="white")
grid.table(decr, rows=NULL)
dev.off()

# 8. Estimate total account position
df = data.frame(date=seq(from=as.Date("2019-05-01"), to=as.Date("2020-07-11"), by="day"))
for ( i in 1:length(ll) ) {
  xt = ll[[i]]$y_daily
  tk = colnames(xt)[1]
  dff = data.frame(date=as.Date(index(xt)), xt=as.numeric(xt[,1]))
  df = merge(df, dff, by="date", all.x=TRUE, all.y=TRUE)
  colnames(df)[i+1] = tk
}
total_pos = apply(df[,-1], 1, sum, na.rm=TRUE) / 1e6
X11();plot(df[,"date"], total_pos, type="l", xlab="date", ylab="Total Position (million)")
df1 = cbind(date=df[,"date"], df[,-1]/(1e6*total_pos))

X11();par(mfrow=c(3,3), mar=c(2,2,2,2))
plot(df1[,"date"], df1[,"TSLA"], type="l", xlab="", ylab="% of total", main="TSLA")
plot(df1[,"date"], df1[,"AMZN"], type="l", xlab="", ylab="% of total", main="AMZN")
plot(df1[,"date"], df1[,"AAPL"], type="l", xlab="", ylab="% of total", main="AAPL")
plot(df1[,"date"], df1[,"MSFT"], type="l", xlab="", ylab="% of total", main="MSFT")
plot(df1[,"date"], df1[,"FB"], type="l", xlab="", ylab="% of total", main="FB")
plot(df1[,"date"], df1[,"GOOG"], type="l", xlab="", ylab="% of total", main="GOOG")
plot(df1[,"date"], df1[,"NIO"], type="l", xlab="", ylab="% of total", main="NIO")
plot(df1[,"date"], df1[,"F"], type="l", xlab="", ylab="% of total", main="F")
plot(df1[,"date"], df1[,"CCL"], type="l", xlab="", ylab="% of total", main="CCL")

vv = t(tail(df1,1)[,-1])[order(vv[,1], decreasing = TRUE),]




# Get YF stock prices
sapply(top_nm, function(.k) getSymbols(.k, env=globalenv(), src="yahoo", from="1800-01-01"))
sapply(incr[,"Ticker"], function(.k) getSymbols(.k, env=globalenv(), src="yahoo", from="1800-01-01"))
sapply(decr[,"Ticker"], function(.k) getSymbols(.k, env=globalenv(), src="yahoo", from="1800-01-01"))



# Time Series Plots (one yr)
setwd(plot_dir)
png("Plot_Top_10.png", width = 1080, height=640)
par(mfrow=c(3,4), mar=c(2,2,2,2))
for ( s in top_nm ) {
  ix = which(tkr == s)
  y = ll[[ix]]$y_daily["2020-01::"]
  df3 = data.frame(date=as.Date(index(y)), y=as.numeric(y))
  y1 = get(s)["2020-01::", 6]
  df4 = data.frame(date=index(y1), y1=as.numeric(y1))
  df5 = merge(x=df3, y=df4, by="date", all.x=FALSE, all.y=TRUE)
  tick.loc = as.integer(seq.int(from=1, to=nrow(df5), length.out=10))
  plot(y~date, data=df5, xlab="", ylab="", xaxt="n", type="l", lwd=5, col="red", main=s)
  par(new=TRUE)
  plot(y1~date, data=df5, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=1, col="blue" )
  axis(1, at=df5[tick.loc,"date"], labels=format(df5[tick.loc,"date"], "%b-%d"), cex.axis=0.6)
}
plot(0, type="n", axes=FALSE, ann=FALSE)
legend(x="center", legend=c("Popularity", "Stock Price"), col=c("red", "blue"), lty=1, lwd=5, cex=2)
dev.off()


png("Plot_incr_since_lastwk.png", width = 1080, height=640)
par(mfrow=c(3,4), mar=c(2,2,2,2))
for ( s in incr[,"Ticker"] ) {
  ix = which(tkr == s)
  y = ll[[ix]]$y_daily["2020-06-15::"]
  df3 = data.frame(date=as.Date(index(y)), y=as.numeric(y))
  y1 = get(s)["2020-06-15::", 6]
  df4 = data.frame(date=index(y1), y1=as.numeric(y1))
  df5 = merge(x=df3, y=df4, by="date", all.x=FALSE, all.y=TRUE)
  tick.loc = as.integer(seq.int(from=1, to=nrow(df5), length.out=10))
  plot(y~date, data=df5, xlab="", ylab="", xaxt="n", type="l", lwd=5, col="red", main=s)
  par(new=TRUE)
  plot(y1~date, data=df5, xlab="", ylab="", xaxt="n", yaxt="n", type="l", lwd=5, col="blue" )
  axis(1, at=df5[tick.loc,"date"], labels=format(df5[tick.loc,"date"], "%b-%d"), cex.axis=0.6)
}
plot(0, type="n", axes=FALSE, ann=FALSE)
legend(x="center", legend=c("Popularity", "Stock Price"), col=c("red", "blue"), lty=1, lwd=5, cex=2)
dev.off()


setwd(private_dir)
save.image("Robintrack_Jul19.RData")

