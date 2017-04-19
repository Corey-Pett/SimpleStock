# SimpleStock

This iOS application was to fulfill a coding challenge below:

 A Simple Stock Info App
The goal of this app is to allow a user to search for a particular publicly traded company and display a price history for a selected stock symbol.
Try to get as far as you can, it’s okay if you can’t complete every use case.
Framework Requirements
● Use Objective C, Swift, or Android for the front end (avoid using projects like cordova and rubymotion)
● Any server side framework you like
● You’re welcome to use any open-source charting framework.
● Your code should be committed to a github project
● Your github project’s ReadMe.md should have clear instructions on how to setup and run
the project.
Data Sources
Stock Symbols
You can get a CSV of listed stocks for each exchange from here:
http://www.nasdaq.com/screening/company-list.aspx
Stock Price History
Yahoo provides a free API to retrieve historical stock prices:
https://www.google.com/webhp?ion=1&espv=2&ie=UTF%C2%AD8#q=yahoo+finance+api+ruby +gem
Use Cases
Symbol Search (SymSrch)
1. You must present a view to allow a user to search for a stock symbol by company name.
2. The search algorithm can be a simple prefix match.
a. Example: the query “app” should have “Apple Inc” in the results.
b. This request should be non blocking
c. You may prefect all the symbols but, the app should remain responsive when
doing this.
3. The results of the search will have at least the company’s stock symbol and name.
a. The results should be initial by “Company Name Ascending”
Setup Details
● You can save the listed stock CSVs to a directory in your project
Price History Chart (PrcHist)
1. On selecting a symbol search result row, a chart will be rendered showing the prices of the stock for the last 30 days.
    
 2. The stock price history chart should render a point for the average price per “historic quote”.
a. Example: Yahoo will return a series of “quote” entries for a symbol. Each entry will have a number of fields, you should take the average of low, high, open, and close for the value on the y-axis.
Bonus Features
1. Instead of the doing the average of the price per quote entry, render a candlestick bar instead:  http://en.wikipedia.org/wiki/Candlestick_chart
2. Auto-complete: Display symbol search results dynamically as the user provides search input rather than requiring a full form submission.
3. Handle loading of data from the network with some kind of loading display, so the user isn’t looking at blank screens as things wait to load
4. Save the data to disk so the app is usable without networking, when the app comes back online it should update its data.
  
