*E' POSSIBILE OTTENERE I GRAFICI MOSTRATI NEL DOCUMENTO MODIFICANDO I VALORI DI VARIANZA DELLE DUE VARIABILI GENERATE;

*SIMULO LE VARIABILI SKILL E LUCK DA UNA NORMALE
E' POSSIBILE MODIFICARE LA PERCENTUALE DI LUCK CHE CONTRIBUISCE ALLA VALUTAZIONE ATTRAVERSO
LA VARIABILE PROP_LUCK: un valore ad esempio uguale a 5 esprime che in media il 5% della variabile valutazione
è formata da luck;

DATA luck;  
CALL STREAMINIT(23112024);  
do prop_luck=5 to 95 by 5;
    DO IDSAMPLE = 1 TO 1000;  /* Numero di simulazioni */
        DO id = 1 TO 100;  /* Numero di persone per simulazione */
            luck = rand("Normal",  prop_luck, (prop_luck* 1/100 ) );  /* assumo che entrambe le variabili abbiano una deviazione standard
			                                                       pari alla metà della loro media */
            skill = rand("Normal", (100 - prop_luck), ( (100 - prop_luck)* 1/100 ) ); 
            OUTPUT;  
        END;
    END;
end;
RUN;


*CREO VARIABILE VALUTAZIONE COME SOMMA DI SKILL E LUCK;
DATA luck; 
SET luck; 
valutazione=skill+luck;
RUN;


*CREO VARIABILE SELEZIONATO, CHE E' =1 PER 5 INDIVIDUI CON VALUTAZIONE PIU ALTA PER OGNI SIMULAZIONE;
/* Ordino i dati per simulazione (IDSAMPLE) e per valutazione decrescente */
PROC SORT DATA=luck; 
    BY prop_luck IDSAMPLE DESCENDING valutazione; 
RUN;
/* Creazione della variabile 'selezionato' */
DATA luck;
    SET luck;
    BY prop_luck IDSAMPLE;
 
    RETAIN rank; 
    IF FIRST.IDSAMPLE THEN rank = 0;
    rank + 1;
    IF rank <= 5 THEN selezionato = 1; 
    ELSE selezionato = 0;

    DROP rank; 
RUN;


*CREO VARIABILE SELEZIONATO_wl, CHE E' =1 PER 5 INDIVIDUI CON skill PIU ALTA PER OGNI SIMULAZIONE;
PROC SORT DATA=luck; 
    BY prop_luck IDSAMPLE DESCENDING skill; 
RUN;
/* Creazione della variabile 'selezionato_wl' */
DATA luck;
    SET luck;
    BY prop_luck IDSAMPLE;
 
    RETAIN rank; 
    IF FIRST.IDSAMPLE THEN rank = 0;
    rank + 1;
    IF rank <= 5 THEN selezionato_wl = 1; 
    ELSE selezionato_wl = 0;

    DROP rank; 
RUN;


DATA luck; 
SET luck; 
sel=selezionato+selezionato_wl;
if sel=0 then delete ;
if selezionato=0 then delete;
RUN;

proc freq data=luck;
tables prop_luck*sel / nopercent nocol ;
run;


*GRAFICO CHE MOSTRA L'ANDAMENTO DELLE PERSONE CHE VERREBBERO RISELEZIONATE IN CASO DI ASSENZA DI FORTUNA AL VARIARE
DEL PESO DELLA FORTUNA NELLA VALUTAZIONE DEI SOGGETTI;
PROC FREQ DATA=luck NOPRINT;
    TABLES prop_luck*sel / OUT=freq_table;
RUN;
*creo variabile non riselezionati in assenza di fortuna, in termini percentuali;
DATA freq_table; 
SET freq_table;
not_reselezionated=count/5000*100 ;
if sel=2 then delete;
RUN;

proc sgplot data=freq_table;
scatter x=prop_luck y=not_reselezionated;
run;



