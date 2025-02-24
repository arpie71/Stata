A lot of times you want to know the country name for a certain COW code or the COW code for a country name. I have written up a quick little program that will allow you to look up this information within Stata. The command is called ctyfind.

There is a help document included. Basically, there are two functions. You can enter a country identifier and get a list of other country identifiers. Or you can enter a partial country name to get its name in the database. I also made the search result clickable. For example if you type:
ctyfind Bar, list
It will show on the screen:
Antigua And Barbuda
Barbados

Both will be clickable links that will run the ctyfind command to get the other country identifiers. 


To install, put the files in the ado/plus/c directory. On Windows machines it should be c:\ado\personal\c.
On Macs you can get the location by typing sysdir in Stata and looking for the PLUS location. You might have to add a "c" directory. 

If you find it useful feel free to share it with others.
