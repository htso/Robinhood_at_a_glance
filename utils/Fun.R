

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


sweep_env = function(env, fun) {
  tkr = ls(envir=env)
  ll = lapply(tkr, function(.s) fun(get(.s, envir=env)))
  return(ll)
}


latest_stat = function(le, base_date) {
  tkr = colnames(le[["y_daily"]])[1]
  base_hld = mean(le[["y_daily"]][base_date], na.rm=TRUE)
  cur_hld = mean(as.matrix(tail(le[["y_daily"]], 10)), na.rm=TRUE)
  list(tkr=tkr, base_holding=base_hld, cur_holding=cur_hld)
}









