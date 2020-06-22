# Robinhood at a Glance

This is a preamble to full scale modeling the Robinhood popularity data using machine learning. Before I do that, I want to 
take a glance of the current market as seen in the Robinhood community. Here I use the dataset provided in [*robintrack*](https://robintrack.net), 
which has user holdings up till Jun 20, 2020. 

[Robinhood](https://robinhood.com) is a discount broker which charges zero commission for stock trading. It has gained almost a cult following in
recent years, particularly among the millennials. Unlike other brokers, it publishes aggregate data about what stocks its
users own, and that is the *popularity data* I analyse here. 

For example, in the table below, it shows there are 904,254 stock accounts in Robinhood 
that owns shares in Ford. However, Robinhood does not publish the exact number of shares each account holds. 

Since the dataset is sizeable and it belongs to *robintrack*, I do not include it in this repo. 
To run my scripts, you need to download it from his site (see __Data Sources__ below) and place it under the `data` subdirectory.

## Top 10 Holdings
These are the favorites of the Robinhood community. Interestingly, seven of the 10 happen to be old fashion non-technology names. 

| Ticker    |  Company Name   | Mar 20 Holdings | Current Holdings | Change % |
| -----------|--------|---------|---------|------|
|    F  |  Ford | 303,352  |  904,254 |  198  |
|   GE  |  General Electric |291,234  |  817,346 | 180  |
|     AAL |  American Airline  |61,748  |  643,567 | 942 |
|  DIS  | Disney |167,922  |  605,648 | 260  |
|  DAL  |   Delta Airline | 62,161  |  594,703 | 856 |
|  CCL  |  Carnival | 49,300  |  500,496 | 915 |
| GPRO  | GoPro |208,416  |  487,691 | 134|
| MSFT  |  Microsoft |219,815  |  474,344 | 115 |
|    ACB  | Aurora Cannabis |461,893  |  465,437 | 0.7|
|   AAPL  |  Apple |224,299  |  438,283 | 95 |

![top_ten](plots/Top_10.png)

## Stocks held by at least 100k accounts
Just a quick scan of the most popular holdings. Notice that some of these are ETF, e.g. `VOO`, `SPY`. 

`"F"    "GE"   "AAL"  "DIS"  "DAL"  "CCL"  "GPRO" "MSFT" "ACB"  "AAPL" "NCLH" "UAL"  "BA"   "BAC"  "FIT"` 
`"PLUG" "SNAP" "TSLA" "HEXO" "CGC"  "AMZN" "RCL"  "SAVE" "UBER" "INO"  "CRON" "TWTR" "AMD"  "BABA" "FB"`  
`"GRPN" "MRNA" "ZNGA" "MGM"  "MRO"  "SBUX" "LUV"  "APHA" "KO"   "JBLU" "T"    "GNUS" "TOPS" "MFA"  "USO"` 
`"OGI"  "XOM"  "UCO"  "HTZ"  "NIO"  "NKLA" "IVR"  "LK"   "NFLX" "GM"   "AMC"  "SPCE" "NOK"  "CPE"  "VOO"` 
`"CTST" "NRZ"  "NVDA" "PENN" "PLAY" "TLRY" "CPRX" "DKNG" "OAS"  "SIRI" "WORK" "SPY"` 


## Largest % increase since Mar 20
I use the holding level on March 20 as the base for comparison since that's the bottom of this bear market -- so far. 

    
| Ticker    |  Company Name   | Mar 20 Holdings | Current Holdings | Change % |
| -----------|--------|---------|---------|------|
| GNUS   | Genius Brands |  6140 |   190193  | 2997 |
|  HTZ   | Hertz|  7126 |   163226|  2190|
|  IVR   | Invesco Mortgage|  7974  |  144370 |  1710|
|  UCO  |ProShares Ultra Crude Oil|  11363  |  164385 |  1346|
| XSPA  |XpresSpa |   6462  |   90944 |  1307|
| SAVE  |Spirit Airlines|  17886  |  231562 |  1194|
|  OAS  |Oasis Petroleum|   8338  |  103812 |  1144|
| PLAY  |Dave Buster's Ent|   9114  |  107744 |  1082|
|  CPE  |Callon Petroleum|   9960  |  115889 |  1063|
| SHIP  |Seanergy Maritime|   6775  |   78600 |  1060|


## Largest decrease since Mar 20
Who is falling out of favor. To make sure we're not picking up penny stocks with little
interest, the holding on Mar 20 must be at least 10k. 

      tkr base_holding cur_holding  pct_change
1738   CY     10437.11      7514.5 -28.0021199
4020   IQ     38409.43     28256.2 -26.4342153
5097   MU     58209.85     51520.3 -11.4921324
6220 QLGN     11524.77     11104.8  -3.6440576
8208  WMG     14117.89     13779.0  -2.4004218
4257 JNUG     41869.29     40870.1  -2.3864464
7476 TMBR     13788.03     13542.9  -1.7778486
8034  VRM     17046.08     16914.5  -0.7719271






 
### Data Sources
Popularity data originated from Robinhood, but is sourced from *robintrack*[1]. 
Price data is from Yahoo Finance[2].

## Scripts



### Install Software
To install R, press Ctrl+Alt+T to open a terminal

    sudo apt-get update 
    sudo apt-get install r-base

### Dependencies
Code has been tested on 
* R 3.6.0
* Ubuntu 18.04 


### Contact
To ask questions or report issues, please open an issue on the [issues tracker](https://github.com/htso/Robinhood_at_a_glance/issues).


References

[1] https://robintrack.net

[2] https://finance.yahoo.com/