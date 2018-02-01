
{smcl}
{* 20apr2012}{...}
{hline}
help for {hi:ccode}
{hline}

{title:Program to convert to different country codes.}

{p 8 14 2}
   {cmd: ccode}
   {it:country_var} 
   {cmd:,}
   {cmd: from}{it:(Country code name)}
   {cmd: to}{it:(Country code name)}
   {cmd: gen}{it:(newvar)}
{p_end}

{title:Description}

{p 4 4 2}
This command is to translate between different country codes used in data. For example, if you have a dataset where countries are identified by World Bank code 
and you want to merge with data where countries are identified by IMF code, you could use this program to create a new IMF code variable. As of now, the country 
codes available are the Correlates of War, IMF's numeric code, the World Bank's alphabetical code, and Banks's numeric code.
{p_end}


{title:Options}
{p 4 4 2}{it:country_var} is the name of the exising variable that contains the country code{p_end}
{p 4 4 2}{cmd:from} is the name of the country code {it:country_var} is in{p_end}
{p 4 4 2}{cmd:to} is the name of the country code {it:newvar} will be in{p_end}
{p 4 4 2}{it:newvar} is the name of the new variable to be created{p_end}

{title:Supported databases}

{title:Notes}

