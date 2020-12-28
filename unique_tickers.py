import pickle
import numpy as np
import pandas as pd
import pdblp

# start bloomberg
con = pdblp.BCon(debug=False, port=8194)
con.start()
con = pdblp.BCon(timeout=5000)
con.restart()

# read file
file =  pd.read_csv('all_SX5E_Index_constituents_from_1984-01-01_to_2020-11-01.csv')

# get unique tickers
unique_tickers = []
file =file.to_numpy()
row,col = np.shape(file)

for i in range(0,row):
    for j in range(0,col):
        unique_tickers.append(file[i][j])

unique_tickers = [x for x in unique_tickers if pd.notnull(x)]
unique_tickers = set(unique_tickers)
unique_tickers = list(unique_tickers)

# Construct ticker to feed to Bloomberg
eqt = " Equity"
for i in range(0,len(unique_tickers)):
    unique_tickers[i]+=eqt
    
# get data from bloomberg
tickers = unique_tickers
fields = ['PX_Last']
historical_prices = con.bdh(tickers, fields,'19840101', '20201101')


# create list of all tickers
data_top=list(historical_prices.columns)
tickers =[]
for tick in data_top:
    tup = tick[0]
    tickers.append(tup[:-7])
historical_prices.columns = tickers# ['SXXP'] # change tickers of historical prices
historical_prices.to_pickle("./SX5E_constprices.pkl")


historical_prices.to_pickle("./SXXP_indiex_constprices.pkl")





