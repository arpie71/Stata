
program define ccode

syntax varlist , from(string) to(string) gen(string)

*** acceptable databases: IMF, WB, COW, BANKS, CTY
qui {
if "`from'" == "" {
di as error "Please specify the form of the existing country code."
exit 198
}
if "`to'"=="" {
di as error "Please specify the form of the new country code."
exit 198
}

if ~inlist(upper("`from'"),"COW","WB","IMF","BANKS", "CTY") {
di as error "The From database must be COW, IMF, WB, Banks, Cty"
exit 198
}

if ~inlist(upper("`to'"),"COW","WB","IMF","BANKS", "CTY") {
di as error "The To database must be COW, IMF, WB, Banks, or Cty"
exit 198
}

if (upper("`to'")==upper("`from'")) {
di as error "The from and to databases are the same. Please specify different databases."
exit 198
}

tokenize `varlist'

if upper("`from'") =="COW" | upper("`from'") =="IMF" | upper("`from'") =="BANKS" {
capture confirm numeric v `1'
if _rc {
di as error "`var' is a string variable."
exit 198
}
}

if upper("`from'") =="COW" { 
local from_n = 4
}
if upper("`from'") =="IMF" {
local from_n=2
}
if upper("`from'") =="BANKS" {
local from_n=5
}

if upper("`from'") =="WB" | upper("`from'")=="CTY" {
capture confirm string v `1'
if _rc {
di as error "`var' is a numeric variable."
exit 198
}
}

if upper("`from'")=="WB" {
local from_n = 3
}

if upper("`from'")=="CTY" {
local from_n = 1
}

capture confirm new var `gen'
if _rc {
di as error "`gen' already exists. Please enter a new variable name."
exit 198
}
if upper("`to'") =="COW" {
gen `gen' = .
local to_n = 4
}
if upper("`to'") =="IMF" {
gen `gen' = .
local to_n = 2
}
if upper("`to'") =="BANKS" {
gen `gen' = .
local to_n = 5
}

if upper("`to'") =="WB" {
gen `gen' = ""
local to_n = 3
} 

if upper("`to'")=="CTY" {
gen `gen' = ""
local to_n=1
}
if upper("`from'")~="CTY" {
levelsof `1' , local(existcode) clean
}
if upper("`from'")=="CTY" {
tempvar fc
gen `fc' = proper(`1')
replace `fc' = regexr(`fc',"&","And")
replace `fc' = regexr(`fc',"^Saint","St.")
replace `fc' = regexr(`fc',"Isds","Islands")
replace `fc' = regexr(`fc',"Rep\.","Republic")
replace `fc' = regexr(`fc',"Faeroe","Faroe")
replace `fc' = "Bahamas" if `fc'=="Bahamas, The" | `fc'=="The Bahamas"
replace `fc' = "Bahrain" if regexm(`fc',"Bahrain")
replace `fc' = "Bolivia" if `fc'=="Bolivia (Plurinational State of)" | `fc'=="Bolivia, Plurinational State of"
replace `fc' = "Brunei" if `fc'=="Brunei Darussalam"
replace `fc' = "Comoros" if `fc'=="Comoro Islands" | `fc'=="Comoros Islands"
replace `fc' = "Congo, Republic" if `fc'=="Congo, Republic Of" | `fc'=="Republic Of Congo" | `fc'=="Republic Of The Congo"
replace `fc' = "Congo, Dem. Republic" if `fc'=="Zaire" | `fc'=="Dem. Republic Of The Congo" | `fc'=="Democratic Republic Of The Congo" | `fc'=="Congo DR"
replace `fc' = "Egypt" if `fc'=="Egypt, Arab Republic"
replace `fc' = "Gambia" if `fc'=="The Gambia" | `fc'=="Gambia, The"
replace `fc' = "Guinea-Bissau" if `fc'=="Guinea Bissau"
replace `fc' = "South Korea" if `fc'=="Republic Of Korea" | `fc'=="Korea, Republic" | `fc'=="Korea, Republic Of" | `fc'=="Korea Republic"
replace `fc' = "Hong Kong" if regexm(`fc',"Hong Kong")
replace `fc' = "Iran" if `fc'=="Iran, Islamic Republic"
replace `fc' = "Kyrgyz Republic" if `fc'=="Kyrgyzstan"
replace `fc' = "Laos" if `fc'=="Lao People's Dem. Republic" | `fc'=="Lao PDR"
replace `fc' = "Macedonia" if regexm(`fc',"Macedonia")
replace `fc' = "Macao" if regexm(`fc',"Macao") | regexm(`fc',"Macau")
replace `fc' = "Myanmar" if regexm(`fc',"Myanmar") | `fc'=="Burma"
replace `fc' = "Russia" if `fc'=="Russian Federation"
replace `fc' = "Slovakia" if `fc'=="Slovak Republic"
replace `fc' = "Swaziland" if regexm(`fc',"Swaziland")
replace `fc' = "Syria" if `fc'=="Syrian Arab Republic"
replace `fc' = "Taiwan" if `fc'=="Taiwan, China" | `fc'=="Chinese Taipei"
replace `fc' = "Tanzania" if regexm(`fc',"Tanzania")
replace `fc' = "United States" if `fc'=="USA" | `fc'=="US" | `fc'=="United States of America"
replace `fc' = "Vietnam" if `fc'=="Viet Nam"
replace `fc' = "Yemen, Pdr" if `fc'=="Fmr Dem. Yemen"
replace `fc' = "Yemen, Arab Republic" if `fc'=="Fmr Arab Republic of Yemen" 
replace `fc' = "Yemen, Republic" if `fc'=="Yemen, Republic Of" | `fc'=="Republic Of Yemen"

levelsof `fc' , local(existcode) clean
}

countrymacs "`_country'" "_country"
foreach var of local _country {
local code_old: word `from_n' of ``var''
local code: list code_old & existcode 

if "`code'"=="`code_old'" {
local code_new: word `to_n' of ``var''
if upper("`to'")~="WB" & upper("`from'")~="WB" & upper("`from'")~="CTY" & upper("`to'")~="CTY" {
replace `gen' = `code_new' if `1'==`code_old' & `1'~=.
}

if (upper("`to'")~="WB" & upper("`to'")~="CTY") & (upper("`from'")=="WB" ) {
replace `gen' = `code_new' if `1'=="`code_old'" & `1'~=""
}
if (upper("`to'")~="CTY" & upper("`to'")~="WB") & (upper("`from'")=="CTY") {
replace `gen' = `code_new' if `fc'=="`code_old'" & `fc'~=""
}

if (upper("`to'")=="WB" | upper("`to'")=="CTY" ) & (upper("`from'")~="WB" & upper("`from'")~="CTY") {
replace `gen' = "`code_new'" if `1'==`code_old' & `1'~=.
}
if (upper("`to'")=="CTY" ) & (upper("`from'")=="WB" ) {
replace `gen' = "`code_new'" if `1'=="`code_old'" & `1'~=""
}
if (upper("`to'")=="WB" ) & (upper("`from'")=="CTY" ) {
replace `gen' = "`code_new'" if `fc'=="`code_old'" & `fc'~=""
}
}

}
}
end

*** CREATING LOCALS

program countrymacs
#delim ;

c_local _country `"_cty_afg _cty_albania _cty_algeria _cty_amsamoa _cty_andorra _cty_angola _cty_antigua _cty_arg _cty_armenia _cty_aruba 
_cty_austral _cty_austria _cty_azer _cty_bahamas _cty_bahrain _cty_bang _cty_barb _cty_belluxns _cty_belarus _cty_belg _cty_belglux _cty_belize
 _cty_benin _cty_bermuda _cty_bhutan _cty_bolivia _cty_bosnia _cty_botswana _cty_brazil _cty_windies _cty_brunei _cty_bulgaria _cty_burkina 
_cty_burundi _cty_cambodia _cty_cameroon _cty_canada _cty_capeverde _cty_cayman _cty_car _cty_chad _cty_channel _cty_chile _cty_china 
_cty_colombia _cty_comoros _cty_zar _cty_congo _cty_cr _cty_civ _cty_croatia _cty_cuba _cty_cyprus _cty_czechrep _cty_czech _cty_czechns 
_cty_dk _cty_djib _cty_dominica _cty_dr _cty_ddr _cty_ecuador _cty_egypt _cty_salvador _cty_eqguinea _cty_eritrea _cty_estonia _cty_ethiopia 
_cty_falk _cty_faroe _cty_fiji _cty_finland _cty_france _cty_frguiana _cty_frpoly _cty_frindies _cty_gabon _cty_gambia _cty_georgia _cty_deu 
_cty_ghana _cty_gibraltar _cty_greece _cty_greenland _cty_grenada _cty_guadel _cty_guam _cty_guat _cty_guinea _cty_guinbiss _cty_guyana 
_cty_haiti _cty_hond _cty_hk _cty_hung _cty_ice _cty_india _cty_indo _cty_iran _cty_iraq _cty_ire _cty_man _cty_isr _cty_italy _cty_jamaica 
_cty_jap _cty_jordan _cty_kazak _cty_kenya _cty_kirib _cty_kuwait _cty_kyrgyz _cty_laos _cty_latvia _cty_lebanon _cty_leeward _cty_lesotho 
_cty_liberia _cty_libya _cty_liech _cty_lith _cty_lux _cty_macao _cty_maced _cty_madag _cty_malawi _cty_malay _cty_maldives _cty_mali 
_cty_malta _cty_marshall _cty_martin _cty_mauritania _cty_mauritius _cty_mayotte _cty_mex _cty_micro _cty_moldova _cty_monaco _cty_mong 
_cty_montserrat _cty_morocco _cty_mozamb _cty_myanmar _cty_namibia _cty_nauru _cty_nepal _cty_neth _cty_nethantilles _cty_caledonia _cty_nz 
_cty_nicaragua _cty_niger _cty_nigeria _cty_nkorea _cty_mariana _cty_norway _cty_oman _cty_pakistan _cty_palau _cty_panama _cty_png 
_cty_paraguay _cty_peru _cty_phil _cty_poland _cty_port _cty_pr _cty_qatar _cty_reunion _cty_romania _cty_russia _cty_rwanda _cty_samoa 
_cty_marino _cty_tome _cty_saudi _cty_senegal _cty_serbia _cty_seychelles _cty_leone _cty_sing _cty_slovak _cty_slovenia _cty_solomon 
_cty_somalia _cty_safr _cty_skor _cty_spain _cty_srilanka _cty_helena _cty_kitts _cty_lucia _cty_pierre _cty_vincent _cty_sudan _cty_suri 
_cty_swazi _cty_sweden _cty_switz _cty_syria _cty_taiwan _cty_tajik _cty_tanz _cty_thai _cty_timor _cty_togo _cty_tonga _cty_trinidad 
_cty_tunis _cty_turkey _cty_turkmen _cty_turks _cty_tuv _cty_uganda _cty_ukr _cty_uae _cty_uk _cty_us _cty_uru _cty_ussr _cty_uzbek _cty_van 
_cty_venez _cty_vietnam _cty_ukvi _cty_wallis _cty_gaza _cty_frg _cty_wind _cty_yar _cty_ypr _cty_yemen _cty_yugo _cty_yugons _cty_zamb 
_cty_zimb _cty_anguilla _cty_vatican _cty_monte _cty_cook _cty_christ _cty_cocos _cty_tokelau _cty_niue _cty_pitcairn _cty_usvi "';

#delim cr

c_local _cty_afg `""Afghanistan" 512 "AFG" 700 10"'
c_local _cty_albania `""Albania" 914 "ALB" 339 20"'
c_local _cty_algeria `""Algeria" 612 "DZA" 615 30"'
c_local _cty_amsamoa `""American Samoa" 859 "ASM" 991 ."'
c_local _cty_andorra `""Andorra" 171 "ADO" 232 32"'
c_local _cty_angola `""Angola" 614 "AGO" 540 35"'
c_local _cty_antigua `""Antigua And Barbuda" 311 "ATG" 58 37"'
c_local _cty_arg `""Argentina" 213 "ARG" 160 40"'
c_local _cty_armenia `""Armenia" 911 "ARM" 371 45"'
c_local _cty_aruba `""Aruba" 314 "ABW" 1069 854"'
c_local _cty_austral `""Australia" 193 "AUS" 900 50"'
c_local _cty_austria `""Austria" 122 "AUT" 305 61"'
c_local _cty_azer `""Azerbaijan" 912 "AZE" 373 64"'
c_local _cty_bahamas `""Bahamas" 313 "BHS" 31 69"'
c_local _cty_bahrain `""Bahrain" 419 "BHR" 692 65"'
c_local _cty_bang `""Bangladesh" 513 "BGD" 771 901"'
c_local _cty_barb `""Barbados" 316 "BRB" 53 70"'
c_local _cty_belluxns `""Bel Lux Ns" 127 "" . ."'
c_local _cty_belarus `""Belarus" 913 "BLR" 370 75"'
c_local _cty_belg `""Belgium" 124 "BEL" 211 80"'
c_local _cty_belglux `""Belgium-Luxembourg" 126 "" . ."'
c_local _cty_belize `""Belize" 339 "BLZ" 80 90"'
c_local _cty_benin `""Benin" 638 "BEN" 434 310"'
c_local _cty_bermuda `""Bermuda" 319 "BMU" 30 ."'
c_local _cty_bhutan `""Bhutan" 514 "BTN" 760 66"'
c_local _cty_bolivia `""Bolivia" 218 "BOL" 145 100"'
c_local _cty_bosnia `""Bosnia And Herzegovina" 963 "BIH" 346 107"'
c_local _cty_botswana `""Botswana" 616 "BWA" 571 110"'
c_local _cty_brazil `""Brazil" 223 "BRA" 140 120"'
c_local _cty_windies `""British West Indies" 379 "" . ."'
c_local _cty_brunei `""Brunei" 516 "BRN" 835 125"'
c_local _cty_bulgaria `""Bulgaria" 918 "BGR" 355 130"'
c_local _cty_burkina `""Burkina Faso" 748 "BFA" 439 1230"'
c_local _cty_burundi `""Burundi" 618 "BDI" 516 150"'
c_local _cty_cambodia `""Cambodia" 522 "KHM" 811 160"'
c_local _cty_cameroon `""Cameroon" 622 "CMR" 471 170"'
c_local _cty_canada `""Canada" 156 "CAN" 20 180"'
c_local _cty_capeverde `""Cape Verde" 624 "CPV" 402 185"'
c_local _cty_cayman `""Cayman Islands" 377 "CYM" 1033 ."'
c_local _cty_car `""Central African Republic" 626 "CAF" 482 190"'
c_local _cty_chad `""Chad" 628 "TCD" 483 210"'
c_local _cty_channel `""Channel Islands" . "CHI" . ."'
c_local _cty_chile `""Chile" 228 "CHL" 155 220"'
c_local _cty_china `""China" 924 "CHN" 710 230"'
c_local _cty_colombia `""Colombia" 233 "COL" 100 240"'
c_local _cty_comoros `""Comoros" 632 "COM" 581 245"'
c_local _cty_zar `""Congo, Dem. Republic" 636 "ZAR" 490 260"'
c_local _cty_congo `""Congo, Republic" 634 "COG" 484 250"'
c_local _cty_cr `""Costa Rica" 238 "CRI" 94 270"'
c_local _cty_civ `""Cote D'Ivoire" 662 "CIV" 437 580"'
c_local _cty_croatia `""Croatia" 960 "HRV" 344 275"'
c_local _cty_cuba `""Cuba" 928 "CUB" 40 280"'
c_local _cty_cyprus `""Cyprus" 423 "CYP" 352 290"'
c_local _cty_czechrep `""Czech Republic" 935 "CZE" 316 301"'
c_local _cty_czech `""Czechoslovakia" 934 "CSK" 315 300"'
c_local _cty_czechns `""Czechoslovakia Ns" 937 "" . ."'
c_local _cty_dk `""Denmark" 128 "DNK" 390 320"'
c_local _cty_djib `""Djibouti" 611 "DJI" 522 325"'
c_local _cty_dominica `""Dominica" 321 "DMA" 54 327"'
c_local _cty_dr `""Dominican Republic" 243 "DOM" 42 330"'
c_local _cty_ddr `""East Germany" 938 "DDR" 265 430"'
c_local _cty_ecuador `""Ecuador" 248 "ECU" 130 340"'
c_local _cty_egypt `""Egypt" 469 "EGY" 651 1200"'
c_local _cty_salvador `""El Salvador" 253 "SLV" 92 350"'
c_local _cty_eqguinea `""Equatorial Guinea" 642 "GNQ" 411 355"'
c_local _cty_eritrea `""Eritrea" 643 "ERI" 531 375"'
c_local _cty_estonia `""Estonia" 939 "EST" 366 360"'
c_local _cty_ethiopia `""Ethiopia" 644 "ETH" 530 370"'
c_local _cty_falk `""Falkland Islands" 323 "FLK" 1163 ."'
c_local _cty_faroe `""Faroe Islands" 816 "FRO" 11 ."'
c_local _cty_fiji `""Fiji" 819 "FJI" 950 1216"'
c_local _cty_finland `""Finland" 172 "FIN" 375 380"'
c_local _cty_france `""France" 132 "FRA" 220 390"'
c_local _cty_frguiana `""French Guiana" 333 "GUF" 120 ."'
c_local _cty_frpoly `""French Polynesia" 887 "PYF" 960 ."'
c_local _cty_frindies `""French West Indies" 383 "" . ."'
c_local _cty_gabon `""Gabon" 646 "GAB" 481 400"'
c_local _cty_gambia `""Gambia" 648 "GMB" 420 410"'
c_local _cty_georgia `""Georgia" 915 "GEO" 372 415"'
c_local _cty_deu `""Germany" 134 "DEU" 255 420"'
c_local _cty_ghana `""Ghana" 652 "GHA" 452 440"'
c_local _cty_gibraltar `""Gibraltar" 823 "GIB" 231 ."'
c_local _cty_greece `""Greece" 174 "GRC" 350 450"'
c_local _cty_greenland `""Greenland" 326 "GRL" 10 ."'
c_local _cty_grenada `""Grenada" 328 "GRD" 55 455"'
c_local _cty_guadel `""Guadeloupe" 329 "GLP" 65 ."'
c_local _cty_guam `""Guam" 829 "GUM" 985 ."'
c_local _cty_guat `""Guatemala" 258 "GTM" 90 460"'
c_local _cty_guinea `""Guinea" 656 "GIN" 438 470"'
c_local _cty_guinbiss `""Guinea-Bissau" 654 "GNB" 404 475"'
c_local _cty_guyana `""Guyana" 336 "GUY" 110 480"'
c_local _cty_haiti `""Haiti" 263 "HTI" 41 490"'
c_local _cty_hond `""Honduras" 268 "HND" 91 500"'
c_local _cty_hk `""Hong Kong" 532 "HKG" 720 ."'
c_local _cty_hung `""Hungary" 944 "HUN" 310 62"'
c_local _cty_ice `""Iceland" 176 "ISL" 395 510"'
c_local _cty_india `""India" 534 "IND" 750 520"'
c_local _cty_indo `""Indonesia" 536 "IDN" 850 530"'
c_local _cty_iran `""Iran" 429 "IRN" 630 540"'
c_local _cty_iraq `""Iraq" 433 "IRQ" 645 550"'
c_local _cty_ire `""Ireland" 178 "IRL" 205 1212"'
c_local _cty_man `""Isle Of Man" . "IMY" . ."'
c_local _cty_isr `""Israel" 436 "ISR" 666 560"'
c_local _cty_italy `""Italy" 136 "ITA" 325 570"'
c_local _cty_jamaica `""Jamaica" 343 "JAM" 51 590"'
c_local _cty_jap `""Japan" 158 "JPN" 740 600"'
c_local _cty_jordan `""Jordan" 439 "JOR" 663 610"'
c_local _cty_kazak `""Kazakhstan" 916 "KAZ" 705 615"'
c_local _cty_kenya `""Kenya" 664 "KEN" 501 620"'
c_local _cty_kirib `""Kiribati" 826 "KIR" 946 625"'
c_local _cty_kuwait `""Kuwait" 443 "KWT" 690 640"'
c_local _cty_kyrgyz `""Kyrgyz Republic" 917 "KGZ" 703 645"'
c_local _cty_laos `""Laos" 544 "LAO" 812 650"'
c_local _cty_latvia `""Latvia" 941 "LVA" 367 660"'
c_local _cty_lebanon `""Lebanon" 446 "LBN" 660 670"'
c_local _cty_leeward `""Leeward Islands" 346 "" 1063 ."'
c_local _cty_lesotho `""Lesotho" 666 "LSO" 570 680"'
c_local _cty_liberia `""Liberia" 668 "LBR" 450 690"'
c_local _cty_libya `""Libya" 672 "LBY" 620 700"'
c_local _cty_liech `""Liechtenstein" 147 "LIE" 223 705"'
c_local _cty_lith `""Lithuania" 946 "LTU" 368 710"'
c_local _cty_lux `""Luxembourg" 137 "LUX" 212 720"'
c_local _cty_macao `""Macao" 546 "MAC" 721 ."'
c_local _cty_maced `""Macedonia" 962 "MKD" 343 725"'
c_local _cty_madag `""Madagascar" 674 "MDG" 580 730"'
c_local _cty_malawi `""Malawi" 676 "MWI" 553 740"'
c_local _cty_malay `""Malaysia" 548 "MYS" 820 750"'
c_local _cty_maldives `""Maldives" 556 "MDV" 781 760"'
c_local _cty_mali `""Mali" 678 "MLI" 432 770"'
c_local _cty_malta `""Malta" 181 "MLT" 338 780"'
c_local _cty_marshall `""Marshall Islands" 867 "MHL" 983 785"'
c_local _cty_martin `""Martinique" 349 "MTQ" 66 ."'
c_local _cty_mauritania `""Mauritania" 682 "MRT" 435 790"'
c_local _cty_mauritius `""Mauritius" 684 "MUS" 590 800"'
c_local _cty_mayotte `""Mayotte" 920 "MYT" 5812 ."'
c_local _cty_mex `""Mexico" 273 "MEX" 70 810"'
c_local _cty_micro `""Micronesia" 868 "FSM" 987 812"'
c_local _cty_moldova `""Moldova" 921 "MDA" 359 813"'
c_local _cty_monaco `""Monaco" 183 "MCO" 221 815"'
c_local _cty_mong `""Mongolia" 948 "MNG" 712 820"'
c_local _cty_montserrat `""Montserrat" 351 "MSR" 59 ."'
c_local _cty_morocco `""Morocco" 686 "MAR" 600 830"'
c_local _cty_mozamb `""Mozambique" 688 "MOZ" 541 835"'
c_local _cty_myanmar `""Myanmar" 518 "MMR" 775 140"'
c_local _cty_namibia `""Namibia" 728 "NAM" 565 837"'
c_local _cty_nauru `""Nauru" 836 "NRU" 970 51"'
c_local _cty_nepal `""Nepal" 558 "NPL" 790 840"'
c_local _cty_neth `""Netherlands" 138 "NLD" 210 850"'
c_local _cty_nethantilles `""Netherlands Antilles" 353 "ANT" 68 852"'
c_local _cty_caledonia `""New Caledonia" 839 "NCL" 930 ."'
c_local _cty_nz `""New Zealand" 196 "NZL" 920 860"'
c_local _cty_nicaragua `""Nicaragua" 278 "NIC" 93 870"'
c_local _cty_niger `""Niger" 692 "NER" 436 880"'
c_local _cty_nigeria `""Nigeria" 694 "NGA" 475 890"'
c_local _cty_nkorea `""North Korea" 954 "PRK" 731 631"'
c_local _cty_mariana `""Northern Mariana Islands" . "MNP" 984 ."'
c_local _cty_norway `""Norway" 142 "NOR" 385 1091"'
c_local _cty_oman `""Oman" 449 "OMN" 698 895"'
c_local _cty_pakistan `""Pakistan" 564 "PAK" 770 900"'
c_local _cty_palau `""Palau" 565 "PLW" 986 905"'
c_local _cty_panama `""Panama" 283 "PAN" 95 910"'
c_local _cty_png `""Papua New Guinea" 853 "PNG" 910 915"'
c_local _cty_paraguay `""Paraguay" 288 "PRY" 150 920"'
c_local _cty_peru `""Peru" 293 "PER" 135 930"'
c_local _cty_phil `""Philippines" 566 "PHL" 840 940"'
c_local _cty_poland `""Poland" 964 "POL" 290 950"'
c_local _cty_port `""Portugal" 182 "PRT" 235 960"'
c_local _cty_pr `""Puerto Rico" . "PRI" 6 ."'
c_local _cty_qatar `""Qatar" 453 "QAT" 694 965"'
c_local _cty_reunion `""Reunion" 696 "REU" 585 ."'
c_local _cty_romania `""Romania" 968 "ROM" 360 970"'
c_local _cty_russia `""Russia" 922 "RUS" 365 975"'
c_local _cty_rwanda `""Rwanda" 714 "RWA" 517 980"'
c_local _cty_samoa `""Samoa" 862 "WSM" 990 1270"'
c_local _cty_marino `""San Marino" 135 "SMR" 331 982"'
c_local _cty_tome `""Sao Tome And Principe" 716 "STP" 403 985"'
c_local _cty_saudi `""Saudi Arabia" 456 "SAU" 670 990"'
c_local _cty_senegal `""Senegal" 722 "SEN" 433 1000"'
c_local _cty_serbia `""Serbia And Montenegro" 965 "SER" . ."'
c_local _cty_seychelles `""Seychelles" 718 "SYC" 591 1005"'
c_local _cty_leone `""Sierra Leone" 724 "SLE" 451 1010"'
c_local _cty_sing `""Singapore" 576 "SGP" 830 1020"'
c_local _cty_slovak `""Slovakia" 936 "SVK" 317 302"'
c_local _cty_slovenia `""Slovenia" 961 "SVN" 349 1023"'
c_local _cty_solomon `""Solomon Islands" 813 "SLB" 940 1025"'
c_local _cty_somalia `""Somalia" 726 "SOM" 520 1030"'
c_local _cty_safr `""South Africa" 199 "ZAF" 560 1040"'
c_local _cty_skor `""South Korea" 542 "KOR" 732 632"'
c_local _cty_spain `""Spain" 184 "ESP" 230 1060"'
c_local _cty_srilanka `""Sri Lanka" 524 "LKA" 780 200"'
c_local _cty_helena `""St. Helena" 856 "" 4050 ."'
c_local _cty_kitts `""St. Kitts And Nevis" 361 "KNA" 60 1063"'
c_local _cty_lucia `""St. Lucia" 362 "LCA" 56 981"'
c_local _cty_pierre `""St. Pierre And Miquelon" 363 "SPM" 1029 ."'
c_local _cty_vincent `""St. Vincent And The Grenadines" 364 "VCT" 57 1065"'
c_local _cty_sudan `""Sudan" 732 "SDN" 625 1070"'
c_local _cty_suri `""Suriname" 366 "SUR" 115 1075"'
c_local _cty_swazi `""Swaziland" 734 "SWZ" 572 1080"'
c_local _cty_sweden `""Sweden" 144 "SWE" 380 1092"'
c_local _cty_switz `""Switzerland" 146 "CHE" 225 1100"'
c_local _cty_syria `""Syria" 463 "SYR" 652 1110"'
c_local _cty_taiwan `""Taiwan" 528 "TWN" 713 231"'
c_local _cty_tajik `""Tajikistan" 923 "TJK" 702 1115"'
c_local _cty_tanz `""Tanzania" 738 "TZA" 510 1120"'
c_local _cty_thai `""Thailand" 578 "THA" 800 1130"'
c_local _cty_timor `""Timor-Leste" 579 "TMP" 860 335"'
c_local _cty_togo `""Togo" 742 "TGO" 461 1140"'
c_local _cty_tonga `""Tonga" 866 "TON" 955 1215"'
c_local _cty_trinidad `""Trinidad And Tobago" 369 "TTO" 52 1150"'
c_local _cty_tunis `""Tunisia" 744 "TUN" 616 1160"'
c_local _cty_turkey `""Turkey" 186 "TUR" 640 1170"'
c_local _cty_turkmen `""Turkmenistan" 925 "TKM" 701 1172"'
c_local _cty_turks `""Turks And Caicos" 381 "TCA" 1032 ."'
c_local _cty_tuv `""Tuvalu" 869 "TUV" 947 1175"'
c_local _cty_uganda `""Uganda" 746 "UGA" 500 1180"'
c_local _cty_ukr `""Ukraine" 926 "UKR" 369 1183"'
c_local _cty_uae `""United Arab Emirates" 466 "ARE" 696 1185"'
c_local _cty_uk `""United Kingdom" 112 "GBR" 200 1210"'
c_local _cty_us `""United States" 111 "USA" 2 1220"'
c_local _cty_uru `""Uruguay" 298 "URY" 165 1240"'
c_local _cty_ussr `""Ussr" 974 "SUN" 364 1190"'
c_local _cty_uzbek `""Uzbekistan" 927 "UZB" 704 1241"'
c_local _cty_van `""Vanuatu" 846 "VUT" 935 1243"'
c_local _cty_venez `""Venezuela" 299 "VEN" 101 1250"'
c_local _cty_vietnam `""Vietnam" 582 "VNM" 816 1260"'
c_local _cty_ukvi `""Virgin Islands, British" 372 "VGB" 1061 ."'
c_local _cty_wallis `""Wallis And Futuna" 857 "WLF" 9321 ."'
c_local _cty_gaza `""West Bank And Gaza" 487 "WBG" 665 ."'
c_local _cty_frg `""West Germany" . "FRG" 260 431"'
c_local _cty_wind `""Windward Islands" 376 "" 1055 ."'
c_local _cty_yar `""Yemen, Arab Republic" 473 "YAR" 678 1280"'
c_local _cty_ypr `""Yemen, Pdr" 459 "YPR" 680 1050"'
c_local _cty_yemen `""Yemen, Republic" 474 "YEM" 679 1285"'
c_local _cty_yugo `""Yugoslavia" 188 "YUG" 345 1290"'
c_local _cty_yugons `""Yugoslavia Ns" 966 "" . ."'
c_local _cty_zamb `""Zambia" 754 "ZMB" 551 1300"'
c_local _cty_zimb `""Zimbabwe" 698 "ZWE" 552 1214"'
c_local _cty_anguilla `""Anguilla" 312 "AIA" 1062 ."'
c_local _cty_vatican `""Vatican" . "VAT" 328 ."'
c_local _cty_monte `""Montenegro" . "MNE" 348 ."'
c_local _cty_cook `""Cook Islands" 815 "COK" 925 ."'
c_local _cty_christ `""Christmas Island" . "CXR" 9001 ."'
c_local _cty_cocos `""Cocos" . "CCK" 9002 ."'
c_local _cty_tokelau `""Tokelau" . "TKL" 9201 ."'
c_local _cty_niue `""Niue" . "NIU" 9253 ."'
c_local _cty_pitcairn `""Pitcairn" . "PCN" 9620 ."'
c_local _cty_usvi `""Virgin Islands, U.S." . "VIR" 5 ."'

end

