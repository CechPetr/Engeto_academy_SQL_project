# Engeto_academy_SQL_project
Průvodka:

Po přečtení zadání jsem se nejprve podíval jaká data obsahují covid19_basic, 
covid19_testing a weather. V těchto tabulkách se objevuje sloupec date, jednoduchými
dotazy jsem zjistil v jakém časovém rozmezí se bude pohybovat výsledná tabulka. 

Projekt jsem začal od třetí části - počasí.
Největším problémem při tvoření jednotlivých bodů této části byli datové typy sloupců
rain a temp (text). Při operacích s nimi a následným spojováním tabulek do výsledné tabulky
pro třetí část vznikal erorr. Dokud jsem mezivýsledky ukládal jako views, tak jsem 
problémy neměl.
Výsledek pro část tři je tabluka t_project_part_3, která obsahuje sloupce city, date, avg_temp,
rain a max_gust. Přes sloupce city a date budu později spojovat další části projektu.

Dále jsem pokračoval na projektu částí dvě - proměnné specifické pro danný stát. 
Po zkušenostech z části tři, jsem na všechny číselné výsledky použil explicitní CAST na číslo s
desetinou tečkou. Jednotlivé tabulky části dvě se zdálo nejjednodušší spojit přes sloupec country,
který se vyskytoval ve všedch použitých tabulkách. Sloupec capital_city, který jsem potřeboval k
propojeni tabulek části dvě a tři jsem našel v tabulce countries. Výstupem této části byla tabulka
t_project_part_2.

Problém nastal při spojování tabulek dvě a tři do mezivýsledné tabulky. Při analýze výsledku jsem 
zjistil, že mi mizí výrazné množství dat. Po prozkoumání sloupců city z tabulky t_project_part_3
a capital_city z tabulky t_project_part_2 jsem nalezl rozdíly mezi jednotlivými názvy měst - proto
je ve skriptu i spojovací tabulka. 

Nakonec jsem vytvořil tabulku t_project_part_1 která obsahovala požadované sloupce.
Jediné zdržení nastalo při rozdělení roku podle ročních období se zahrnutím slunovratů a 
rovnodenností.
Poučen z problému při spojování tabulek z předchozích částí, i zde je spojovací tabulka tentokrát
pro státy. 

Výsledkem mého snažení je tabulka t_petr_cech_project_SQL_final ve které jsou uložena data 
srovnaná v pořadí jakém bylo požadováno a časovém rozsahu daném tabulkou covid19_basic.

