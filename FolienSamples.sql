/**********************************************
* Beispiel 1 : ONE ROW PER MATCH
**********************************************/

SELECT * FROM CORONAZAHLENFULDA MATCH_RECOGNIZE (
                ORDER BY MELDEDATUM
                MEASURES STRT.meldedatum AS start_day,
                         LAST(DOWN.meldedatum) AS bottom_day,
                         LAST(UP.meldedatum) AS high_day
                ONE ROW PER MATCH
                AFTER MATCH SKIP TO LAST UP
                PATTERN (STRT DOWN+ UP+)
                DEFINE DOWN AS DOWN.fallzahl < PREV(DOWN.fallzahl),
                       UP AS UP.fallzahl > PREV(UP.fallzahl)
              );


/**********************************************
* Variante zu Beispiel 1 : ONE ROW PER MATCH
**********************************************/              
SELECT * FROM CORONAZAHLENFULDA MATCH_RECOGNIZE (
                ORDER BY MELDEDATUM
                MEASURES STRT.meldedatum AS start_day,
                         DOWN.meldedatum AS bottom_day,
                         DOWN.fallzahl AS bottom_zahl,
                         UP.meldedatum AS high_day,
                         UP.fallzahl AS high_zahl
                ONE ROW PER MATCH
                AFTER MATCH SKIP TO LAST UP
                PATTERN (STRT DOWN+ UP+)
                DEFINE DOWN AS DOWN.fallzahl < PREV(DOWN.fallzahl),
                       UP AS UP.fallzahl > PREV(UP.fallzahl)
              );



/**********************************************
* Beispiel 2 : ONE ROW PER MATCH mit Partitionierung
**********************************************/              
SELECT * FROM CORZAHLENFULDAGESCHLECHT MATCH_RECOGNIZE (
    PARTITION BY geschlecht
    ORDER BY MELDEDATUM
    MEASURES STRT.meldedatum AS start_day,
             STRT.fallzahl AS start_zahl,
             DOWN.meldedatum AS bottom_day,
             DOWN.fallzahl AS bottom_zahl,
             UP.meldedatum AS high_day,
             UP.fallzahl AS high_zahl,
             round(avg(fallzahl),2) AS average
    ONE ROW PER MATCH
    AFTER MATCH SKIP TO LAST UP
    PATTERN (STRT DOWN+ UP+)
    DEFINE DOWN AS DOWN.fallzahl < PREV(DOWN.fallzahl),
           UP AS UP.fallzahl > PREV(UP.fallzahl)
    ) m ORDER BY m.start_day;
    


/**********************************************
* Beispiel 3 : ALL ROWS PER MATCH
**********************************************/    
SELECT * FROM CORONAZAHLENFULDA MATCH_RECOGNIZE (
    ORDER BY MELDEDATUM
    MEASURES MATCH_NUMBER() AS m_num,
             CLASSIFIER() AS p_var,
             STRT.meldedatum AS start_day,    
             FINAL LAST(DOWN.meldedatum) AS bottom_day,
             FINAL LAST(UP.meldedatum) AS high_day,
             RUNNING COUNT(meldedatum) AS r_days,
             FINAL COUNT(down.meldedatum) AS d_count,
             FINAL COUNT(meldedatum) AS t_count             
    ALL ROWS PER MATCH
    AFTER MATCH SKIP TO LAST UP
    PATTERN (STRT DOWN+ UP+)
    DEFINE DOWN AS DOWN.fallzahl < PREV(DOWN.fallzahl),
           UP AS UP.fallzahl > PREV(UP.fallzahl)
    ) m ORDER BY m.m_num, m.meldedatum;
    


/**********************************************
* Beispiel 4 : TOP-N
**********************************************/    
SELECT * FROM CORZAHLENFULDAGESCHLECHT MATCH_RECOGNIZE (
    PARTITION BY geschlecht
    ORDER BY fallzahl desc
    MEASURES RUNNING COUNT(*) AS r_count
    ALL ROWS PER MATCH
    -- AFTER MATCH SKIP PAST LAST ROW   -- default
    PATTERN ( ^STRT{1,4} )
    DEFINE    -- ist nicht optional
           STRT AS 1=1    -- dummy
    ) ORDER BY geschlecht;
    


/**********************************************
* Beispiel 5 : Nutzung einer Navigationsfunktion
**********************************************/
SELECT m.meldedatum, current_fallz, pre2_fallz FROM CORONAZAHLENFULDA
    MATCH_RECOGNIZE (
    ORDER BY MELDEDATUM
    MEASURES  X.fallzahl AS current_fallz,
              PREV(X.fallzahl, 2) AS pre2_fallz
    ALL ROWS PER MATCH
    PATTERN (X)
    DEFINE X AS X.fallzahl > 2 * (PREV (X.fallzahl, 2))
    ) m ORDER BY m.meldedatum;
   