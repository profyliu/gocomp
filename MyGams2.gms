$title Grid Optimization Competition
$ontext
Base model in the SCOPF Problem Formulation: Challenge 1
$offtext

*input files
$if not set con $set con case.con
$if not set inl $set inl case.inl
$if not set raw $set raw case.raw
$if not set rop $set rop case.rop
$if not set timelimit $set timelimit 2700
$if not set ScoringMethod $set ScoringMethod 0
$if not set NetworkModel $set NetworkModel model_name

$if not set havedata $set havedata yes
$if not set firstNcont $set firstNcont 10000
$if not set ncores $set ncores 24
$if not set method $set method minlp
$if not set have_sol1_gdx $set have_sol1_gdx yes


option threads=%ncores%;
option nlp=conopt4, mip=cplex, rminlp=conopt4, minlp=dicopt;
option limrow=0,limcol=0;

set     UELORDER    /1*999997/;


* Table 4
sets
    area set of areas
*    line set of lines

    FixedBusShunt set of FixedBusShunt
    FixedBusShuntInfo /STATUS,    GL,    BL /
    businfo /BASKV,    IDE,    AREA,    ZONE,    OWNER,    VM,    VA,    NVHI,    NVLO,    EVHI,    EVLO/
    loadinfo /STATUS,    AREA,    ZONE,    PL,    QL,    IP,    IQ,    YP,    YQ,    OWNER,    SCALE,    INTRPT/
    Generatorinfo /PG,    QG,    QT,    QB,    VS,    IREG,    MBASE,    ZR,    ZX,    RT,    XT,    GTAP,    STAT,    RMPCT,    PT,    PB,    O1,    F1,    O2,    F2,    O3,    F3,    O4,    F4,    WMOD,    WPF/
    NonTransformerBranchinfo /R,    X,    B,    RATEA,    RATEB,    RATEC,    GI,    BI,    GJ,    BJ,    ST,    MET,    LEN,    O1,    F1,    O2,    F2,    O3,    F3,    O4,    F4/
    Transformerinfo /CW    ,CZ    ,CM    ,MAG1    ,MAG2    ,NMETR    ,STAT    ,O1    ,F1    ,O2    ,F2    ,O3    ,F3    ,O4    ,F4    ,R12    ,X12    ,SBASE12    ,WINDV1    ,NOMV1    ,ANG1    ,RATA1    ,RATB1    ,RATC1    ,COD1    ,CONT1    ,RMA1    ,RMI1    ,VMA1    ,VMI1    ,NTP1    ,TAB1    ,CR1    ,CX1    ,CNXA1    ,WINDV2    ,NOMV2/
    SwitchedShuntinfo /MODSW,    ADJM,    STAT,    VSWHI,    VSWLO,    SWREM,    RMPCT,    BINIT,    N1,    B1,    N2,    B2,    N3,    B3,    N4,    B4,    N5,    B5,    N6,    B6,    N7,    B7,    N8,    B8/


    transformer set of transformers
    csample set of cost function sample points
    bus set of buses
    contingency set of contingencies
*    /Label1*label2/
    csegment set of segments in the piecewise linear penalty cost function for violations (constraint relaxations)
    /cseg1*cseg3/
    load set of load IDs
    ckt set of circuit numbers
    generatorid set of generators ID
;



* Table 5
alias(area,a);
alias(transformer,f);
alias(generatorid,g);
alias(csample,h);
alias(bus,i,j,from,to);
alias(contingency,k,k0);
alias(csegment,n);

set activek(k);

sets
    line(i,j,ckt)
    xfmr(i,j,ckt)
    gen(i,g)
;

* Table 6
sets
    ak(i,a,k) contigent area of contingency k
    failArea(a,k)
    failBus(i,k)

    actline(i,i,ckt) lines active in the base case
    actxfmr(i,i,ckt) transformers active in the base case
    actlinek(i,i,ckt,k) lines active in contigency k
    actxfmrk(i,i,ckt,k) transformers active in contingency k

    actgen(i,g) generators active in the base case
    actgenk(i,g,k) generator g active in contingency k
    gkp(i,g,k) generator g participating in real power response in contingency k
*    (bus,g,i,k) generators active in contingency k and connected to bus i
    hg(i,g,h) cost function sample points for generator g

    failgenk(i,g,k)
    faillinek(i,i,ckt,k)
    failxfmrk(i,i,ckt,k)

    ia(i,a) buses in area a

    actset_pgk(i,g,k)
    actset_pgk_lq(i,g,k)
    actset_pgk_gq(i,g,k)
    actset_vik(i,k)
    actset_vik_lq(i,k)
    actset_vik_gq(i,k)

;


$ifthen %havedata% == no
*Generate data files
$call =pip install pandas
$call =python raw2xlsx4od.py %raw%
$call =python rop2xlsx4od.py %rop%
$call =python inl2xlsx4od.py %inl%
$call =python con2xlsx4od.py %con%


$call =csv2gdx CID.csv id=CID values=2..lastCol useHeader=y
$call =csv2gdx BusData.csv id=BusData index=2 values=3..lastCol useHeader=y
$call =csv2gdx LoadData.csv id=LoadData index=2..3 values=4..lastCol useHeader=y
$call =csv2gdx FixedBusShuntData.csv id=FixedBusShuntData index=2..3 values=4..lastCol useHeader=y
$call =csv2gdx GeneratorData.csv id=GeneratorData index=2..3 values=4..lastCol useHeader=y

$call =csv2gdx GeneratorData.csv id=Gen index=2..3 useHeader=y output=gen.gdx

$call =csv2gdx NonTransformerBranchData.csv id=NonTransformerBranchData index=2..4 values=5..lastCol useHeader=y

$call =csv2gdx NonTransformerBranchData.csv id=line index=2..4 useHeader=y output=line.gdx

$call =csv2gdx TransformerData.csv id=TransformerData index=2..4 values=5..lastCol useHeader=y

$call =csv2gdx TransformerData.csv id=xfmr index=2..4 useHeader=y output=xfmr.gdx

$call =csv2gdx SwitchedShuntData.csv id=SwitchedShuntData index=2 values=3..lastCol useHeader=y
$call =csv2gdx AreaData.csv id=area index=2 useHeader=y
$call =csv2gdx Areas.csv id=areas index=2..3 useHeader=y
$call =csv2gdx GeneratorDispatchUnitsData.csv id=GeneratorDispatchUnitsData index=2..4 useHeader=y
$call =csv2gdx ActivePowerDispatchTables.csv id=ActivePowerDispatchTablesData index=2..3 values=4..lastCol useHeader=y
$call =csv2gdx PiecewiseLinearCostCurve.csv id=PiecewiseLinearCostCurveData index=2..3 values=4..lastCol useHeader=y
$call =csv2gdx LTBLNPAIRS.csv id=LTBLNPAIRSData index=2 values=3..lastCol useHeader=y
$call =csv2gdx GenCostDatacombinedbyTbl.csv id=GenCostDatacombinedbyTbl index=2..4 values=5..lastCol useHeader=y

$call =csv2gdx GeneratorDispatchUnitsData.csv id=GenTbl index=2..4 useHeader=y output=GenTbl.gdx
$call =csv2gdx ActivePowerDispatchTables.csv id=TblTbl index=2..3 useHeader=y output=TblTbl.gdx
$call =csv2gdx PiecewiseLinearCostCurve.csv id=Tblh index=2..3 useHeader=y output=Tblh.gdx


$call =csv2gdx UIAGRData.csv id=UIAGRData index=2..3 values=3..lastCol useHeader=y
$call =csv2gdx ContingencyLabel.csv id=ContingencyLabel index=2 useHeader=y
$call =csv2gdx BranchOutofServiceEvent.csv id=BranchOutofServiceEvent index=2..5 useHeader=y
$call =csv2gdx GeneratorOutofServiceEvent.csv id=GeneratorOutofServiceEvent index=2..4 useHeader=y
$endif



*Load Data from RAW
parameter CID(*)
         BusData(bus,businfo)
         LoadData(Bus,load,loadinfo)
         FixedBusShuntData(Bus,FixedBusShunt,FixedBusShuntInfo)
         GeneratorData(Bus,Generatorid,Generatorinfo)
         NonTransformerBranchData(Bus,Bus,ckt,NonTransformerBranchinfo)
         TransformerData(Bus,Bus,ckt,Transformerinfo)
         SwitchedShuntData(Bus,SwitchedShuntinfo)
;
Sets
        Areas(bus,area)
;


$gdxin CID.gdx
$load CID
$gdxin

$gdxin BusData.gdx
$load Bus = Dim1
$load BusData
$gdxin

$gdxin LoadData.gdx
$load load = Dim2
$load LoadData
$gdxin

$gdxin FixedBusShuntData.gdx
$load FixedBusShunt = Dim2
$load FixedBusShuntData
$gdxin

$gdxin GeneratorData.gdx
$load Generatorid = Dim2
$load GeneratorData
$gdxin

$gdxin gen.gdx
$load gen
$gdxin

$gdxin NonTransformerBranchData.gdx
$load ckt = Dim3
$load NonTransformerBranchData
$gdxin

$gdxin line.gdx
$load line
$gdxin

$gdxin TransformerData.gdx
$load TransformerData
$gdxin

$gdxin xfmr.gdx
$load xfmr
$gdxin

$gdxin SwitchedShuntData.gdx
$load SwitchedShuntData
$gdxin

$gdxin Areas.gdx
$load area = Dim2
$load Areas
$gdxin



*Load Data from ROP
sets
    GeneratorDispatchUnitsTbl
    ActivePowerDispatchTablesTbl
    ActivePowerDispatchTablesinfo
    PiecewiseLinearCostCurveTbl
    PiecewiseLinearCostCurveNoP
    PiecewiseLinearCostCurveinfo
    LTBLNPAIRSinfo
    tbl
    GenTbl(i,g,tbl)
    Tbltbl(tbl,tbl)
    Tblh(tbl,h)
;

Set
    GeneratorDispatchUnitsData(Bus,Generatorid,Tbl)

    GenTbl(i,g,tbl)
    Tbltbl(tbl,tbl)
    Tblh(tbl,h)
;

parameter
        ActivePowerDispatchTablesData(Tbl,Tbl,ActivePowerDispatchTablesinfo)
        PiecewiseLinearCostCurveData(Tbl,csample,PiecewiseLinearCostCurveinfo)
        LTBLNPAIRSData(Tbl)

        GenCostDatacombinedbyTbl(i,g,h,*)
;

$gdxin GeneratorDispatchUnitsData.gdx
$load Tbl = Dim3
$load GeneratorDispatchUnitsData
$gdxin

$gdxin ActivePowerDispatchTables.gdx
$load ActivePowerDispatchTablesinfo = Dim3
$load ActivePowerDispatchTablesData
$gdxin

$gdxin PiecewiseLinearCostCurve.gdx
$load csample = Dim2
$load PiecewiseLinearCostCurveinfo = Dim3
$load PiecewiseLinearCostCurveData
$gdxin

$gdxin LTBLNPAIRS.gdx
$load LTBLNPAIRSData
$gdxin

$gdxin GenCostDatacombinedbyTbl.gdx
$load GenCostDatacombinedbyTbl
$gdxin

$gdxin GenTbl.gdx
$load GenTbl
$gdxin

$gdxin TblTbl.gdx
$load TblTbl
$gdxin

$gdxin Tblh.gdx
$load Tblh
$gdxin


*Load Data from INL
sets
        UIAGRinfo
;
parameter
        UIAGRData(Bus,g,UIAGRinfo)
;
$gdxin UIAGRData.gdx
$load UIAGRinfo = Dim3
$load UIAGRData
$gdxin

*Load Data from CON
sets
        ContingencyLabel
        BranchOutofServiceEvent(Bus,Bus,ckt,contingency)
        GeneratorOutofServiceEvent(Bus,g,contingency)
;

$gdxin ContingencyLabel.gdx
$load contingency=ContingencyLabel
$gdxin

$gdxin BranchOutofServiceEvent.gdx
$load BranchOutofServiceEvent
$gdxin

$gdxin GeneratorOutofServiceEvent.gdx
$load GeneratorOutofServiceEvent
$gdxin


*Read Generator Data
*if STAT = 1
actgen(i,g) = yes$(gen(i,g) and GeneratorData(i,g,'STAT') = 1);
*Line Data
*if ST = 1
actline(i,j,ckt) = yes$(line(i,j,ckt) and NonTransformerBranchData(i,j,ckt,'ST') = 1);
*Transformer Data
*if STAT = 1
actxfmr(i,j,ckt) = yes$(xfmr(i,j,ckt) and TransformerData(i,j,ckt,'STAT') = 1);




* Table 7
parameters
    p_be(i,i,ckt) line e series susceptance
    p_bech(i,i,ckt) line e total charging susceptance
    p_bf(i,i,ckt) transformer f series susceptance
    p_bfm(i,i,ckt) transformer f magnetizing susceptance
    p_bics_u(i) bus i maximum controllable shunt susceptance
    p_bics_l(i) bus i minimum controllable shunt susceptance
    p_bifs(i) bus i fixed shunt susceptance
    p_cslack the objective value of a certain easily constructed feasible solution
    p_cgh(i,g,h) generator cost of generator g at sample point h
    p_ge(i,i,ckt) line e series conductance
    p_gf(i,i,ckt) transformer f series conductance
    p_gfm(i,i,ckt) transformer f magnetizing conductance
    p_gifs(i) bus i fixed shunt conductance
    p_M a large constant used in the big-M integer programming formulation of generator real power contingency response
    p_M_l a large constant such that for any p_M > p_M_l the MIP formulation is valid
    p_Mp
    p_Mp_l
    p_Mq
    p_Mq_l
    p_Mv
    p_Mv_l
    p_pg_u(i,g) generator g real power maximum
    p_pg_l(i,g) generator g real power minimum
    p_pgh(i,g,h) real power output of generator g at sample point h
    p_piL(i) bus i constant real power load
    p_qg_u(i,g) generator g reactive power maximum
    p_qg_l(i,g) generator g reactive power minimum
    p_qiL(i) bus i constant reactive power load
    p_Re_u(i,i,ckt) line e apparent current maximum in base case
    p_ReK_u(i,i,ckt) line e apparent current maximum in contingencies
    p_s_tilde system power base MVA
    p_sf_u(i,i,ckt) transformer f apparent power maximum in base case
    p_sfK_u(i,i,ckt) transformer f apparent power maximum in contingencies
    p_vi_tilde(i) bus i voltage base kV
    p_vi_u(i) bus i voltage maximum in the base case
    p_vi_l(i) bus i voltage minimum in the base case
    p_viK_u(i) bus i voltage maximum in contingencies
    p_viK_l(i) bus i voltage minimum in contingencies
    p_alphag(i,g) participation factor of generator g in real power contingency response
    p_delta weight on base case in objective
    p_thetaf(i,i,ckt) transformer f phase angle rad
    p_lambdanP(n)
    p_lambdanQ(n)
    p_lambdanS(n)
    p_sigmaenS_u(i,i,ckt,n)
    p_sigmafnS_u(i,i,ckt,n)
    p_sigmaeknS_u(i,i,ckt,k,n)
    p_sigmafknS_u(i,i,ckt,k,n)
    p_sigmainPp_u(i,n)
    p_sigmainPn_u(i,n)
    p_sigmainQp_u(i,n)
    p_sigmainQn_u(i,n)
    p_sigmaiknPp_u(i,k,n)
    p_sigmaiknPn_u(i,k,n)
    p_sigmaiknQp_u(i,k,n)
    p_sigmaiknQn_u(i,k,n)
    p_tauf(i,i,ckt) transformer f tap ratio


    p_ai(i) area
;

* Table 8
variables
    v_biCS(i) bus i controllable shunt susceptance
    v_bikCS(i,k) bus i contingency k controllable shunt susceptance
    v_c total objective
    v_cg(i,g) generator cost of generator g
    v_csigma total constraint violation penalty in base case
    v_cksigma(k) total constraint violation penalty in contingency k
    v_ped(i,i,ckt) line e real power from destination bus into line
    v_peo(i,i,ckt) line e real power from origin bus into line
    v_pekd(i,i,ckt,k) line e contingency k real power from destination bus into line
    v_peko(i,i,ckt,k) line e contingency k real power from origin bus into line
    v_pfd(i,i,ckt) transformer f real power from destination bus into transformer
    v_pfo(i,i,ckt) transformer f real power from origin bus into transformer
    v_pfkd(i,i,ckt,k) transformer f contingency k real power from destination bus into transformer
    v_pfko(i,i,ckt,k) transformer f contingency k real power from origin bus into transformer
    v_pg(i,g) generator g real power output
    v_pgk(i,g,k) generator g contingency k real power output
    v_qed(i,i,ckt) line e reactive power from destination bus into line
    v_qeo(i,i,ckt) line e reactive power from origin bus into line
    v_qekd(i,i,ckt,k) line e contingency k reactive power from destination bus into line
    v_qeko(i,i,ckt,k) line e contingency k reactive power from origin bus into line
    v_qfd(i,i,ckt) transformer f reactive power from destination bus into transformer
    v_qfo(i,i,ckt) transformer f reactive power from origin bus into transformer
    v_qfkd(i,i,ckt,k) transformer f contingency k reactive power from destination bus into transformer
    v_qfko(i,i,ckt,k) transformer f contingency k reactive power from origin bus into transformer
    v_qg(i,g) generator g reactive power output
    v_qgk(i,g,k) generator g contingency k reactive power output
    v_tgh(i,g,h) coefficient of sample point h for generator g solution as a point on generation cost function
    v_vi(i) bus i voltage magnitude
    v_vik(i,k) bus i contingency k voltage magnitude
    v_Deltak(k) contingency k scale factor on generator participation factors definining generator real power contingency response
    v_thetai(i) bus i voltage angle
    v_thetaik(i,k) bus i contingency k voltage angle
    v_sigmaenS(i,i,ckt,n) line e apparent current rating violation for segment n in the piecewise linear penalty cost function
    v_sigmaeknS(i,i,ckt,k,n) line e contingency k apparent current rating violation for segment n in the piecewise linear penalty cost function
    v_sigmafknS(i,i,ckt,k,n) transformer f contingency k apparent power rating violation for segment n in the piecewise linear penalty cost function
    v_sigmainPp(i,n) bus i real power balance violation positive part
    v_sigmainPn(i,n) bus i real power balance violation negative part
    v_sigmainQp(i,n) bus i reactive power balance violation positive part for segment n in the piecewise linear penalty cost function
    v_sigmainQn(i,n) bus i reactive power balance violation negative part for segment n in the piecewise linear penalty cost function
    v_sigmaiknPp(i,k,n) bus i contingency k real power balance violation positive part for segment n in the piecewise linear penalty cost function
    v_sigmaiknPn(i,k,n) bus i contingency k real power balance violation negative part for segment n in the piecewise linear penalty cost function
    v_sigmaiknQp(i,k,n) bus i contingency k reactive power balance violation positive part for segment n in the piecewise linear penalty cost function
    v_sigmaiknQn(i,k,n) bus i contingency k reactive power balance violation negative part for segment n in the piecewise linear penalty cost function


;

Binary Variables
    v_xgkPp(i,g,k) generator g contingency k binary variable indicating positive slack in upper bound on real power output
    v_xgkPn(i,g,k) generator g contingency k binary variable indicating positive slack in lower bound on real power output
    v_xgkQp(i,g,k) generator g contingency k binary variable indicating positive slack in upper bound on reactive power output
    v_xgkQn(i,g,k) generator g contingency k binary variable indicating positive slack in lower bound on reactive power output
;

*Other parameters & variables


parameters
*eq20-31
    p_sigmaenSp_u(from,to,ckt,n)
    p_sigmafnSp_u(from,to,ckt,n)
;


variables

*eq6
    v_sigmafnS(i,i,ckt,n)
*eq8-19
    v_sigmaiPp(i)
    v_sigmaikPp(i,k)
    v_sigmaiPn(i)
    v_sigmaikPn(i,k)
    v_sigmaiQp(i)
    v_sigmaikQp(i,k)
    v_sigmaiQn(i)
    v_sigmaikQn(i,k)
    v_sigmaeS(i,i,ckt) soft constraint violation variables
    v_sigmaekS(from,to,ckt,k)
    v_sigmafS(from,to,ckt)
    v_sigmafkS(from,to,ckt,k)
*eq20-31
    v_sigmaenSp(from,to,ckt,n)
    v_sigmaeknSp(from,to,ckt,k,n)
    v_sigmafnSp(from,to,ckt,n)
    v_sigmafknSp(from,to,ckt,k,n)
;




*Case Identification Data from RAW
p_s_tilde = CID('SBASE');

*Bus Data
p_vi_tilde(i) = BusData(i,'BASKV');

p_ai(i) = BusData(i,'AREA');
v_vi.l(i) = BusData(i,'VM');
v_thetai.l(i) = BusData(i,'VA');
p_vi_u(i) = BusData(i,'NVHI');
p_vi_l(i) = BusData(i,'NVLO');
p_viK_u(i) = BusData(i,'EVHI');
p_viK_l(i) = BusData(i,'EVLO');

*Load Data
*?ID
*?STATUS  status, binary. 1 indicates in service, 0 out of service.
p_piL(i) = sum(load, LoadData(i,load,'PL')/p_s_tilde);
p_qiL(i) = sum(load, LoadData(i,load,'QL')/p_s_tilde);

*Fixed Bus Shunt Data
*?ID
*?STTUS
p_gifs(i) = sum(FixedBusShunt,FixedBusShuntData(i,FixedBusShunt,'GL')/p_s_tilde);
p_bifs(i) = sum(FixedBusShunt,FixedBusShuntData(i,FixedBusShunt,'BL')/p_s_tilde);

*Generator Data  g = (i,id)  ?gi(g,i) ig(i,g)
*?ID
*idg(id,g) = Generator(*);

v_pg.l(i,g) = GeneratorData(i,g,'PG')/p_s_tilde;
v_qg.l(i,g) = GeneratorData(i,g,'QG')/p_s_tilde;
p_qg_u(i,g) = GeneratorData(i,g,'QT')/p_s_tilde;
p_qg_l(i,g) = GeneratorData(i,g,'QB')/p_s_tilde;
p_pg_u(i,g) = GeneratorData(i,g,'PT')/p_s_tilde;
p_pg_l(i,g) = GeneratorData(i,g,'PB')/p_s_tilde;



*Non-Transformer Branch Data  (Line Data)

p_ge(from,to,ckt)$line(from,to,ckt) = NonTransformerBranchData(from,to,ckt,'R') / (sqr(NonTransformerBranchData(from,to,ckt,'R')) + sqr(NonTransformerBranchData(from,to,ckt,'X')));
p_be(from,to,ckt)$line(from,to,ckt) = -NonTransformerBranchData(from,to,ckt,'X') / (sqr(NonTransformerBranchData(from,to,ckt,'R')) + sqr(NonTransformerBranchData(from,to,ckt,'X')));
p_bech(from,to,ckt)$line(from,to,ckt) = NonTransformerBranchData(from,to,ckt,'B');
p_Re_u(from,to,ckt)$line(from,to,ckt) = NonTransformerBranchData(from,to,ckt,'RATEA') / p_s_tilde;
p_ReK_u(from,to,ckt)$line(from,to,ckt) = NonTransformerBranchData(from,to,ckt,'RATEC') / p_s_tilde;
*display p_s_tilde, p_ReK_u;


*Transformer Data


p_gfm(from,to,ckt)$xfmr(from,to,ckt) = TransformerData(from,to,ckt,'MAG1');
p_bfm(from,to,ckt)$xfmr(from,to,ckt) = TransformerData(from,to,ckt,'MAG2');
p_gf(from,to,ckt)$xfmr(from,to,ckt) = TransformerData(from,to,ckt,'R12') / (sqr(TransformerData(from,to,ckt,'R12')) + sqr(TransformerData(from,to,ckt,'X12')));
p_bf(from,to,ckt)$xfmr(from,to,ckt) = -TransformerData(from,to,ckt,'X12') / (sqr(TransformerData(from,to,ckt,'R12')) + sqr(TransformerData(from,to,ckt,'X12')));
p_tauf(from,to,ckt)$xfmr(from,to,ckt) = TransformerData(from,to,ckt,'WINDV1') / TransformerData(from,to,ckt,'WINDV2');

p_thetaf(from,to,ckt) = TransformerData(from,to,ckt,'ANG1') * Pi/180;
p_sf_u(from,to,ckt) = TransformerData(from,to,ckt,'RATA1') / p_s_tilde;
p_sfK_u(from,to,ckt) = TransformerData(from,to,ckt,'RATC1') / p_s_tilde;



*Switched Shunt Data

v_biCS.l(i) =  SwitchedShuntData(i,'BINIT') / p_s_tilde;
p_bics_u(i) = 0;
p_bics_l(i) = 0;

set BLindex /BL1*BL8/;
alias(BLindex,BLindex1);
parameter BL(BLindex);
scalar NBL;
loop(i,
    BL('BL1') = SwitchedShuntData(i,'N1')*SwitchedShuntData(i,'B1');
    BL('BL2') = SwitchedShuntData(i,'N2')*SwitchedShuntData(i,'B2');
    BL('BL3') = SwitchedShuntData(i,'N3')*SwitchedShuntData(i,'B3');
    BL('BL4') = SwitchedShuntData(i,'N4')*SwitchedShuntData(i,'B4');
    BL('BL5') = SwitchedShuntData(i,'N5')*SwitchedShuntData(i,'B5');
    BL('BL6') = SwitchedShuntData(i,'N6')*SwitchedShuntData(i,'B6');
    BL('BL7') = SwitchedShuntData(i,'N7')*SwitchedShuntData(i,'B7');
    BL('BL8') = SwitchedShuntData(i,'N8')*SwitchedShuntData(i,'B8');
*    display BL;
    NBL = 0;
    loop(BLindex,
        if(smin(BLindex1$(ord(BLindex1) <= ord(BLindex)), abs(BL(BLindex1))) > 0,
            NBL = ord(BLindex);
        else
            break;
        );
    );
*    NBL = smax(BLindex$(ord(BLindex1) <= ord(BLindex) and BL(BLindex1) ne 0), ord(BLindex));
*    NBL = smax(BLindex$(BL(BLindex) ne 0), ord(BLindex));
*    display NBL;
    p_bics_u(i) = sum(BLindex$(ord(BLindex) <= NBL), max(0, BL(BLindex)));
    p_bics_l(i) = sum(BLindex$(ord(BLindex) <= NBL), min(0, BL(BLindex)));
*    display p_bics_u;
);


*Generator Cost Data from ROP
loop(tbl,
    hg(i,g,h)$(GenTbl(i,g,tbl) and Tblh(tbl,h) and Tbltbl(tbl,tbl))=yes;
);
$ontext
loop(tbl,
    p_pgh(i,g,h)$hg(i,g,h) = PiecewiseLinearCostCurveData(tbl,h,'XI')$(GenTbl(i,g,tbl)) / p_s_tilde;
);
loop(tbl,
    p_cgh(i,g,h)$hg(i,g,h) = PiecewiseLinearCostCurveData(tbl,h,'YI')$(GenTbl(i,g,tbl));
);
$offtext

p_pgh(i,g,h)$hg(i,g,h) = GenCostDatacombinedbyTbl(i,g,h,'XI') / p_s_tilde;
p_cgh(i,g,h)$hg(i,g,h) = GenCostDatacombinedbyTbl(i,g,h,'YI');

*display p_pgh, tbl;

*Participation Factor Data from INL
p_alphag(i,g) = UIAGRData(i,g,"R");






*Constraint Violation Penalty Parameters

p_delta = 1/2;

parameters
    p_PViolMaxn(n)
    /   cseg1 2
        cseg2 50
        cseg3 inf /
    p_QViolMaxn(n)
    /   cseg1 2
        cseg2 50
        cseg3 inf /
    p_SViolMaxn(n)
    /   cseg1 2
        cseg2 50
        cseg3 inf /
    p_PViolCostn(n)
    /   cseg1 1e3
        cseg2 5e3
        cseg3 1e6 /
    p_QViolCostn(n)
    /   cseg1 1e3
        cseg2 5e3
        cseg3 1e6 /
    p_SViolCostn(n)
    /   cseg1 1e3
        cseg2 5e3
        cseg3 1e6 /
;

p_lambdanP(n) =  p_PViolCostn(n)* p_s_tilde;
p_lambdanQ(n) =  p_QViolCostn(n)* p_s_tilde;
p_lambdanS(n) =  p_SViolCostn(n)* p_s_tilde;
p_sigmaenS_u(from,to,ckt,n)$actline(from,to,ckt) =  p_SViolMaxn(n)/p_s_tilde;
p_sigmafnS_u(from,to,ckt,n)$xfmr(from,to,ckt) =  p_SViolMaxn(n)/p_s_tilde;
p_sigmainPp_u(i,n) =  p_PViolMaxn(n)/ p_s_tilde;
p_sigmainPn_u(i,n) =  p_PViolMaxn(n)/ p_s_tilde;
p_sigmainQp_u(i,n) =  p_QViolMaxn(n)/ p_s_tilde;
p_sigmainQn_u(i,n) =  p_QViolMaxn(n)/ p_s_tilde;





*p71
v_vi.l(i) = (p_vi_u(i)+p_vi_l(i))/2;
v_pg.l(i,g) = (p_pg_u(i,g)+p_pg_l(i,g))/2;
v_qg.l(i,g) = (p_qg_u(i,g)+p_qg_l(i,g))/2;
v_bics.l(i) = 0;





*eq_4
v_tgh.lo(i,g,h)$hg(i,g,h) = 0;


*20
v_sigmainPp.lo(i,n) = 0;
v_sigmainPp.up(i,n) = p_sigmainPp_u(i,n);

*22
v_sigmainPn.lo(i,n) = 0;
v_sigmainPn.up(i,n) = p_sigmainPn_u(i,n);

*24
v_sigmainQp.lo(i,n) = 0;
v_sigmainQp.up(i,n) = p_sigmainQp_u(i,n);

*26
v_sigmainQn.lo(i,n) = 0;
v_sigmainQn.up(i,n) = p_sigmainQn_u(i,n);

*28     p_sigmaenSp_u->p_sigmaenS_u      v_sigmaenSp -> v_sigmaenS
v_sigmaenS.lo(from,to,ckt,n)$actline(from,to,ckt) = 0;
v_sigmaenS.up(from,to,ckt,n)$actline(from,to,ckt) = p_sigmaenS_u(from,to,ckt,n);

*30     p_sigmafnSp_u->p_sigmafnS_u             v_sigmafnSp -> v_sigmafnS
v_sigmafnS.lo(from,to,ckt,n)$actxfmr(from,to,ckt) = 0;
v_sigmafnS.up(from,to,ckt,n)$actxfmr(from,to,ckt) = p_sigmafnS_u(from,to,ckt,n);



*Primary Optimization Variable Bounds in the Base Case

*32
v_vi.lo(i) = p_vi_l(i);
v_vi.up(i) = p_vi_u(i);
*33
v_pg.lo(i,g)$actgen(i,g) = p_pg_l(i,g);
v_pg.up(i,g)$actgen(i,g) = p_pg_u(i,g);
*34
v_pg.fx(i,g)$(not actgen(i,g)) = 0;
*35
v_qg.lo(i,g)$actgen(i,g) = p_qg_l(i,g);
v_qg.up(i,g)$actgen(i,g) = p_qg_u(i,g);
*36
v_qg.fx(i,g)$(not actgen(i,g)) = 0;
*37
v_biCS.lo(i) = p_bics_l(i);
v_biCS.up(i) = p_bics_u(i);

* Artificial bounds for theta
v_thetai.lo(i) = -pi/3;
v_thetai.up(i) = pi/3;

*47
v_sigmaiPp.lo(i) = 0;
*48
v_sigmaiPn.lo(i) = 0;

*50
v_sigmaiQp.lo(i) = 0;
*51
v_sigmaiQn.lo(i) = 0;

*53 ? line?
v_sigmaeS.lo(from,to,ckt)$actline(from,to,ckt) = 0;

*56
v_sigmafS.lo(from,to,ckt)$actxfmr(from,to,ckt) = 0;





p_Mv = max(smax(i, p_vi_u(i)) - smin(i, p_viK_l(i)), smax(i, p_viK_u(i)) - smin(i, p_vi_l(i)));
p_Mq = smax((i,g),  p_qg_u(i,g)) - smin((i,g), p_qg_l(i,g));
p_Mp = smax((i,g),  p_pg_u(i,g)) - smin((i,g), p_pg_l(i,g));
*?
p_M = p_Mp+1;

*display p_MV, p_Mq, p_Mp, p_M;





equations
    eq_1_objfun
    eq_1_objfun_base_only
    eq_2(i,g) Generator real power cost definition
    eq_3(i,g) Generator real power output interpolation to sample points

    eq_5(i,g) Generator cost interpolation coefficient normalization
    eq_6  The penalties in the base case
    eq_7(k)  The penalties in contingencyies
    eq_8(i)  Bounds on violation variables for each segment
    eq_9(i,k)
    eq_10(i)
    eq_11(i,k)
    eq_12(i)
    eq_13(i,k)
    eq_14(i)
    eq_15(i,k)
    eq_16(i,i,ckt)
    eq_17(i,i,ckt,k)
    eq_18(i,i,ckt)
    eq_19(i,i,ckt,k)

*Line Flow Definitions in the Base Case
    eq_38(i,i,ckt)  Real power flows into a line at the origin buses in the base case
    eq_39(i,i,ckt)  Reactive power flows into a line at the origin buses in the base case
    eq_40(i,i,ckt)  Real power flows into a line at the destination buses in the base case
    eq_41(i,i,ckt)  Reactive power flows into a line at the destination buses in the base case
*Transformer Flow Definitions in the Base Case
    eq_42(i,i,ckt)  Real power flows into a transformer at the origin buses in the base case
    eq_43(i,i,ckt)  Reactive power flows into a transformer at the origin buses in the base case
    eq_44(i,i,ckt)  Real  power flows into a transformer at the destination buses in the base case
    eq_45(i,i,ckt)  Reactive  power flows into a transformer at the destination buses in the base case
*Bus Power Balance Constraints in the Base Case
    eq_46(i)  Bus real power balance constraints
*    eq_47(i)
*    eq_48(i)
    eq_49(i)  Bus reactive power balance constraints
*    eq_50(i)
*    eq_51(i)
*Line Current Ratings in the Base Case
    eq_52(i,i,ckt)  Line current ratings in the base case at the origin bus
*    eq_53(i,i,ckt)
    eq_54(i,i,ckt)  Line current ratings in the base case at the destination bus
*Transformer Power Ratings in the Base Case
    eq_55(i,i,ckt)  at the origin bus
*    eq_56(i,i,ckt)
    eq_57(i,i,ckt)  at the destination bus
*Primary Optimization Variable Bounds in Contingencies

*    eq_58(i)  Bounds on voltage in each contingency
*    eq_59(k,i,g)  Bounds on real power generation
*    eq_60(k,i,g)  No real power is produced by generators that are not active in each contingency
*    eq_61(k,i,g)  Bounds on reactive power generation in each contingency
*    eq_62(k,i,g)  No reactive power is produced by generators that are not active in each contingency
*    eq_63(k,i)  Bounds on shunt susceptance in each contingency



*Line Flow Definitions in Contingencies
    eq_64(i,i,ckt,k)  Real power flows into a line at the origin bus each contingency
    eq_65(i,i,ckt,k)  Reactive power flows into a line at the origin bus each contingency
    eq_66(i,i,ckt,k)  Real power flows into a line at the destination bus in each contingency
    eq_67(i,i,ckt,k)  Reactive power flows into a line at the destination bus in each contingency
*Transformer Flow Definitions in Contingencies
    eq_68(i,i,ckt,k)  Real power flows into a transformer at the origin bus in each contingency
    eq_69(i,i,ckt,k)  Reactive power flows into a transformer at the origin bus in each contingency
    eq_70(i,i,ckt,k)  Real power flows into a transformer at the destination bus in each contingency
    eq_71(i,i,ckt,k)  Reactive power flows into a transformer at the destination bus in each contingency


*Bus Power Balance Constraints in Contingencies
    eq_72(i,k)  Bus real power balance constraints in each contingency
*    eq_73(k,i)
*    eq_74(k,i)
    eq_75(i,k)  Bus reactive power balance constraints in each contingency
*    eq_76(k,i)
*    eq_77(k,i)
*Line Current Ratings in Contingencies
    eq_78(i,i,ckt,k)  Line current ratings at the origin bus in each contingency
*    eq_79(k,i,i,ckt)
    eq_80(i,i,ckt,k)  Line current ratings at the destination bus in each contingency
*Transformer Power Ratings in Contingencies
    eq_81(i,i,ckt,k)  at the origin bus with soft constraint violation
*    eq_82(k,i,i,ckt)
    eq_83(i,i,ckt,k)  at the destination bus with soft constraint violation
*Generator Real Power Contingency Response
    eq_84(i,g,k)

    eq_85_1(i,g,k)
    eq_85_2(i,g,k)
    eq_85_3(i,g,k)

*Mixed Integer Programming Formulation
*    eq_87(k,i,g)
*    eq_88(k,i,g)
    eq_89(i,g,k)
    eq_90(i,g,k)
    eq_91(i,g,k)
    eq_92(i,g,k)
*Generator Reactive Power Contingency Response

    eq_93_1(i,g,k)
    eq_93_2(i,g,k)
    eq_93_3(i,g,k)

    eq_98(i,g,k)
    eq_99(i,g,k)
    eq_100(i,g,k)
    eq_101(i,g,k)


;

eq_1_objfun..
    v_c =e= sum((i,g)$actgen(i,g), v_cg(i,g)) + p_delta*v_csigma + (1-p_delta)/card(k)*sum(k$activek(k),v_cksigma(k));

eq_1_objfun_base_only..
    v_c =e= sum((i,g)$actgen(i,g), v_cg(i,g)) + p_delta*v_csigma;

eq_2(i,g)$actgen(i,g)..
    v_cg(i,g) =e= sum(h$hg(i,g,h), p_cgh(i,g,h)*v_tgh(i,g,h));

eq_3(i,g)$actgen(i,g)..
    sum(h$hg(i,g,h), p_pgh(i,g,h)*v_tgh(i,g,h)) =e= v_pg(i,g);



eq_5(i,g)$actgen(i,g)..
    sum(h$hg(i,g,h), v_tgh(i,g,h)) =e= 1;

eq_6..
    v_csigma =e= sum(n, (p_lambdanP(n)*sum(i, v_sigmainPp(i,n)+v_sigmainPn(i,n)) + p_lambdanQ(n)*sum(i, v_sigmainQp(i,n)+v_sigmainQn(i,n)) + p_lambdanS(n)*sum((from,to,ckt)$actline(from,to,ckt), v_sigmaenS(from,to,ckt,n)) + p_lambdanS(n)*sum((from,to,ckt)$actxfmr(from,to,ckt), v_sigmafnS(from,to,ckt,n))));


eq_7(k)$activek(k)..
    v_cksigma(k) =e= sum(n, (p_lambdanP(n)*sum(i, v_sigmaiknPp(i,k,n)+v_sigmaiknPn(i,k,n)) + p_lambdanQ(n)*sum(i, v_sigmaiknQp(i,k,n)+v_sigmaiknQn(i,k,n)) + p_lambdanS(n)*sum((from,to,ckt)$actlinek(from,to,ckt,k), v_sigmaeknS(from,to,ckt,k,n)) + p_lambdanS(n)*sum((from,to,ckt)$actxfmrk(from,to,ckt,k), v_sigmafknS(from,to,ckt,k,n))));


eq_8(i)..
    v_sigmaiPp(i) =e= sum(n, v_sigmainPp(i,n));

*? v_sigmaikPp(i,k) not defined
eq_9(i,k)$activek(k)..
    v_sigmaikPp(i,k) =e= sum(n, v_sigmaiknPp(i,k,n));

*? v_sigmaiPn(i) not defined
eq_10(i)..
    v_sigmaiPn(i) =e= sum(n, v_sigmainPn(i,n));

*? v_sigmaikPn(i,k) not defined
eq_11(i,k)$activek(k)..
    v_sigmaikPn(i,k) =e= sum(n, v_sigmaiknPn(i,k,n));

eq_12(i)..
    v_sigmaiQp(i) =e= sum(n, v_sigmainQp(i,n));

eq_13(i,k)$activek(k)..
    v_sigmaikQp(i,k) =e= sum(n, v_sigmaiknQp(i,k,n));

eq_14(i)..
    v_sigmaiQn(i) =e= sum(n, v_sigmainQn(i,n));

eq_15(i,k)$activek(k)..
    v_sigmaikQn(i,k) =e= sum(n, v_sigmaiknQn(i,k,n));

eq_16(from,to,ckt)$actline(from,to,ckt)..
    v_sigmaeS(from,to,ckt) =e= sum(n, v_sigmaenS(from,to,ckt,n));

*should be ekn
eq_17(from,to,ckt,k)$(actline(from,to,ckt) and activek(k))..
    v_sigmaekS(from,to,ckt,k) =e= sum(n, v_sigmaeknS(from,to,ckt,k,n));

eq_18(from,to,ckt)$actxfmr(from,to,ckt)..
    v_sigmafS(from,to,ckt) =e= sum(n, v_sigmafnS(from,to,ckt,n));

*should be fkn
eq_19(from,to,ckt,k)$(actxfmr(from,to,ckt) and activek(k))..
    v_sigmafkS(from,to,ckt,k) =e= sum(n, v_sigmafknS(from,to,ckt,k,n));



* Line Flow Definitions in the Base Case
*38
eq_38(from,to,ckt)$actline(from,to,ckt)..
    v_peo(from,to,ckt) =e=  p_ge(from,to,ckt)*sqr(v_vi(from)) + (-p_ge(from,to,ckt)*cos(v_thetai(from) - v_thetai(to)) - p_be(from,to,ckt)*sin(v_thetai(from) - v_thetai(to)))*v_vi(from)*v_vi(to);

*39
eq_39(from,to,ckt)$actline(from,to,ckt)..
    v_qeo(from,to,ckt) =e= -(p_be(from,to,ckt) + p_bech(from,to,ckt)/2)*sqr(v_vi(from)) + (p_be(from,to,ckt)*cos(v_thetai(from) - v_thetai(to)) - p_ge(from,to,ckt)*sin(v_thetai(from) - v_thetai(to)))*v_vi(from)*v_vi(to);

*40
eq_40(from,to,ckt)$actline(from,to,ckt)..
    v_ped(from,to,ckt) =e=  p_ge(from,to,ckt)*sqr(v_vi(to)) + (-p_ge(from,to,ckt)*cos(v_thetai(to) - v_thetai(from)) - p_be(from,to,ckt)*sin(v_thetai(to) - v_thetai(from)))*v_vi(from)*v_vi(to);

*41
eq_41(from,to,ckt)$actline(from,to,ckt)..
    v_qed(from,to,ckt) =e= -(p_be(from,to,ckt) + p_bech(from,to,ckt)/2)*sqr(v_vi(to)) + (p_be(from,to,ckt)*cos(v_thetai(to) - v_thetai(from)) - p_ge(from,to,ckt)*sin(v_thetai(to) - v_thetai(from)))*v_vi(from)*v_vi(to);


*Transformer Flow Definitions in the Base Case

*42
eq_42(from,to,ckt)$actxfmr(from,to,ckt)..
    v_pfo(from,to,ckt) =e= (p_gf(from,to,ckt)/sqr(p_tauf(from,to,ckt))+p_gfm(from,to,ckt))*sqr(v_vi(from)) + (-p_gf(from,to,ckt)/p_tauf(from,to,ckt)*cos(v_thetai(from)-v_thetai(to)-p_thetaf(from,to,ckt)) - p_bf(from,to,ckt)/p_tauf(from,to,ckt)*sin(v_thetai(from)-v_thetai(to)-p_thetaf(from,to,ckt)))*v_vi(from)*v_vi(to);

*43
eq_43(from,to,ckt)$actxfmr(from,to,ckt)..
    v_qfo(from,to,ckt) =e= -(p_bf(from,to,ckt)/sqr(p_tauf(from,to,ckt))+p_bfm(from,to,ckt))*sqr(v_vi(from)) + (p_bf(from,to,ckt)/p_tauf(from,to,ckt)*cos(v_thetai(from)-v_thetai(to)-p_thetaf(from,to,ckt)) - p_gf(from,to,ckt)/p_tauf(from,to,ckt)*sin(v_thetai(from)-v_thetai(to)-p_thetaf(from,to,ckt)))*v_vi(from)*v_vi(to);

*44
eq_44(from,to,ckt)$actxfmr(from,to,ckt)..
    v_pfd(from,to,ckt) =e= p_gf(from,to,ckt)*sqr(v_vi(to)) + (-p_gf(from,to,ckt)/p_tauf(from,to,ckt)*cos(v_thetai(to)-v_thetai(from)+p_thetaf(from,to,ckt)) - p_bf(from,to,ckt)/p_tauf(from,to,ckt)*sin(v_thetai(to)-v_thetai(from)+p_thetaf(from,to,ckt)))*v_vi(from)*v_vi(to);

*45
eq_45(from,to,ckt)$actxfmr(from,to,ckt)..
    v_qfd(from,to,ckt) =e= -p_bf(from,to,ckt)*sqr(v_vi(to)) + (p_bf(from,to,ckt)/p_tauf(from,to,ckt)*cos(v_thetai(to)-v_thetai(from)+p_thetaf(from,to,ckt)) - p_gf(from,to,ckt)/p_tauf(from,to,ckt)*sin(v_thetai(to)-v_thetai(from)+p_thetaf(from,to,ckt)))*v_vi(from)*v_vi(to);

*Bus Power Balance Constraints in the Base Case

*46 v_sigmaiPp(i)  v_sigmaiPn(i)  defined in 8 10   ?  set is under control already
eq_46(i)..
    sum((g)$actgen(i,g), v_pg(i,g)) -p_piL(i)-p_giFS(i)*sqr(v_vi(i)) - sum((to,ckt)$actline(i,to,ckt), v_peo(i,to,ckt)) - sum((from,ckt)$actline(from,i,ckt), v_ped(from,i,ckt)) - sum((to,ckt)$actxfmr(i,to,ckt), v_pfo(i,to,ckt)) - sum((from,ckt)$(actxfmr(from,i,ckt)), v_pfd(from,i,ckt)) =e=  v_sigmaiPp(i) - v_sigmaiPn(i);


*49 v_sigmaiQp(i)  v_sigmaiQn(i) defined in 12 14  ? set is under control already
eq_49(i)..
    sum((g)$actgen(i,g), v_qg(i,g))-p_qiL(i)-(-p_bifs(i)-v_biCS(i))*sqr(v_vi(i)) - sum((to,ckt)$actline(i,to,ckt), v_qeo(i,to,ckt)) - sum((from,ckt)$actline(from,i,ckt), v_qed(from,i,ckt)) - sum((to,ckt)$actxfmr(i,to,ckt), v_qfo(i,to,ckt)) - sum((from,ckt)$(actxfmr(from,i,ckt)), v_qfd(from,i,ckt)) =e=  v_sigmaiQp(i) - v_sigmaiQn(i);


*Line Current Ratings in the Base Case
*52   v_sigmaeS(e) defined in 16
eq_52(from,to,ckt)$actline(from,to,ckt)..
    sqr(v_peo(from,to,ckt))+sqr(v_qeo(from,to,ckt)) =l= sqr(p_Re_u(from,to,ckt)*v_vi(from) + v_sigmaeS(from,to,ckt));

*54
eq_54(from,to,ckt)$actline(from,to,ckt)..
    sqr(v_ped(from,to,ckt))+sqr(v_qed(from,to,ckt)) =l= sqr(p_Re_u(from,to,ckt)*v_vi(to) + v_sigmaeS(from,to,ckt));

*Transformer Power Ratings in the Base Case
*55 v_sigmafS(f) defined in 18
eq_55(from,to,ckt)$actxfmr(from,to,ckt)..
    sqr(v_pfo(from,to,ckt))+sqr(v_qfo(from,to,ckt)) =l= sqr(p_sf_u(from,to,ckt) + v_sigmafS(from,to,ckt));

*57 v_sigmafS(f) defined in 18
eq_57(from,to,ckt)$actxfmr(from,to,ckt)..
    sqr(v_pfd(from,to,ckt))+sqr(v_qfd(from,to,ckt)) =l= sqr(p_sf_u(from,to,ckt) + v_sigmafS(from,to,ckt));


*Line Flow Definitions in Contingencies ?  actlinek(from,to,ckt,k))

*64 ?
eq_64(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    v_peko(from,to,ckt,k) =e= p_ge(from,to,ckt)*sqr(v_vik(from,k)) + (-p_ge(from,to,ckt)*cos(v_thetaik(from,k) - v_thetaik(to,k)) - p_be(from,to,ckt)*sin(v_thetaik(from,k) - v_thetaik(to,k)))*v_vik(from,k)*v_vik(to,k);

*65 ?
eq_65(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    v_qeko(from,to,ckt,k) =e= -(p_be(from,to,ckt) + p_bech(from,to,ckt)/2)*sqr(v_vik(from,k)) + (p_be(from,to,ckt)*cos(v_thetaik(from,k) - v_thetaik(to,k)) - p_ge(from,to,ckt)*sin(v_thetaik(from,k) - v_thetaik(to,k)))*v_vik(from,k)*v_vik(to,k);

*66 ?
eq_66(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    v_pekd(from,to,ckt,k) =e=  p_ge(from,to,ckt)*sqr(v_vik(to,k)) + (-p_ge(from,to,ckt)*cos(v_thetaik(to,k) - v_thetaik(from,k)) - p_be(from,to,ckt)*sin(v_thetaik(to,k) - v_thetaik(from,k)))*v_vik(from,k)*v_vik(to,k);

*67 ?
eq_67(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    v_qekd(from,to,ckt,k) =e= -(p_be(from,to,ckt) + p_bech(from,to,ckt)/2)*sqr(v_vik(to,k)) + (p_be(from,to,ckt)*cos(v_thetaik(to,k) - v_thetaik(from,k)) - p_ge(from,to,ckt)*sin(v_thetaik(to,k) - v_thetaik(from,k)))*v_vik(from,k)*v_vik(to,k);


*Transformer Flow Definitions in Contingencies  ?  actxfmrk(from,to,ckt,k))

*68 ?
eq_68(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
    v_pfko(from,to,ckt,k) =e= (p_gf(from,to,ckt)/sqr(p_tauf(from,to,ckt))+p_gfm(from,to,ckt))*sqr(v_vik(from,k)) + (-p_gf(from,to,ckt)/p_tauf(from,to,ckt)*cos(v_thetaik(from,k)-v_thetaik(to,k)-p_thetaf(from,to,ckt)) - p_bf(from,to,ckt)/p_tauf(from,to,ckt)*sin(v_thetaik(from,k)-v_thetaik(to,k)-p_thetaf(from,to,ckt)))*v_vik(from,k)*v_vik(to,k);

*69
eq_69(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
    v_qfko(from,to,ckt,k) =e= -(p_bf(from,to,ckt)/sqr(p_tauf(from,to,ckt))+p_bfm(from,to,ckt))*sqr(v_vik(from,k)) + (p_bf(from,to,ckt)/p_tauf(from,to,ckt)*cos(v_thetaik(from,k)-v_thetaik(to,k)-p_thetaf(from,to,ckt)) - p_gf(from,to,ckt)/p_tauf(from,to,ckt)*sin(v_thetaik(from,k)-v_thetaik(to,k)-p_thetaf(from,to,ckt)))*v_vik(from,k)*v_vik(to,k);

*70
eq_70(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
    v_pfkd(from,to,ckt,k) =e= p_gf(from,to,ckt)*sqr(v_vik(to,k)) + (-p_gf(from,to,ckt)/p_tauf(from,to,ckt)*cos(v_thetaik(to,k)-v_thetaik(from,k)+p_thetaf(from,to,ckt)) - p_bf(from,to,ckt)/p_tauf(from,to,ckt)*sin(v_thetaik(to,k)-v_thetaik(from,k)+p_thetaf(from,to,ckt)))*v_vik(from,k)*v_vik(to,k);

*71
eq_71(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
    v_qfkd(from,to,ckt,k) =e= -p_bf(from,to,ckt)*sqr(v_vik(to,k)) + (p_bf(from,to,ckt)/p_tauf(from,to,ckt)*cos(v_thetaik(to,k)-v_thetaik(from,k)+p_thetaf(from,to,ckt)) - p_gf(from,to,ckt)/p_tauf(from,to,ckt)*sin(v_thetaik(to,k)-v_thetaik(from,k)+p_thetaf(from,to,ckt)))*v_vik(from,k)*v_vik(to,k);


*Bus Power Balance Constraints in Contingencies

*72
eq_72(i,k)$activek(k)..
    sum((g)$actgenk(i,g,k), v_pgk(i,g,k)) -p_piL(i)-p_giFS(i)*sqr(v_vik(i,k)) - sum((to,ckt)$actlinek(i,to,ckt,k), v_peko(i,to,ckt,k)) - sum((from,ckt)$actlinek(from,i,ckt,k), v_pekd(from,i,ckt,k)) - sum((to,ckt)$actxfmrk(i,to,ckt,k), v_pfko(i,to,ckt,k)) - sum((from,ckt)$(actxfmrk(from,i,ckt,k)), v_pfkd(from,i,ckt,k)) =e=  v_sigmaikPp(i,k) - v_sigmaikPn(i,k);


*75
eq_75(i,k)$activek(k)..
    sum((g)$actgenk(i,g,k), v_qgk(i,g,k)) -p_qiL(i)-(-p_bifs(i)-v_bikCS(i,k))*sqr(v_vik(i,k)) - sum((to,ckt)$actlinek(i,to,ckt,k), v_qeko(i,to,ckt,k)) - sum((from,ckt)$actlinek(from,i,ckt,k), v_qekd(from,i,ckt,k)) - sum((to,ckt)$actxfmrk(i,to,ckt,k), v_qfko(i,to,ckt,k)) - sum((from,ckt)$(actxfmrk(from,i,ckt,k)), v_qfkd(from,i,ckt,k)) =e=  v_sigmaikQp(i,k) - v_sigmaikQn(i,k);



*Line Current Ratings in Contingencies

*78
eq_78(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    sqr(v_peko(from,to,ckt,k))+sqr(v_qeko(from,to,ckt,k)) =l= sqr(p_ReK_u(from,to,ckt)*v_vik(from,k) + v_sigmaekS(from,to,ckt,k));


*80
eq_80(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    sqr(v_pekd(from,to,ckt,k))+sqr(v_qekd(from,to,ckt,k)) =l= sqr(p_ReK_u(from,to,ckt)*v_vik(to,k) + v_sigmaekS(from,to,ckt,k));

*Transformer Power Ratings in Contingencies

*81
eq_81(from,to,ckt,k)$(actxfmr(from,to,ckt) and actxfmrk(from,to,ckt,k) and activek(k))..
    sqr(v_pfko(from,to,ckt,k))+sqr(v_qfko(from,to,ckt,k)) =l= sqr(p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k));


*83
eq_83(from,to,ckt,k)$(actxfmr(from,to,ckt) and actxfmrk(from,to,ckt,k) and activek(k))..
    sqr(v_pfkd(from,to,ckt,k))+sqr(v_qfkd(from,to,ckt,k)) =l= sqr(p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k));

*Generator Real Power Contingency Response

*84
eq_84(i,g,k)$(actgenk(i,g,k) and (not gkp(i,g,k)) and activek(k))..
    v_pgk(i,g,k) =e= v_pg(i,g);



*89
eq_89(i,g,k)$(gkp(i,g,k) and activek(k))..
    p_pg_u(i,g) - v_pgk(i,g,k) =l= p_Mp*v_xgkPp(i,g,k);

*90
eq_90(i,g,k)$(gkp(i,g,k) and activek(k))..
    v_pgk(i,g,k) - p_pg_l(i,g) =l= p_Mp*v_xgkPn(i,g,k);

*91
eq_91(i,g,k)$(gkp(i,g,k) and activek(k))..
    v_pg(i,g) + p_alphag(i,g)*v_deltak(k) - v_pgk(i,g,k) =l= p_M*(1-v_xgkPp(i,g,k));


*92
eq_92(i,g,k)$(gkp(i,g,k) and activek(k))..
    v_pgk(i,g,k) - v_pg(i,g) - p_alphag(i,g)*v_deltak(k) =l= p_M*(1-v_xgkPn(i,g,k));

*Generator Reactive Power Contingency Response


*98 i g k
eq_98(i,g,k)$(actgenk(i,g,k) and activek(k))..
    p_qg_u(i,g) - v_qgk(i,g,k) =l= p_Mq*v_xgkQp(i,g,k);

*99
eq_99(i,g,k)$(actgenk(i,g,k) and activek(k))..
    v_qgk(i,g,k) - p_qg_l(i,g) =l= p_Mq*v_xgkQn(i,g,k);

*100
eq_100(i,g,k)$(actgenk(i,g,k) and activek(k))..
    v_vi(i) - v_vik(i,k) =l= p_Mv*(1-v_xgkQp(i,g,k));

*101
eq_101(i,g,k)$(actgenk(i,g,k) and activek(k))..
    v_vik(i,k) - v_vi(i) =l= p_Mv*(1-v_xgkQn(i,g,k));


parameter
    p_pg(i,g)
    p_vi(i)
    p_qg(i,g)
    p_thetai(i)
    p_bics(i)

    p_sigmaekS_this(from,to,ckt)
    p_sigmafkS_this(from,to,ckt)

    p_xgkPp(i,g,k)
    p_xgkPn(i,g,k)
    p_xgkQp(i,g,k)
    p_xgkQn(i,g,k)
;



variable
    lin_c_P
    lin_c_Q
    lin_c_S
    fix_ck
;
equations
    lineq_64(i,i,ckt,k)  Real power flows into a line at the origin bus each contingency
    lineq_65(i,i,ckt,k)  Reactive power flows into a line at the origin bus each contingency
    lineq_66(i,i,ckt,k)  Real power flows into a line at the destination bus in each contingency
    lineq_67(i,i,ckt,k)  Reactive power flows into a line at the destination bus in each contingency
    lineq_68(i,i,ckt,k)  Real power flows into a transformer at the origin bus in each contingency
    lineq_69(i,i,ckt,k)  Reactive power flows into a transformer at the origin bus in each contingency
    lineq_70(i,i,ckt,k)  Real power flows into a transformer at the destination bus in each contingency
    lineq_71(i,i,ckt,k)  Reactive power flows into a transformer at the destination bus in each contingency
    lineq_72(i,k)  Bus real power balance constraints in each contingency
    lineq_75(i,k)  Bus reactive power balance constraints in each contingency

    lineq_78_Pp(from,to,ckt,k)
    lineq_78_Pn(from,to,ckt,k)
    lineq_80_Pp(from,to,ckt,k)
    lineq_80_Pn(from,to,ckt,k)
    lineq_81_Pp(from,to,ckt,k)
    lineq_81_Pn(from,to,ckt,k)
    lineq_83_Pp(from,to,ckt,k)
    lineq_83_Pn(from,to,ckt,k)

    lineq_78_Qp(from,to,ckt,k)
    lineq_78_Qn(from,to,ckt,k)
    lineq_80_Qp(from,to,ckt,k)
    lineq_80_Qn(from,to,ckt,k)
    lineq_81_Qp(from,to,ckt,k)
    lineq_81_Qn(from,to,ckt,k)
    lineq_83_Qp(from,to,ckt,k)
    lineq_83_Qn(from,to,ckt,k)

    lineq_91(i,g,k)
    lineq_92(i,g,k)
    lineq_100(i,g,k)
    lineq_101(i,g,k)

    fixeq_89(i,g,k)
    fixeq_90(i,g,k)
    fixeq_91(i,g,k)
    fixeq_92(i,g,k)
    fixeq_98(i,g,k)
    fixeq_99(i,g,k)
    fixeq_100(i,g,k)
    fixeq_101(i,g,k)

    bineq_89(i,g,k)
    bineq_90(i,g,k)
    bineq_91(i,g,k)
    bineq_92(i,g,k)
    bineq_98(i,g,k)
    bineq_99(i,g,k)
    bineq_100(i,g,k)
    bineq_101(i,g,k)

    lineq_17
    lineq_19

    lin_obj_real
    lin_obj_reactive
    lin_obj_current
    fix_obj

;

* P and Theta are variables, fix V to base case level, sin(a+b) = a+b, cos(a+b) = 1
lineq_64(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    v_peko(from,to,ckt,k) =e= p_ge(from,to,ckt)*sqr(p_vi(from)) + (-p_ge(from,to,ckt)*1 - p_be(from,to,ckt)*(v_thetaik(from,k) - v_thetaik(to,k)))*p_vi(from)*p_vi(to);
lineq_66(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    v_pekd(from,to,ckt,k) =e=  p_ge(from,to,ckt)*sqr(p_vi(to)) + (-p_ge(from,to,ckt)*1 - p_be(from,to,ckt)*(v_thetaik(to,k) - v_thetaik(from,k)))*p_vi(from)*p_vi(to);
lineq_68(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
    v_pfko(from,to,ckt,k) =e= (p_gf(from,to,ckt)/sqr(p_tauf(from,to,ckt))+p_gfm(from,to,ckt))*sqr(p_vi(from)) + (-p_gf(from,to,ckt)/p_tauf(from,to,ckt)*1 - p_bf(from,to,ckt)/p_tauf(from,to,ckt)*(v_thetaik(from,k)-v_thetaik(to,k)-p_thetaf(from,to,ckt)))*p_vi(from)*p_vi(to);
lineq_70(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
    v_pfkd(from,to,ckt,k) =e= p_gf(from,to,ckt)*sqr(p_vi(to)) + (-p_gf(from,to,ckt)/p_tauf(from,to,ckt)*1 - p_bf(from,to,ckt)/p_tauf(from,to,ckt)*(v_thetaik(to,k)-v_thetaik(from,k)+p_thetaf(from,to,ckt)))*p_vi(from)*p_vi(to);
lineq_72(i,k)$activek(k)..
    sum((g)$actgenk(i,g,k), v_pgk(i,g,k)) -p_piL(i)-p_giFS(i)*sqr(p_vi(i)) - sum((to,ckt)$actlinek(i,to,ckt,k), v_peko(i,to,ckt,k)) - sum((from,ckt)$actlinek(from,i,ckt,k), v_pekd(from,i,ckt,k)) - sum((to,ckt)$actxfmrk(i,to,ckt,k), v_pfko(i,to,ckt,k)) - sum((from,ckt)$(actxfmrk(from,i,ckt,k)), v_pfkd(from,i,ckt,k)) =e=  v_sigmaikPp(i,k) - v_sigmaikPn(i,k);

lineq_91(i,g,k)$(gkp(i,g,k) and activek(k))..
    p_pg(i,g) + p_alphag(i,g)*v_deltak(k) - v_pgk(i,g,k) =l= p_M*(1-v_xgkPp(i,g,k));
lineq_92(i,g,k)$(gkp(i,g,k) and activek(k))..
    v_pgk(i,g,k) - p_pg(i,g) - p_alphag(i,g)*v_deltak(k) =l= p_M*(1-v_xgkPn(i,g,k));

lineq_78_Pp(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
v_peko(from,to,ckt,k) =l= p_ReK_u(from,to,ckt)*p_viK_u(from) + v_sigmaekS(from,to,ckt,k);

lineq_78_Pn(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
-v_peko(from,to,ckt,k) =l= p_ReK_u(from,to,ckt)*p_viK_u(from) + v_sigmaekS(from,to,ckt,k);

lineq_80_Pp(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
v_pekd(from,to,ckt,k) =l= p_ReK_u(from,to,ckt)*p_viK_u(to) + v_sigmaekS(from,to,ckt,k);

lineq_80_Pn(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
-v_pekd(from,to,ckt,k) =l= p_ReK_u(from,to,ckt)*p_viK_u(to) + v_sigmaekS(from,to,ckt,k);

lineq_81_Pp(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
v_pfko(from,to,ckt,k) =l= p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k);

lineq_81_Pn(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
-v_pfko(from,to,ckt,k) =l= p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k);

lineq_83_Pp(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
v_pfkd(from,to,ckt,k) =l= p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k);

lineq_83_Pn(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
-v_pfkd(from,to,ckt,k) =l= p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k);


lin_obj_real..
    lin_c_P =e= sum(k$activek(k), sum(n, (p_lambdanP(n)*sum(i, v_sigmaiknPp(i,k,n)+v_sigmaiknPn(i,k,n)))
                                          + (p_lambdanS(n)*sum((from,to,ckt)$actlinek(from,to,ckt,k), v_sigmaeknS(from,to,ckt,k,n))
                       + p_lambdanS(n)*sum((from,to,ckt)$actxfmrk(from,to,ckt,k), v_sigmafknS(from,to,ckt,k,n))) ));

model lin_P_model /
    eq_9
    eq_11
    eq_17
    eq_19
    lineq_64
    lineq_66
    lineq_68
    lineq_70
    lineq_72
    lineq_78_Pp
    lineq_78_Pn
    lineq_80_Pp
    lineq_80_Pn
    lineq_81_Pp
    lineq_81_Pn
    lineq_83_Pp
    lineq_83_Pn
    eq_89
    eq_90
    lineq_91
    lineq_92
    lin_obj_real
/;


* Q and V are variables, fix theta to base case level, fix v_bikCS to v_biCS.l, ab = a+b-1
lineq_65(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    v_qeko(from,to,ckt,k) =e= -(p_be(from,to,ckt) + p_bech(from,to,ckt)/2)*(v_vik(from,k) + v_vik(from,k) - 1) + (p_be(from,to,ckt)*cos(p_thetai(from) - p_thetai(to)) - p_ge(from,to,ckt)*sin(p_thetai(from) - p_thetai(to)))*(v_vik(from,k)+v_vik(to,k)-1);
lineq_67(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
    v_qekd(from,to,ckt,k) =e= -(p_be(from,to,ckt) + p_bech(from,to,ckt)/2)*(v_vik(to,k) + v_vik(to,k) - 1) + (p_be(from,to,ckt)*cos(p_thetai(to) - p_thetai(from)) - p_ge(from,to,ckt)*sin(p_thetai(to) - p_thetai(from)))*(v_vik(from,k)+v_vik(to,k)-1);
lineq_69(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
    v_qfko(from,to,ckt,k) =e= -(p_bf(from,to,ckt)/sqr(p_tauf(from,to,ckt))+p_bfm(from,to,ckt))*(v_vik(from,k) + v_vik(from,k) - 1) + (p_bf(from,to,ckt)/p_tauf(from,to,ckt)*cos(p_thetai(from)-p_thetai(to)-p_thetaf(from,to,ckt)) - p_gf(from,to,ckt)/p_tauf(from,to,ckt)*sin(p_thetai(from)-p_thetai(to)-p_thetaf(from,to,ckt)))*(v_vik(from,k) + v_vik(to,k) - 1);
lineq_71(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
    v_qfkd(from,to,ckt,k) =e= -p_bf(from,to,ckt)*(v_vik(to,k) + v_vik(to,k) - 1) + (p_bf(from,to,ckt)/p_tauf(from,to,ckt)*cos(p_thetai(to)-p_thetai(from)+p_thetaf(from,to,ckt)) - p_gf(from,to,ckt)/p_tauf(from,to,ckt)*sin(p_thetai(to)-p_thetai(from)+p_thetaf(from,to,ckt)))*(v_vik(from,k) + v_vik(to,k) -1);
lineq_75(i,k)$activek(k)..
    sum((g)$actgenk(i,g,k), v_qgk(i,g,k)) -p_qiL(i)-(-p_bifs(i)-p_bics(i))*(v_vik(i,k) + v_vik(i,k) -1) - sum((to,ckt)$actlinek(i,to,ckt,k), v_qeko(i,to,ckt,k)) - sum((from,ckt)$actlinek(from,i,ckt,k), v_qekd(from,i,ckt,k)) - sum((to,ckt)$actxfmrk(i,to,ckt,k), v_qfko(i,to,ckt,k)) - sum((from,ckt)$(actxfmrk(from,i,ckt,k)), v_qfkd(from,i,ckt,k)) =e=  v_sigmaikQp(i,k) - v_sigmaikQn(i,k);

lineq_78_Qp(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
v_qeko(from,to,ckt,k) =l= p_ReK_u(from,to,ckt)*v_vik(from,k) + v_sigmaekS(from,to,ckt,k);

lineq_78_Qn(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
-v_qeko(from,to,ckt,k) =l= p_ReK_u(from,to,ckt)*v_vik(from,k) + v_sigmaekS(from,to,ckt,k);

lineq_80_Qp(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
v_qekd(from,to,ckt,k) =l= p_ReK_u(from,to,ckt)*v_vik(to,k) + v_sigmaekS(from,to,ckt,k);

lineq_80_Qn(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k))..
-v_qekd(from,to,ckt,k) =l= p_ReK_u(from,to,ckt)*v_vik(to,k) + v_sigmaekS(from,to,ckt,k);

lineq_81_Qp(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
v_qfko(from,to,ckt,k) =l= p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k);

lineq_81_Qn(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
-v_qfko(from,to,ckt,k) =l= p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k);

lineq_83_Qp(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
v_qfkd(from,to,ckt,k) =l= p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k);

lineq_83_Qn(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k))..
-v_qfkd(from,to,ckt,k) =l= p_sfK_u(from,to,ckt) + v_sigmafkS(from,to,ckt,k);

lineq_100(i,g,k)$(actgenk(i,g,k) and activek(k))..
    p_vi(i) - v_vik(i,k) =l= p_Mv*(1-v_xgkQp(i,g,k));
lineq_101(i,g,k)$(actgenk(i,g,k) and activek(k))..
    v_vik(i,k) - p_vi(i) =l= p_Mv*(1-v_xgkQn(i,g,k));

lin_obj_reactive..
    lin_c_Q =e= sum(k$activek(k), sum(n, (p_lambdanQ(n)*sum(i, v_sigmaiknQp(i,k,n)+v_sigmaiknQn(i,k,n)))
                                          + (p_lambdanS(n)*sum((from,to,ckt)$actlinek(from,to,ckt,k), v_sigmaeknS(from,to,ckt,k,n))
                       + p_lambdanS(n)*sum((from,to,ckt)$actxfmrk(from,to,ckt,k), v_sigmafknS(from,to,ckt,k,n))) ));

model lin_Q_model /
    eq_13
    eq_15
    eq_17
    eq_19
    lineq_65
    lineq_67
    lineq_69
    lineq_71
    lineq_75
    lineq_78_Qp
    lineq_78_Qn
    lineq_80_Qp
    lineq_80_Qn
    lineq_81_Qp
    lineq_81_Qn
    lineq_83_Qp
    lineq_83_Qn
    eq_98
    eq_99
    lineq_100
    lineq_101
    lin_obj_reactive
/;


fixeq_89(i,g,k)$(gkp(i,g,k) and activek(k) and (p_xgkPp(i,g,k) eq 0))..
    p_pg_u(i,g) - v_pgk(i,g,k) =l= 0;

fixeq_90(i,g,k)$(gkp(i,g,k) and activek(k) and (p_xgkPn(i,g,k) eq 0))..
    v_pgk(i,g,k) - p_pg_l(i,g) =l= 0;

fixeq_91(i,g,k)$(gkp(i,g,k) and activek(k) and (p_xgkPp(i,g,k) eq 1))..
    p_pg(i,g) + p_alphag(i,g)*v_deltak(k) - v_pgk(i,g,k) =l= 0;

fixeq_92(i,g,k)$(gkp(i,g,k) and activek(k) and (p_xgkPn(i,g,k) eq 1))..
    v_pgk(i,g,k) - p_pg(i,g) - p_alphag(i,g)*v_deltak(k) =l= 0;

fixeq_98(i,g,k)$(actgenk(i,g,k) and activek(k) and (p_xgkQp(i,g,k) eq 0))..
    p_qg_u(i,g) - v_qgk(i,g,k) =l= 0;

fixeq_99(i,g,k)$(actgenk(i,g,k) and activek(k) and (p_xgkQn(i,g,k) eq 0))..
    v_qgk(i,g,k) - p_qg_l(i,g) =l= 0;

fixeq_100(i,g,k)$(actgenk(i,g,k) and activek(k) and (p_xgkQp(i,g,k) eq 1))..
    p_vi(i) - v_vik(i,k) =l= 0;

fixeq_101(i,g,k)$(actgenk(i,g,k) and activek(k) and (p_xgkQn(i,g,k) eq 1))..
    v_vik(i,k) - p_vi(i) =l= 0;

fix_obj..
    fix_ck =e= sum(k$activek(k), sum(n, (p_lambdanP(n)*sum(i, v_sigmaiknPp(i,k,n)+v_sigmaiknPn(i,k,n)) + p_lambdanQ(n)*sum(i, v_sigmaiknQp(i,k,n)+v_sigmaiknQn(i,k,n)) + p_lambdanS(n)*sum((from,to,ckt)$actlinek(from,to,ckt,k), v_sigmaeknS(from,to,ckt,k,n)) + p_lambdanS(n)*sum((from,to,ckt)$actxfmrk(from,to,ckt,k), v_sigmafknS(from,to,ckt,k,n)))));


model fix_single_cont /
    eq_9
    eq_11
    eq_13
    eq_15
    eq_17
    eq_19

    eq_64
    eq_65
    eq_66
    eq_67
    eq_68
    eq_69
    eq_70
    eq_71
    eq_72
    eq_75
    eq_78
    eq_80
    eq_81
    eq_83
    eq_84

    fixeq_89
    fixeq_90
    fixeq_91
    fixeq_92
    fixeq_98
    fixeq_99
    fixeq_100
    fixeq_101
    fix_obj

/;

eq_85_1(i,g,k)$(gkp(i,g,k) and activek(k) and actset_pgk(i,g,k))..
    v_pgk(i,g,k) =e= p_pg(i,g) + p_alphag(i,g)*v_deltak(k);

eq_85_2(i,g,k)$(gkp(i,g,k) and activek(k) and actset_pgk_lq(i,g,k))..
    v_pgk(i,g,k) =l= p_pg(i,g) + p_alphag(i,g)*v_deltak(k);

eq_85_3(i,g,k)$(gkp(i,g,k) and activek(k) and actset_pgk_gq(i,g,k))..
    v_pgk(i,g,k) =g= p_pg(i,g) + p_alphag(i,g)*v_deltak(k);

eq_93_1(i,g,k)$(gkp(i,g,k) and activek(k) and actset_vik(i,k))..
    v_vik(i,k) =e= p_vi(i);

eq_93_2(i,g,k)$(gkp(i,g,k) and activek(k) and actset_vik_lq(i,k))..
    v_vik(i,k) =l= p_vi(i);

eq_93_3(i,g,k)$(gkp(i,g,k) and activek(k) and actset_vik_gq(i,k))..
    v_vik(i,k) =g= p_vi(i);

bineq_89(i,g,k)$(gkp(i,g,k) and activek(k))..
    p_pg_u(i,g) - v_pgk(i,g,k) =l= p_Mp*v_xgkPp(i,g,k);

bineq_90(i,g,k)$(gkp(i,g,k) and activek(k))..
    v_pgk(i,g,k) - p_pg_l(i,g) =l= p_Mp*v_xgkPn(i,g,k);

bineq_91(i,g,k)$(gkp(i,g,k) and activek(k))..
    p_pg(i,g) + p_alphag(i,g)*v_deltak(k) - v_pgk(i,g,k) =l= p_M*(1-v_xgkPp(i,g,k));

bineq_92(i,g,k)$(gkp(i,g,k) and activek(k))..
    v_pgk(i,g,k) - p_pg(i,g) - p_alphag(i,g)*v_deltak(k) =l= p_M*(1-v_xgkPn(i,g,k));

bineq_98(i,g,k)$(actgenk(i,g,k) and activek(k))..
    p_qg_u(i,g) - v_qgk(i,g,k) =l= p_Mq*v_xgkQp(i,g,k);

bineq_99(i,g,k)$(actgenk(i,g,k) and activek(k))..
    v_qgk(i,g,k) - p_qg_l(i,g) =l= p_Mq*v_xgkQn(i,g,k);

bineq_100(i,g,k)$(actgenk(i,g,k) and activek(k))..
    p_vi(i) - v_vik(i,k) =l= p_Mv*(1-v_xgkQp(i,g,k));

bineq_101(i,g,k)$(actgenk(i,g,k) and activek(k))..
    v_vik(i,k) - p_vi(i) =l= p_Mv*(1-v_xgkQn(i,g,k));

model minlp_single_cont /
    eq_9
    eq_11
    eq_13
    eq_15
    eq_17
    eq_19

    eq_64
    eq_65
    eq_66
    eq_67
    eq_68
    eq_69
    eq_70
    eq_71
    eq_72
    eq_75
    eq_78
    eq_80
    eq_81
    eq_83
    eq_84

    bineq_89
    bineq_90
    bineq_91
    bineq_92
    bineq_98
    bineq_99
    bineq_100
    bineq_101
    fix_obj
/;

model nlp_single_cont /
    eq_9
    eq_11
    eq_13
    eq_15
    eq_17
    eq_19

    eq_64
    eq_65
    eq_66
    eq_67
    eq_68
    eq_69
    eq_70
    eq_71
    eq_72
    eq_75
    eq_78
    eq_80
    eq_81
    eq_83
    eq_84
    eq_85_1
    eq_85_2
    eq_85_3
    eq_93_1
    eq_93_2
    eq_93_3

    fix_obj
/;

fix_single_cont.solprint = no;
fix_single_cont.optfile=1;
fix_single_cont.solvelink=5;

minlp_single_cont.solprint = no;
minlp_single_cont.optfile=1;
minlp_single_cont.solvelink=5;

lin_P_model.optfile=1;
lin_Q_model.optfile=1;

lin_P_model.solprint = no;
lin_Q_model.solprint = no;

lin_P_model.solvelink = 5;
lin_Q_model.solvelink = 5;


parameter
    starttime
    cont_viol(k)
    base_v_c the base case generation cost
    cont_v_c(k) the base case generation cost in model with single contingency k
    cont_mod_stat_nlp(k) model status of nlp base + single contingency
    cont_mod_stat_P(k)
    cont_mod_stat_Q(k)
    cont_cputime_nlp(k)
    cont_cputime_P(k)
    cont_cputime_Q(k)
    cont_c_Total(k,*)
    isfeasible
;


parameter
    sol_v_vi(i)
    sol_v_thetai(i)
    sol_v_biCS(i)
    sol_v_pg(i,g)
    sol_v_qg(i,g)
    sol_v_vik(i,k)
    sol_v_thetaik(i,k)
    sol_v_bikCS(i,k)
    sol_v_pgk(i,g,k)
    sol_v_qgk(i,g,k)
    sol_v_deltak(k)

    sol_fix_ck(k)
;

sets
    BusSolInfo
    GenSolInfo
;
parameters
    BusSol(Bus,BusSolInfo)
    GeneratorSol(Bus,g,GenSolInfo)
;

$ifthen %have_sol1_gdx% == yes
execute_load 'solution1.gdx' sol_v_vi, sol_v_thetai, sol_v_biCS, sol_v_pg, sol_v_qg;
$else
$gdxin txt2xls.gdx
$load BusSolInfo,GenSolInfo, BusSol, GeneratorSol
$gdxin

sol_v_vi(i) = BusSol(i,'v');
sol_v_thetai(i) = BusSol(i,'theta');
sol_v_bics(i) = BusSol(i,'bcs');
sol_v_pg(i,g) = GeneratorSol(i,g,'p');
sol_v_qg(i,g) = GeneratorSol(i,g,'q');
$endif


* Initialize all contingencies solutions to the base case solution, in case the program is interrupted due to time limit
sol_v_vik(i,k) = sol_v_vi(i);
sol_v_thetaik(i,k) = sol_v_thetai(i);
sol_v_bikCS(i,k) = sol_v_bics(i);
sol_v_pgk(i,g,k) = sol_v_pg(i,g);
sol_v_qgk(i,g,k) = sol_v_qg(i,g);
sol_v_deltak(k) = 0;

p_pg(i,g) = sol_v_pg(i,g)/p_s_tilde;
p_vi(i) = sol_v_vi(i);
p_qg(i,g) = sol_v_qg(i,g)/p_s_tilde;
p_thetai(i) = sol_v_thetai(i)/(180/pi);
p_bics(i) = sol_v_biCS(i)/p_s_tilde;

option limrow=0,limcol=0;

* Handle generator contintencies
loop(k0$(ord(k0) <= %firstNcont%),
    activek(k) = yes$(ord(k) = ord(k0));

*Contingency Data from CON
    actlinek(i,j,ckt,k0)$actline(i,j,ckt) = yes;
    actxfmrk(i,j,ckt,k0)$actxfmr(i,j,ckt) = yes;
    actgenk(i,g,k0)$actgen(i,g) = yes;
    failgenk(i,g,k0)$(GeneratorOutofServiceEvent(i,g,k0)) = yes;
    actgenk(i,g,k0)$failgenk(i,g,k0) = No;
    faillinek(i,j,ckt,k0)$(BranchOutofServiceEvent(i,j,ckt,k0) and actlinek(i,j,ckt,k0)) = yes;
    actlinek(i,j,ckt,k0)$faillinek(i,j,ckt,k0) = No;
    failxfmrk(i,j,ckt,k0)$(BranchOutofServiceEvent(i,j,ckt,k0) and actxfmrk(i,j,ckt,k0)) = yes;
    actxfmrk(i,j,ckt,k0)$failxfmrk(i,j,ckt,k0) = No;
    gkp(i,g,k0)$actgenk(i,g,k0) = yes;
*Generator Real Power Contingency Response Data
    failBus(i,k)$activek(k) = yes$(sum((g)$failgenk(i,g,k),1)>=1 or sum((to,ckt)$faillinek(i,to,ckt,k),1)>=1 or sum((from,ckt)$faillinek(from,i,ckt,k),1)>=1 or sum((to,ckt)$failxfmrk(i,to,ckt,k),1)>=1 or sum((from,ckt)$failxfmrk(from,i,ckt,k),1)>=1);
    failArea(a,k)$activek(k) = yes$(sum((i)$(Areas(i,a) and failbus(i,k)),1)>=1);
    gkp(i,g,k)$activek(k) = yes$(actgenk(i,g,k) and sum((a)$(failArea(a,k) and Areas(i,a)),1)>=1);

    p_sigmaeknS_u(i,j,ckt,k0,n)$actlinek(i,j,ckt,k0) =  p_SViolMaxn(n)/p_s_tilde;
    p_sigmafknS_u(i,j,ckt,k0,n)$actxfmrk(i,j,ckt,k0) =  p_SViolMaxn(n)/p_s_tilde;
    p_sigmaiknPp_u(i,k0,n) =  p_PViolMaxn(n)/ p_s_tilde;
    p_sigmaiknPn_u(i,k0,n) =  p_PViolMaxn(n)/ p_s_tilde;
    p_sigmaiknQp_u(i,k0,n) =  p_QViolMaxn(n)/ p_s_tilde;
    p_sigmaiknQn_u(i,k0,n) =  p_QViolMaxn(n)/ p_s_tilde;


    v_sigmaiknPp.lo(i,k,n)$activek(k) = 0;
    v_sigmaiknPp.up(i,k,n)$activek(k) = p_sigmainPp_u(i,n);

    v_sigmaiknPn.lo(i,k,n)$activek(k) = 0;
    v_sigmaiknPn.up(i,k,n)$activek(k) = p_sigmainPn_u(i,n);

    v_sigmaiknQp.lo(i,k,n)$activek(k) = 0;
    v_sigmaiknQp.up(i,k,n)$activek(k) = p_sigmainQp_u(i,n);

    v_sigmaiknQn.lo(i,k,n)$activek(k) = 0;
    v_sigmaiknQn.up(i,k,n)$activek(k) = p_sigmainQn_u(i,n);

    v_sigmaeknS.lo(from,to,ckt,k,n)$(actline(from,to,ckt) and activek(k)) = 0;
    v_sigmaeknS.up(from,to,ckt,k,n)$(actline(from,to,ckt) and activek(k)) = p_sigmaenS_u(from,to,ckt,n);

    v_sigmafknS.lo(from,to,ckt,k,n)$(actxfmr(from,to,ckt) and activek(k)) = 0;
    v_sigmafknS.up(from,to,ckt,k,n)$(actxfmr(from,to,ckt) and activek(k)) = p_sigmafnS_u(from,to,ckt,n);

    v_vik.lo(i,k)$activek(k) = p_viK_l(i);
    v_vik.up(i,k)$activek(k) = p_viK_u(i);



    v_pgk.fx(i,g,k)$((not actgenk(i,g,k)) and activek(k)) = 0;



    v_qgk.fx(i,g,k)$((not actgenk(i,g,k)) and activek(k)) = 0;

    v_bikCS.lo(i,k)$activek(k) = p_bics_l(i);
    v_bikCS.up(i,k)$activek(k) = p_bics_u(i);

    v_sigmaikPp.lo(i,k)$activek(k) = 0;

    v_sigmaikPn.lo(i,k)$activek(k) = 0;

    v_sigmaikQp.lo(i,k)$activek(k) = 0;

    v_sigmaikQn.lo(i,k)$activek(k) = 0;

    v_sigmaekS.lo(from,to,ckt,k)$(actlinek(from,to,ckt,k) and activek(k)) = 0;

    v_sigmafkS.lo(from,to,ckt,k)$(actxfmrk(from,to,ckt,k) and activek(k)) = 0;

    v_thetaik.lo(i,k)$activek(k) = -pi/3;
    v_thetaik.up(i,k)$activek(k) = pi/3;
*    v_deltak.lo(k0) = 0;


$ifthen %method% == minlp
    v_pgk.lo(i,g,k)$(actgenk(i,g,k) and activek(k)) = p_pg_l(i,g);
    v_pgk.up(i,g,k)$(actgenk(i,g,k) and activek(k)) = p_pg_u(i,g);
    v_qgk.lo(i,g,k)$(actgenk(i,g,k) and activek(k)) = p_qg_l(i,g);
    v_qgk.up(i,g,k)$(actgenk(i,g,k) and activek(k)) = p_qg_u(i,g);
    solve minlp_single_cont minimize fix_ck using minlp;
$elseif  %method% == nlp
    isfeasible = 0;
    actset_pgk(i,g,k) = yes;
    actset_vik(i,k) = yes;
    actset_pgk_lq(i,g,k) = no;
    actset_pgk_gq(i,g,k) = no;
    actset_vik_lq(i,k) = no;
    actset_vik_gq(i,k) = no;
    while((isfeasible < 1),
        isfeasible = 1;
        solve nlp_single_cont minimize fix_ck using nlp;
        loop((i,g,k)$(actgenk(i,g,k) and activek(k)),
            if(v_pgk.l(i,g,k) > p_pg_u(i,g),
                v_pgk.fx(i,g,k) = p_pg_u(i,g);
                actset_pgk_lq(i,g,k) = yes;
                actset_pgk(i,g,k) = no;
                isfeasible = 0;
                );
            if(v_pgk.l(i,g,k) < p_pg_l(i,g),
                v_pgk.fx(i,g,k) = p_pg_l(i,g);
                actset_pgk_gq(i,g,k) = yes;
                actset_pgk(i,g,k) = no;
                isfeasible = 0;
                );
            );
        loop((i,g,k)$(actgenk(i,g,k) and activek(k)),
            if(v_qgk.l(i,g,k) > p_qg_u(i,g),
                v_qgk.fx(i,g,k) = p_qg_u(i,g);
                actset_vik(i,k) = no;
                actset_vik_lq(i,k) = yes;
                isfeasible = 0;
                );
            if(v_qgk.l(i,g,k) < p_qg_l(i,g),
                v_qgk.fx(i,g,k) = p_qg_l(i,g);
                actset_vik(i,k) = no;
                actset_vik_gq(i,k) = yes;
                isfeasible = 0;
                );
            );
        );
$else
* Initialize
    v_xgkPp.l(i,g,k0)$actgenk(i,g,k0) = 0;
    v_xgkPn.l(i,g,k0)$actgenk(i,g,k0) = 0;
    v_xgkQp.l(i,g,k0)$actgenk(i,g,k0) = 0;
    v_xgkQn.l(i,g,k0)$actgenk(i,g,k0) = 0;

    starttime = timeelapsed;
    solve lin_P_model minimize lin_c_P using mip;
    cont_cputime_P(k0) = timeelapsed - starttime;
    cont_mod_stat_P(k0) = lin_P_model.modelstat;
    starttime = timeelapsed;
    solve lin_Q_model minimize lin_c_Q using mip;
    cont_cputime_Q(k0) = timeelapsed - starttime;
    cont_mod_stat_Q(k0) = lin_Q_model.modelstat;


    p_xgkPp(i,g,k0) = v_xgkPp.l(i,g,k0);
    p_xgkPn(i,g,k0) = v_xgkPn.l(i,g,k0);
    p_xgkQp(i,g,k0) = v_xgkQp.l(i,g,k0);
    p_xgkQn(i,g,k0) = v_xgkQn.l(i,g,k0);
    solve fix_single_cont minimize fix_ck using nlp;
$endif

    sol_v_vik(i,k0) = v_vik.l(i,k0);
    sol_v_thetaik(i,k0) = (180/pi)* v_thetaik.l(i,k0);
    sol_v_bikCS(i,k0) = p_s_tilde * v_bikCS.l(i,k0);
    sol_v_pgk(i,g,k0) = p_s_tilde * v_pgk.l(i,g,k0);
    sol_v_qgk(i,g,k0) = p_s_tilde * v_qgk.l(i,g,k0);
    sol_v_deltak(k0) = p_s_tilde * v_deltak.l(k0);

    sol_fix_ck(k0) = fix_ck.l;
);

display sol_fix_ck;

execute_unload 'solution2.gdx' sol_v_vik, sol_v_thetaik, sol_v_bikCS, sol_v_pgk, sol_v_qgk, sol_v_deltak;

file soltext2 /'solution2.txt'/;
put soltext2;
loop(k,
    put '--contigency' /;
    put 'lable' /;
    put "'" k.tl:30 "'"/;
    put '--bus section' /;
    put 'i, v, theta, b' /;
    loop(i,
        put  i.tl  ',' sol_v_vik(i,k):25:15 ',' sol_v_thetaik(i,k):25:15 ',' sol_v_bikCS(i,k):25:15 /;
    );
    put '--generator section' /;
    put 'i, uid, p, q' /;
    loop((i,g)$gen(i,g),
        put  i.tl ',' "'" g.tl "'" ',' sol_v_pgk(i,g,k):25:15 ',' sol_v_qgk(i,g,k):25:15 /;
    );
    put '--delta section' /;
    put 'delta' /;
    put sol_v_deltak(k):25:15 /;
);
