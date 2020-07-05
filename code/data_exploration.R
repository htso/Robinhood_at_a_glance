# data_exploration.R -- on the raw CSV files.
# Horace W. Tso (c)
# Jun 25, 2020

library(quantmod)

home = "/mnt/WanChai/Dropbox/GITHUB_REPO/Robinhood_at_a_glance"
home = "/mnt/WanChai/Dropbox/AlgoTrading/Robinhood"
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
# Read CSV files, convert them to xts objects, save them to the data_env environment
setwd(dat_dir)
data_env = new.env()
Len = sapply(nm, read_convert_save2env, data_env=data_env)
summary(Len)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  19   15136   17828   15097   17861   32077 
# time series lengths
setwd(home)
png("LengthDistrib.png", width=640, height=480)
hist(Len, breaks=35, xlab="No of observations in a CSV file", main="Distribution of Time Series Lengths")
dev.off()
# Data issue : some time series are much longer than others. Duplicate entries. 
which(Len > 25000)
# 9
EBR.csv GEF.csv HEI.csv HVT.csv LEN.csv MKC.csv PBR.csv STZ.csv WSO.csv 
2136    3125    3476    3661    4543    4906    5739    7214    8247

# Look at their time steps =================================================
ll = sweep_env(data_env, xts_time_spacing)
# Over all the tickers, what percent of the time intervals falls in the half-hr to 1 hr bucket?
pct_1hr = sapply(ll, function(.x) .x[["granu"]][["1hr"]] / sum(.x[["granu"]]))
png("OneHrIntervalDistrib.png", width=640, height=480)
hist(pct_1hr, breaks=30, xlab="Fraction of 1-hr Intervals", main="Distribution of One-Hour Intervals")
dev.off()
# Observation : Most of the data are spaced by 1 hour. 

# Over all the tickers, what percent of the time intervals falls in the 0 to 5-min bucket?
pct_5min = sapply(ll, function(.x) .x[["granu"]][["5min"]] / sum(.x[["granu"]]))
png("5minIntervalDistrib.png", width=640, height=480)
hist(pct_5min, breaks=30, xlab="Fraction of 5-min Intervals", main="Distribution of 5-min Intervals")
dev.off()
# Observation : very few. But there are some tickers with more than 40% deltas in the 5min bucket. 
# That smells trouble. Who are these ?
sapply(which(pct_5min > 0.2), function(.i)ll[[.i]][["tkr"]]) # more than 20% of intervals are in this 5-min bucket
"EBR" "GEF" "HEI" "HVT" "LEN" "MKC" "PBR" "STZ" "WSO"
# They all seem to be outer-joined by two different tickers together. Two adjacent
# observations are just seconds apart, and they fluctuate in identifical manner.
# indiv check :
xts_time_spacing(data_env$STZ)

# How many tickers have near zero holding over the entire time period (2 yrs)?
ll1 = sweep_env(data_env, holding_below_threshold, thres=1e-2)
ix.ave = sapply(ll1, function(.x).x[["ave.below"]])
table(ix.ave)
ix.med = sapply(ll1, function(.x).x[["med.below"]])
table(ix.med)
ix.latest = sapply(ll1, function(.x).x[["latest.n.below"]])
table(ix.latest)

sapply(which(ix.ave), function(.i)ll1[[.i]][["tkr"]])
[1] "AFCB"  "ALZH"  "API"   "APL"   "BMAY"  "CGRO"  "CHAQ"  "CHLN"  "CI"    "CNTX"  "CNWGY"
[12] "DEED"  "DMXF"  "EAOA"  "EAOK"  "EAOM"  "EAOR"  "EMSH"  "EROC"  "EVGBC" "EVLMC" "EVSTC"
[23] "EYEG"  "GAME"  "GASX"  "HCRB"  "INNL"  "KOKU"  "KOS"   "LLL"   "MNST"  "NUZE"  "PETZC"
[34] "PLCY"  "PQDI"  "QLVD"  "REFA"  "RNDM"  "RNEM"  "ROCH"  "RTR"   "SCNB"  "SCON"  "SFIG" 
[45] "SPRO"  "SQBG"  "STMB"  "TAL"   "TIG"   "TIVO"  "UBNK"  "VRAY"  "VXX"  

length(sapply(which(ix.med), function(.i)ll1[[.i]][["tkr"]]))
[1] "AA"    "ABAX"  "ABCD"  "AFCB"  "AFLG"  "AGC"   "ALZH"  "AMHC"  "ANCX"  "ANDV" 
[11] "APB"   "API"   "APL"   "APTI"  "ARVR"  "AVHI"  "BBOX"  "BDCX"  "BHAC"  "BHACU"
[21] "BKAG"  "BKEM"  "BKIE"  "BKMC"  "BKSE"  "BLH"   "BMAY"  "BNKO"  "BNKZ"  "BOJA" 
[31] "BSBE"  "BSCI"  "BSDE"  "BSJI"  "BSMM"  "BSMN"  "BSMP"  "BSMR"  "BWINA" "BWINB"
[41] "CA"    "CCT"   "CGRO"  "CHAQ"  "CHEP"  "CHFN"  "CHLN"  "CI"    "CIIC"  "CNDF" 
[51] "CNSF"  "CNTX"  "CNWGY" "COBZ"  "COTV"  "CPLA"  "CVG"   "CVON"  "CWAY"  "CYS"  
[61] "DBEH"  "DEED"  "DEEF"  "DFPH"  "DFVL"  "DIVC"  "DJCB"  "DM"    "DMAY"  "DMXF" 
[71] "DNO"   "DOTA"  "DTUL"  "DTUS"  "DWCH"  "DWMF"  "DWUS"  "EACQ"  "EAOA"  "EAOK" 
[81] "EAOM"  "EAOR"  "ECYT"  "EDGW"  "EEQ"   "EGL"   "EIO"   "EIP"   "ELON"  "EMJ"  
[91] "EMSH"  "ENLK"  "EQGP"  "ERGF"  "ERM"   "EROC"  "ESIO"  "ESRX"  "EVGBC" "EVHC" 
[101] "EVLMC" "EVO"   "EVP"   "EVSTC" "EXPC"  "EYEG"  "FBNK"  "FBR"   "FFKT"  "FIEU" 
[111] "FJNK"  "FLAT"  "FLBL"  "FLIA"  "FLMI"  "FMI"   "FMTX"  "FNCF"  "GAME"  "GASX" 
[121] "GBNK"  "GGP"   "GKNLY" "GLF"   "GLIF"  "GNBC"  "GNRS"  "GPT"   "GSID"  "HACV" 
[131] "HACW"  "HAHA"  "HAUD"  "HCRB"  "HCRF"  "HDP"   "HEFV"  "HEMV"  "HEUS"  "HHYX" 
[141] "HQBD"  "HQCL"  "HSMV"  "IBMG"  "IBTD"  "IBTE"  "IBTG"  "IBTI"  "IBTJ"  "IDY"  
[151] "IGEM"  "ILG"   "IMFD"  "IMFI"  "IMFP"  "IMPV"  "INDF"  "INDU"  "INNL"  "INPX" 
[161] "INTX"  "IPOB"  "ISDX"  "ISEM"  "IVTY"  "JJS"   "JMBA"  "JNP"   "JPEH"  "JTPY" 
[171] "KANG"  "KED"   "KLXI"  "KNAB"  "KOKU"  "KOR"   "KOS"   "KRNY"  "KS"    "KYE"  
[181] "LATN"  "LCM"   "LGCY"  "LIVK"  "LLL"   "LSAC"  "LSAF"  "MATF"  "MLPR"  "MMV"  
[191] "MNST"  "MRGR"  "MSP"   "MTGE"  "MZF"   "MZOR"  "NAO"   "NAP"   "NRGO"  "NRGU" 
[201] "NRGZ"  "NSM"   "NUZE"  "NXEO"  "NXEOU" "NYH"   "NYRT"  "OASI"  "OHRP"  "OIIL" 
[211] "OMOM"  "ONP"   "ONTL"  "OPER"  "OQAL"  "OVB"   "OVF"   "OVLU"  "OVM"   "OVS"  
[221] "P"     "PAAC"  "PAH"   "PBDM"  "PBEE"  "PBND"  "PBSK"  "PBSM"  "PBTP"  "PCF"  
[231] "PCPL"  "PERY"  "PETZC" "PHYL"  "PKD~"  "PLCY"  "PMPT"  "PNK"   "PPLN"  "PPSC" 
[241] "PQDI"  "PQIN"  "PQSG"  "PQSV"  "QCP"   "QLVD"  "QLVE"  "QXMI"  "RECS"  "REFA" 
[251] "REIS"  "RENX"  "REVS"  "RFM"   "RIDV"  "RLJE"  "RMGN"  "RNDM"  "RNEM"  "ROCH" 
[261] "RODE"  "RODI"  "RPUT"  "RTR"   "RWED"  "RWUI"  "RWW"   "SAQN"  "SBUG"  "SCNB" 
[271] "SCON"  "SEIX"  "SEND"  "SFIG"  "SHNY"  "SHYL"  "SIXA"  "SIXL"  "SIXS"  "SKYAY"
[281] "SNMX"  "SPRO"  "SPUN"  "SQBG"  "SQEW"  "SQLV"  "STLC"  "STLV"  "STMB"  "STRA" 
[291] "SVU"   "SWIN"  "SYE"   "SYNT"  "SYV"   "TAEQ"  "TAL"   "TCHF"  "TIG"   "TIVO" 
[301] "TOTA"  "TSRO"  "TVIZ"  "UBNK"  "UCBA"  "UHN"   "USAG"  "USXF"  "UTLF"  "VBIV" 
[311] "VGFO"  "VIIZ"  "VLP"   "VMAX"  "VRAY"  "VVC"   "VXX"   "WFIG"  "WLDR"  "WNGRF"
[321] "WPZ"   "XCRA"  "XL"    "XMHQ"  "XOXO"  "XPLR"  "XRM"   "YESR"  "YGRN"  "ZGYH" 

sapply(which(ix.latest), function(.i)ll1[[.i]][["tkr"]])
[1] "ABAX"  "ABCD"  "AFCB"  "AGC"   "ALZH"  "AMMA"  "ANCX"  "ANDV"  "APB"   "API"  
[11] "APL"   "APTI"  "ARCH"  "ARVR"  "AVHI"  "BBOX"  "BDCX"  "BHAC"  "BHACU" "BLH"  
[21] "BMAY"  "BOJA"  "BSCI"  "BSJI"  "BSML"  "BSMM"  "BSMN"  "BSMP"  "BSMR"  "BWINA"
[31] "BWINB" "CA"    "CCT"   "CGRO"  "CHAQ"  "CHFN"  "CHLN"  "CI"    "CNDF"  "CNSF" 
[41] "CNTX"  "CNWGY" "COBZ"  "COTV"  "CPL"   "CPLA"  "CVG"   "CVON"  "CVRR"  "CWAY" 
[51] "CYS"   "DEED"  "DM"    "DMXF"  "DNO"   "DOGS"  "DOTA"  "DTUS"  "DWCH"  "EACQ" 
[61] "EAOA"  "EAOK"  "EAOM"  "EAOR"  "ECYT"  "EDGW"  "EEQ"   "EGC"   "EGL"   "EIO"  
[71] "EIP"   "ELON"  "EMJ"   "EMSH"  "ENLK"  "EQGP"  "ERGF"  "EROC"  "ESIO"  "ESRX" 
[81] "EVGBC" "EVHC"  "EVLMC" "EVO"   "EVP"   "EVSTC" "EYEG"  "FBNK"  "FBR"   "FFKT" 
[91] "FIEU"  "FLIO"  "FMI"   "FNCF"  "GAME"  "GASX"  "GBNK"  "GEC"   "GGP"   "GKNLY"
[101] "GLF"   "GNBC"  "GPT"   "GSID"  "HACV"  "HACW"  "HAHA"  "HCRB"  "HCRF"  "HDP"  
[111] "HEFV"  "HEMV"  "HEUS"  "HHYX"  "HQBD"  "HQCL"  "HSMV"  "HUSE"  "IBMG"  "IGEM" 
[121] "ILG"   "IMPV"  "INDF"  "INDU"  "INNL"  "INTX"  "IVTY"  "JMBA"  "JMEI"  "JNP"  
[131] "JPEH"  "JTPY"  "KANG"  "KDFI"  "KED"   "KLXI"  "KOKU"  "KOR"   "KOS"   "KS"   
[141] "KYE"   "LCM"   "LGCY"  "LLL"   "LSAC"  "MATF"  "MEXX"  "MLPR"  "MMV"   "MNST" 
[151] "MRGR"  "MSP"   "MTGE"  "MZF"   "MZOR"  "NAO"   "NAP"   "NSM"   "NUZE"  "NXEO" 
[161] "NXEOU" "NYH"   "NYRT"  "OASI"  "OHRP"  "OIIL"  "OMOM"  "ONP"   "ONTL"  "OSIZ" 
[171] "OVB"   "OVF"   "OVS"   "OYLD"  "P"     "PAH"   "PBDM"  "PBSK"  "PBSM"  "PERY" 
[181] "PETZC" "PKD~"  "PLCY"  "PMPT"  "PNK"   "PQDI"  "QCP"   "QLVD"  "QXMI"  "RAAX" 
[191] "REEM"  "REFA"  "REIS"  "RENW"  "RENX"  "RIDV"  "RLJE"  "RMGN"  "RNDM"  "RNEM" 
[201] "ROCH"  "RODE"  "RPUT"  "RRD"   "RTR"   "RWW"   "SCNB"  "SCON"  "SDAG"  "SEIX" 
[211] "SEND"  "SFIG"  "SHNY"  "SIXL"  "SKYAY" "SNMX"  "SPEX"  "SPRO"  "SPUN"  "SQBG" 
[221] "STLC"  "STMB"  "SVU"   "SWIN"  "SYNT"  "TAL"   "TCHF"  "TIG"   "TIVO"  "TSRO" 
[231] "TVIZ"  "UBNK"  "UCBA"  "UHN"   "USAG"  "UTLF"  "VIIZ"  "VLP"   "VMAX"  "VRAY" 
[241] "VVC"   "VXX"   "WPZ"   "XCRA"  "XL"    "XOXO"  "XPLR"  "XRM"   "YESR" 

# Any abrupt change in user holding?
# -- step change from X to zero, or from zero to X
ll2 = sweep_env(data_env, abrupt_change, thres=20000)
ix.big.ch = sapply(ll2, function(.x).x[["big.change"]])
sapply(which(ix.big.ch), function(.i)ll2[[.i]][["tkr"]])

png("ACB.png", width=640, height=480)
plot(data_env$ACB) # stock split ?
dev.off()
png("GNUS.png", width=640, height=480)
plot(data_env$GNUS) # sharp rise is real !
dev.off()
png("IGC.png", width=640, height=480)
plot(data_env$IGC) # chunk of data is missing 
dev.off()
png("INPX.png", width=640, height=480)
plot(data_env$INPX) # chunk of data is missing  
dev.off()
png("NKLA.png", width=640, height=480)
plot(data_env$NKLA) # sharp rise is real
dev.off()
png("UBER.png", width=640, height=480)
plot(data_env$UBER) # no issue
dev.off()
png("UCO.png", width=640, height=480)
plot(data_env$UCO) # problem with one or two data points
dev.off()
png("USO.png", width=640, height=480)
plot(data_env$USO) # not sure why such sharp drop
dev.off()
png("WORK.png", width=640, height=480)
plot(data_env$WORK) # coincide with price gap down
dev.off()



# Which tickers have seen user holding falling to zero from at least 10k in Feb ?


# Which tickers have been holding steadily rising ?








