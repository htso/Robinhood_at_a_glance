
abrupt_change = function(xt, thres=10000) {
  tkr = colnames(xt)[1]
  dx = diff(xt, lag=1)
  big.change = any(abs(dx) > thres)
  return(list(tkr=tkr, big.change=big.change))
}


holding_below_threshold = function(xt, thres=1e-2) {
  tkr = colnames(xt)[1]
  ave = mean(xt, na.rm=TRUE)
  med = median(xt, na.rm=TRUE)
  latest_n = mean(tail(xt, 24), na.rm=TRUE) # last 24 hours or roughly one day
  ave.below = ifelse(ave < thres, TRUE, FALSE) 
  med.below = ifelse(med < thres, TRUE, FALSE) 
  latest.n.below = ifelse(latest_n < thres, TRUE, FALSE)
  return(list(tkr=tkr, ave.below=ave.below, med.below=med.below, latest.n.below=latest.n.below))
}




xts_time_spacing = function(xt) {
  tkr = colnames(xt)[1]
  tdt = index(xt)
  # NOTE : there's a bug in diff(tdt). Sometimes it gives delta in minute, other time in second.
  # Instead, use difftime which allows unit to be specified. 
  tmp = difftime(tail(tdt,-1), head(tdt,-1), units="secs") # set unit to smallest time interval
  dtdt = as.integer(tmp) # delta in seconds
  granu = cut(dtdt, breaks=c(0, 60*5, 60*30,60*60,12*60*60,24*60*60,Inf), 
              labels=c("5min", "halfhr", "1hr", "halfday", "1day", "morethan"), 
              include.lowest=FALSE, right=TRUE, ordered_result = TRUE)
  tb = table(granu)
  return(list(tkr=tkr, granu=tb))
}




parse_ticker = function(s) {
  if(length(s) == 2) {
    if (s[2] == "csv") x = s[1] else x = NA
  } else if (length(s) == 3) {
    if ( s[3] == "csv") x = paste(s[1], s[2], sep=".") else x = NA
  } else
    stop("string has too many periods")
  return(x)
}


read_convert_save2env = function(fnm, data_env) {
  ch = strsplit(fnm, split = "\\.")[[1]]
  if(length(ch) == 2) {
    if (ch[2] == "csv") 
      tkr = ch[1] 
    else 
      return(NA)
  } else if (length(ch) == 3) {
    if ( ch[3] == "csv") 
      tkr = paste(ch[1], ch[2], sep=".") 
    else 
      return(NA)
  } else
    return(NA)
  x = read.csv(fnm, header=TRUE, stringsAsFactors=FALSE)
  if (ncol(x) != 2) stop("this csv file has more or less than two columns ?!")
  if (colnames(x)[2] != "users_holding") stop(paste("colnames :", colnames(x)))
  # NOTE : robintrack timestamps are GMT. The guy said it on his website
  x = cbind(date=strptime(x[,1], "%Y-%m-%d %H:%M:%S", tz="GMT"), x)
  if ( sum(is.na(x[,"date"])) > 0 ) stop("problem with dates....found NAs")
  xt = xts(x[,3], order.by=x[,1])
  colnames(xt) = tkr
  assign(tkr, xt, envir=data_env)
  return(nrow(xt))
}


day_wk_aggregator = function(xt) {
  require(quantmod)
  y_daily = xt[endpoints(xt, on="days", k=1)[-1]]
  dy_daily = diff(y_daily)
  y_wk = xt[endpoints(xt, on="weeks", k=1)[-1]]
  dy_wk = diff(y_wk)
  return(list(y_daily=y_daily, dy_daily=dy_daily, y_wk=y_wk, dy_wk=dy_wk))
}




latest_stat = function(le, base_date) {
  tkr = colnames(le[["y_daily"]])[1]
  base_hld = mean(le[["y_daily"]][base_date], na.rm=TRUE)
  cur_hld = mean(as.matrix(tail(le[["y_daily"]], 10)), na.rm=TRUE)
  list(tkr=tkr, base_holding=base_hld, cur_holding=cur_hld)
}


sweep_env = function(env, fun, ...) {
  tkr = ls(envir=env)
  ll = lapply(tkr, function(.s) fun(get(.s, envir=env), ...))
  return(ll)
}







