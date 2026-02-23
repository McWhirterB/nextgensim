//INTCRAB  JOB ,'USER03',CLASS=A,MSGCLASS=X,                            00010008
//             REGION=0M,NOTIFY=&SYSUID                                 00020000
//*                                                                     00030000
//CRETOBJ  EXEC PGM=IKJEFT01,DYNAMNBR=20                                00040000
//STEPLIB  DD DISP=SHR,DSN=HL2D.SDSNEXIT                                00050000
//         DD DISP=SHR,DSN=DSN.VD10.SDSNLOAD                            00060000
//         DD DISP=SHR,DSN=DSN.VD10.RUNLIB.LOAD                         00070000
//*                                                                     00080000
//SYSPRINT DD SYSOUT=*                                                  00090000
//SYSUDUMP DD SYSOUT=*                                                  00100000
//SYSTSPRT DD SYSOUT=*                                                  00110000
//SYSTSIN  DD *                                                         00120000
  DSN SYSTEM(HL2D)                                                      00130000
   RUN  PROGRAM(DSNTEP2) -                                              00140000
          PLAN(DSNTEP2) -                                               00150000
         PARMS('/ALIGN(MID)')                                           00160000
  END                                                                   00170000
//SYSIN    DD *                                                         00180000
--                                                                      00190000
    SET CURRENT SQLID = 'USER03';                                       00200007
--                                                                      00210000
DROP DATABASE USER03DB;                                                 00220007
COMMIT;                                                                 00230001
                                                                        00240000
CREATE DATABASE   USER03DB;                                             00250007
COMMIT;                                                                 00260000
                                                                        00270000
CREATE TABLESPACE     USER03TS                                          00280007
       IN             USER03DB                                          00290007
       LOCKSIZE       ANY                                               00300000
       SEGSIZE        16                                                00310000
       CLOSE          YES                                               00320000
       COMPRESS       NO;                                               00330000
COMMIT;                                                                 00340000
                                                                        00350000
CREATE TABLE                                                            00360000
        USER03.USER03TB1                                                00370007
        (                                                               00380000
         USERNAME    CHAR(8)                                            00390007
        ,USERPASS    CHAR(8)                                            00400007
        ,BANK        INTEGER                                            00410007
        ,STRENGTH    INTEGER                                            00420007
        ,SECURITY    INTEGER                                            00421007
        ,JOB         INTEGER                                            00422007
        ,MESSAGE     INTEGER                                            00423008
       )                                                                00430000
       IN USER03DB.USER03TS;                                            00440007
                                                                        00450000
COMMIT;                                                                 00460000
/*                                                                      00470000
