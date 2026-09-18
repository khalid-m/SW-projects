# include <cmath>
# include <iostream>
# include "TParticleCodeConverter.h"

TParticleCodeConverter::TParticleCodeConverter() {
}

TParticleCodeConverter::~TParticleCodeConverter() {
}

string TParticleCodeConverter::GetNameFromPdg(int pdg) {
  string s;
  if      (pdg ==  1)       { s = "d";}
  else if (pdg == -1)       { s = "dbar";}
  else if (pdg ==  2)       { s = "u";}
  else if (pdg == -2)       { s = "ubar";}
  else if (pdg ==  3)       { s = "s";}
  else if (pdg == -3)       { s = "sbar";}
  else if (pdg ==  4)       { s = "c";}
  else if (pdg == -4)       { s = "cbar";}
  else if (pdg ==  5)       { s = "b";}
  else if (pdg == -5)       { s = "bbar";}
  else if (pdg ==  6)       { s = "t";}
  else if (pdg == -6)       { s = "tbar";}
  else if (pdg ==  11)      { s = "e-";}
  else if (pdg == -11)      { s = "e+";}
  else if (pdg ==  12)      { s = "nu_e";}
  else if (pdg == -12)      { s = "nu_ebar";}
  else if (pdg ==  13)      { s = "mu-";}
  else if (pdg == -13)      { s = "mu+";}
  else if (pdg ==  14)      { s = "nu_mu";}
  else if (pdg == -14)      { s = "nu_mubar";}
  else if (pdg ==  15)      { s = "tau-";}
  else if (pdg == -15)      { s = "tau+";}
  else if (pdg ==  16)      { s = "nu_tau";}
  else if (pdg == -16)      { s = "nu_taubar";}
  else if (pdg ==  21)      { s = "g";}
  else if (pdg ==  22)      { s = "gamma";}
  else if (pdg ==  23)      { s = "Z0";}
  else if (pdg ==  24)      { s = "W+";}
  else if (pdg == -24)      { s = "W-";}
  else if (pdg ==  25)      { s = "h0";}
  else if (pdg ==  35)      { s = "H0";}
  else if (pdg ==  36)      { s = "A0";}
  else if (pdg ==  37)      { s = "H+";}
  else if (pdg == -37)      { s = "H-";}
  else if (pdg ==  51)      { s = "??";}
  else if (pdg ==  441)     { s = "ETA_C";}
  else if (pdg ==  443)     { s = "JPSI";}
  else if (pdg ==  445)     { s = "CHI_C2";}
  else if (pdg ==  511)     { s = "B_D0";}
  else if (pdg == -511)     { s = "B_D0bar";}
  else if (pdg ==  521)     { s = "B+";}
  else if (pdg == -521)     { s = "B-";}
  else if (pdg ==  531)     { s = "B_S0";}
  else if (pdg == -531)     { s = "B_S0bar";}
  else if (pdg ==  2101)    { s = "ud0";}
  else if (pdg ==  2203)    { s = "uu1";}
  else if (pdg ==  2212)    { s = "p";}
  else if (pdg == -2212)    { s = "pbar";}
  else if (pdg ==  2112)    { s = "n";}
  else if (pdg == -2112)    { s = "nbar";}
  else if (pdg ==  5122)    { s = "lambda_b0";}
  else if (pdg ==  5222)    { s = "sigma_b+";}
  else if (pdg ==  10441)   { s = "CHI_C1";}
  else if (pdg ==  20433)   { s = "DH_S1+";}
  else if (pdg ==  20443)   { s = "PSID";}
  else if (pdg ==  100443)  { s = "PSI2S";}
  else if (pdg ==  1000011) { s = "~e_L-";}
  else if (pdg == -1000011) { s = "~e_L+";}
  else if (pdg ==  1000012) { s = "~nu_eL";}
  else if (pdg == -1000012) { s = "~nu_eLbar";}
  else if (pdg ==  1000013) { s = "~mu_L-";}
  else if (pdg == -1000013) { s = "~mu_L+";}
  else if (pdg ==  1000014) { s = "~nu_muL";}
  else if (pdg == -1000014) { s = "~nu_muLbar";}
  else if (pdg ==  1000015) { s = "~tau_1-";}
  else if (pdg == -1000015) { s = "~tau_1+";}
  else if (pdg ==  1000016) { s = "~nu_tauL";}
  else if (pdg == -1000016) { s = "~nu_tauLbar";}
  else if (pdg ==  2000011) { s = "~e_R-";}
  else if (pdg == -2000011) { s = "~e_R+";}
  else if (pdg ==  2000013) { s = "~mu_R-";}
  else if (pdg == -2000013) { s = "~mu_R+";}
  else if (pdg ==  2000015) { s = "~tau_2-";}
  else if (pdg == -2000015) { s = "~tau_2+";}
  else if (pdg ==  1000021) { s = "~g";}
  else if (pdg ==  1000022) { s = "~chi_10";}
  else if (pdg ==  1000023) { s = "~chi_20";}
  else if (pdg ==  1000024) { s = "~chi_1+";}
  else if (pdg == -1000024) { s = "~chi_1-";}
  else if (pdg ==  1000025) { s = "~chi_30";}
  else if (pdg ==  1000035) { s = "~chi_40";}
  else if (pdg ==  1000037) { s = "~chi_2+";}
  else if (pdg == -1000037) { s = "~chi_2-";}
  else { 
    cout<<"ERROR: TParticleCodeConverter::GetNameFromPdg(), This pdg code "<<pdg<<" was not implemented. Exit!"<<endl;
    exit(1);
  }
  return s;
}

string TParticleCodeConverter::GetNameFromHerwigCode(int herwigCode) {
  int pdg = GetPdgFromHerwigCode(herwigCode);
  return GetNameFromPdg(pdg);
}

string TParticleCodeConverter::GetNameFromIsaCode(int isaCode) {
  int pdg = GetPdgFromIsaCode(isaCode);
  return GetNameFromPdg(pdg);
}

int TParticleCodeConverter::GetPdgFromString(string s) { 
  int pdg;
  if      ( s == "d" )         {pdg =  1;}  
  else if ( s == "dbar" )      {pdg = -1;}
  else if ( s == "u" )         {pdg =  2;}       
  else if ( s == "ubar" )      {pdg = -2;}      
  else if ( s == "s" )         {pdg =  3;}      
  else if ( s == "sbar" )      {pdg = -3;}       
  else if ( s == "c" )         {pdg =  4;}       
  else if ( s == "cbar" )      {pdg = -4;}     
  else if ( s == "b" )         {pdg =  5;}     
  else if ( s == "bbar" )      {pdg = -5;}     
  else if ( s == "t" )         {pdg =  6;}     
  else if ( s == "tbar" )      {pdg = -6;}     
  else if ( s == "e-" )        {pdg =  11;}    
  else if ( s == "e+" )        {pdg = -11;}    
  else if ( s == "nu_e" )      {pdg =  12;}    
  else if ( s == "nu_ebar" )   {pdg = -12;}    
  else if ( s == "mu-" )       {pdg =  13;}    
  else if ( s == "mu+" )       {pdg = -13;}    
  else if ( s == "nu_mu" )     {pdg =  14;}    
  else if ( s == "nu_mubar" )  {pdg = -14;}    
  else if ( s == "tau-" )      {pdg =  15;}    
  else if ( s == "tau+" )      {pdg = -15;}    
  else if ( s == "nu_tau" )    {pdg =  16;}    
  else if ( s == "nu_taubar" ) {pdg = -16;}    
  else if ( s == "g" )         {pdg =  21;}    
  else if ( s == "gamma" )     {pdg =  22;} 
  else if ( s == "pi0" )       {pdg =  111;} 
  else if ( s == "pi+" )       {pdg =  211;} 
  else if ( s == "pi-" )       {pdg = -211;} 
  else if ( s == "Z0" )        {pdg =  23;}    
  else if ( s == "W+" )        {pdg =  24;}    
  else if ( s == "W-" )        {pdg = -24;}    
  else if ( s == "h0" )        {pdg =  25;} 
  else if ( s == "H0" )        {pdg =  35;} 
  else if ( s == "A0" )        {pdg =  36;}
  else if ( s == "H+" )        {pdg =  37;}    
  else if ( s == "H-" )        {pdg = -37;}    
  else if ( s == "??" )        {pdg =  51;}    
  else if ( s == "ETA_C" )     {pdg =  441;}     
  else if ( s == "JPSI" )      {pdg =  443;}     
  else if ( s == "CHI_C2" )    {pdg =  445;}     
  else if ( s == "B_D0" )      {pdg =  511;}     
  else if ( s == "B_D0bar" )   {pdg = -511;}     
  else if ( s == "B+" )        {pdg =  521;}     
  else if ( s == "B-" )        {pdg = -521;}     
  else if ( s == "B_S0" )      {pdg =  531;}     
  else if ( s == "B_S0bar" )   {pdg = -531;}     
  else if ( s == "ud0" )       {pdg =  2101;}    
  else if ( s == "uu1" )       {pdg =  2203;}    
  else if ( s == "p" )         {pdg =  2212;}    
  else if ( s == "pbar" )      {pdg = -2212;}    
  else if ( s == "n" )         {pdg =  2112;}    
  else if ( s == "nbar" )      {pdg = -2112;}    
  else if ( s == "lambda_b0" ) {pdg =  5122;}    
  else if ( s == "sigma_b+" )  {pdg =  5222;}    
  else if ( s == "CHI_C1" )    {pdg =  10441;}   
  else if ( s == "DH_S1+" )    {pdg =  20433;}   
  else if ( s == "PSID" )      {pdg =  20443;}   
  else if ( s == "PSI2S" )     {pdg =  100443;} 
  else if ( s == "~d_L" )      {pdg =  1000001;}
  else if ( s == "~d_Lbar" )   {pdg = -1000001;}
  else if ( s == "~u_L" )      {pdg =  1000002;}
  else if ( s == "~u_Lbar" )   {pdg = -1000002;}
  else if ( s == "~s_L" )      {pdg =  1000003;}
  else if ( s == "~s_Lbar" )   {pdg = -1000003;}
  else if ( s == "~c_L" )      {pdg =  1000004;}
  else if ( s == "~c_Lbar" )   {pdg = -1000004;}
  else if ( s == "~b_1" )      {pdg =  1000005;}
  else if ( s == "~b_1bar" )   {pdg = -1000005;}
  else if ( s == "~t_1" )      {pdg =  1000006;}
  else if ( s == "~t_1bar" )   {pdg = -1000006;}
  else if ( s == "~e_L-" )     {pdg =  1000011;} 
  else if ( s == "~e_L+" )     {pdg = -1000011;} 
  else if ( s == "~nu_eL" )    {pdg =  1000012;} 
  else if ( s == "~nu_eLbar" ) {pdg = -1000012;} 
  else if ( s == "~mu_L-" )    {pdg =  1000013;} 
  else if ( s == "~mu_L+" )    {pdg = -1000013;} 
  else if ( s == "~nu_muL" )   {pdg =  1000014;} 
  else if ( s == "~nu_muLbar" ){pdg = -1000014;} 
  else if ( s == "~tau_1-" )   {pdg =  1000015;} 
  else if ( s == "~tau_1+" )   {pdg = -1000015;} 
  else if ( s == "~nu_tauL" )  {pdg =  1000016;} 
  else if ( s == "~nu_tauLba" ){pdg = -1000016;}
  else if ( s == "~d_R" )      {pdg =  2000001;}
  else if ( s == "~d_Rbar" )   {pdg = -2000001;}
  else if ( s == "~u_R" )      {pdg =  2000002;}
  else if ( s == "~u_Rbar" )   {pdg = -2000002;}
  else if ( s == "~s_R" )      {pdg =  2000003;}
  else if ( s == "~s_Rbar" )   {pdg = -2000003;}
  else if ( s == "~c_R" )      {pdg =  2000004;}
  else if ( s == "~c_Rbar" )   {pdg = -2000004;}
  else if ( s == "~b_2" )      {pdg =  2000005;}
  else if ( s == "~b_2bar" )   {pdg = -2000005;}
  else if ( s == "~t_2" )      {pdg =  2000006;}
  else if ( s == "~t_2bar" )   {pdg = -2000006;}
  else if ( s == "~e_R-" )     {pdg =  2000011;} 
  else if ( s == "~e_R+" )     {pdg = -2000011;}
  else if ( s == "~nu_eR" )    {pdg =  2000012;} 
  else if ( s == "~nu_eRbar" ) {pdg = -2000012;}
  else if ( s == "~mu_R-" )    {pdg =  2000013;} 
  else if ( s == "~mu_R+" )    {pdg = -2000013;} 
  else if ( s == "~nu_muR" )   {pdg =  2000014;} 
  else if ( s == "~nu_muRbar" ){pdg = -2000014;}
  else if ( s == "~tau_2-" )   {pdg =  2000015;} 
  else if ( s == "~tau_2+" )   {pdg = -2000015;}
  else if ( s == "~nu_tauR" )  {pdg =  2000016;} 
  else if ( s == "~nu_tauRba" ){pdg = -2000016;}
  else if ( s == "~g" )        {pdg =  1000021;} 
  else if ( s == "~chi_10" )   {pdg =  1000022;} 
  else if ( s == "~chi_20" )   {pdg =  1000023;} 
  else if ( s == "~chi_1+" )   {pdg =  1000024;} 
  else if ( s == "~chi_1-" )   {pdg = -1000024;} 
  else if ( s == "~chi_30" )   {pdg =  1000025;} 
  else if ( s == "~chi_40" )   {pdg =  1000035;} 
  else if ( s == "~chi_2+" )   {pdg =  1000037;} 
  else if ( s == "~chi_2-" )   {pdg = -1000037;} 
  else if ( s == "~Gravitino" ){pdg =  1000039;}
  else if ( s == "pi_tc0")     {pdg =  3000111;}
  else if ( s == "pi_tc+")     {pdg =  3000211;}
  else if ( s == "pi_tc-")     {pdg = -3000211;}
  else if ( s == "pi'_tc0")    {pdg =  3000221;}
  else { 
    cout<<"ERROR: TParticleCodeConverter::GetPdgFromString(), This name "<<s<<" was not implemented. Exit!"<<endl;
    exit(1);
  }
  return pdg;
}

int TParticleCodeConverter::GetPdgFromHerwigCode(int herwigCode) {
  int pdg;
  if      ( herwigCode ==  1 )      {pdg =  1;}  
  else if ( herwigCode ==  7 )      {pdg = -1;}
  else if ( herwigCode ==  2 )      {pdg =  2;}       
  else if ( herwigCode ==  8 )      {pdg = -2;}      
  else if ( herwigCode ==  3 )      {pdg =  3;}      
  else if ( herwigCode ==  9 )      {pdg = -3;}       
  else if ( herwigCode ==  4 )      {pdg =  4;}       
  else if ( herwigCode ==  10 )      {pdg = -4;}     
  else if ( herwigCode ==  5 )      {pdg =  5;}     
  else if ( herwigCode ==  11 )      {pdg = -5;}     
  else if ( herwigCode ==  6 )      {pdg =  6;}     
  else if ( herwigCode ==  12 )      {pdg = -6;}     
  else if ( herwigCode ==  121 )     {pdg =  11;}    
  else if ( herwigCode ==  127 )     {pdg = -11;}    
  else if ( herwigCode ==  122 )     {pdg =  12;}    
  else if ( herwigCode ==  128 )     {pdg = -12;}    
  else if ( herwigCode ==  123 )     {pdg =  13;}    
  else if ( herwigCode ==  129 )     {pdg = -13;}    
  else if ( herwigCode ==  124 )     {pdg =  14;}    
  else if ( herwigCode ==  130 )     {pdg = -14;}    
  else if ( herwigCode ==  125 )     {pdg =  15;}    
  else if ( herwigCode ==  131 )     {pdg = -15;}    
  else if ( herwigCode ==  126 )     {pdg =  16;}    
  else if ( herwigCode ==  132 )     {pdg = -16;}    
  else if ( herwigCode ==  13 )      {pdg =  21;}    
  else if ( herwigCode ==  59 )     {pdg =  22;}    
  else if ( herwigCode ==  200 )     {pdg =  23;}    
  else if ( herwigCode ==  198 )     {pdg =  24;}    
  else if ( herwigCode ==  199 )     {pdg = -24;}    
  else if ( herwigCode ==  201 )     {pdg =  25;} 
  else if ( herwigCode ==  204 )     {pdg =  35;} 
  else if ( herwigCode ==  205 )     {pdg =  36;}
  else if ( herwigCode ==  206 )     {pdg =  37;}    
  else if ( herwigCode ==  207 )     {pdg = -37;}    
  else if ( herwigCode ==  425 )     {pdg =  1000011;} 
  else if ( herwigCode ==  431 )     {pdg = -1000011;} 
  else if ( herwigCode ==  426 )     {pdg =  1000012;} 
  else if ( herwigCode ==  432 )     {pdg = -1000012;} 
  else if ( herwigCode ==  427 )     {pdg =  1000013;} 
  else if ( herwigCode ==  433 )     {pdg = -1000013;} 
  else if ( herwigCode ==  428 )     {pdg =  1000014;} 
  else if ( herwigCode ==  434 )     {pdg = -1000014;} 
  else if ( herwigCode ==  429 )     {pdg =  1000015;} 
  else if ( herwigCode ==  435 )     {pdg = -1000015;} 
  else if ( herwigCode ==  430 )     {pdg =  1000016;} 
  else if ( herwigCode ==  436 )     {pdg = -1000016;}
  else if ( herwigCode ==  437 )     {pdg =  2000011;} 
  else if ( herwigCode ==  443 )     {pdg = -2000011;}
  else if ( herwigCode ==  439 )     {pdg =  2000013;} 
  else if ( herwigCode ==  445 )     {pdg = -2000013;} 
  else if ( herwigCode ==  441 )     {pdg =  2000015;} 
  else if ( herwigCode ==  447 )     {pdg = -2000015;}
  else if ( herwigCode ==  450 )     {pdg =  1000022;} 
  else if ( herwigCode ==  451 )     {pdg =  1000023;} 
  else if ( herwigCode ==  454 )     {pdg =  1000024;} 
  else if ( herwigCode ==  456 )     {pdg = -1000024;} 
  else if ( herwigCode ==  452 )     {pdg =  1000025;} 
  else if ( herwigCode ==  453 )     {pdg =  1000035;} 
  else if ( herwigCode ==  455 )     {pdg =  1000037;} 
  else if ( herwigCode ==  457 )     {pdg = -1000037;} 
  else { 
    cout<<"ERROR: in TParticleCodeConverter::GetPdgFromHerwigCode, This herwigCode "<<herwigCode<<" was not implemented. Exit!"<<endl;
    exit(1);
  }
  return pdg;
}

int TParticleCodeConverter::GetPdgFromIsaCode(int isaCode) {
  int pdg;
  if      ( isaCode ==  2 )      {pdg =  1;}  
  else if ( isaCode == -2 )      {pdg = -1;}
  else if ( isaCode ==  1 )      {pdg =  2;}       
  else if ( isaCode == -1 )      {pdg = -2;}      
  else if ( isaCode ==  3 )      {pdg =  3;}      
  else if ( isaCode == -3 )      {pdg = -3;}       
  else if ( isaCode ==  4 )      {pdg =  4;}       
  else if ( isaCode == -4 )      {pdg = -4;}     
  else if ( isaCode ==  5 )      {pdg =  5;}     
  else if ( isaCode == -5 )      {pdg = -5;}     
  else if ( isaCode ==  6 )      {pdg =  6;}     
  else if ( isaCode == -6 )      {pdg = -6;}     
  else if ( isaCode ==  12 )     {pdg =  11;}    
  else if ( isaCode == -12 )     {pdg = -11;}    
  else if ( isaCode ==  11 )     {pdg =  12;}    
  else if ( isaCode == -11 )     {pdg = -12;}    
  else if ( isaCode ==  14 )     {pdg =  13;}    
  else if ( isaCode == -14 )     {pdg = -13;}    
  else if ( isaCode ==  13 )     {pdg =  14;}    
  else if ( isaCode == -13 )     {pdg = -14;}    
  else if ( isaCode ==  16 )     {pdg =  15;}    
  else if ( isaCode == -16 )     {pdg = -15;}    
  else if ( isaCode ==  15 )     {pdg =  16;}    
  else if ( isaCode == -15 )     {pdg = -16;}    
  else if ( isaCode ==  9 )      {pdg =  21;}    
  else if ( isaCode ==  10 )     {pdg =  22;}    
  else if ( isaCode ==  90 )     {pdg =  23;}    
  else if ( isaCode ==  80 )     {pdg =  24;}    
  else if ( isaCode == -80 )     {pdg = -24;}    
  else if ( isaCode ==  82 )     {pdg =  25;} 
  else if ( isaCode ==  83 )     {pdg =  35;} 
  else if ( isaCode ==  84 )     {pdg =  36;}
  else if ( isaCode ==  86 )     {pdg =  37;}    
  else if ( isaCode == -86 )     {pdg = -37;}    
  else if ( isaCode ==  22 )     {pdg =  1000001;}
  else if ( isaCode == -22 )     {pdg = -1000001;}
  else if ( isaCode ==  21 )     {pdg =  1000002;}
  else if ( isaCode == -21 )     {pdg = -1000002;}
  else if ( isaCode ==  23 )     {pdg =  1000003;}
  else if ( isaCode == -23 )     {pdg = -1000003;}
  else if ( isaCode ==  24 )     {pdg =  1000004;}
  else if ( isaCode == -24 )     {pdg = -1000004;}
  else if ( isaCode ==  25 )     {pdg =  1000005;}
  else if ( isaCode == -25 )     {pdg = -1000005;}
  else if ( isaCode ==  26 )     {pdg =  1000006;}
  else if ( isaCode == -26 )     {pdg = -1000006;}
  else if ( isaCode ==  32 )     {pdg =  1000011;} 
  else if ( isaCode == -32 )     {pdg = -1000011;} 
  else if ( isaCode ==  31 )     {pdg =  1000012;} 
  else if ( isaCode == -31 )     {pdg = -1000012;} 
  else if ( isaCode ==  34 )     {pdg =  1000013;} 
  else if ( isaCode == -34 )     {pdg = -1000013;} 
  else if ( isaCode ==  33 )     {pdg =  1000014;} 
  else if ( isaCode == -33 )     {pdg = -1000014;} 
  else if ( isaCode ==  36 )     {pdg =  1000015;} 
  else if ( isaCode == -36 )     {pdg = -1000015;} 
  else if ( isaCode ==  35 )     {pdg =  1000016;} 
  else if ( isaCode == -35 )     {pdg = -1000016;}
  else if ( isaCode ==  42 )     {pdg =  2000001;}
  else if ( isaCode == -42 )     {pdg = -2000001;}
  else if ( isaCode ==  41 )     {pdg =  2000002;}
  else if ( isaCode == -41 )     {pdg = -2000002;}
  else if ( isaCode ==  43 )     {pdg =  2000003;}
  else if ( isaCode == -43 )     {pdg = -2000003;}
  else if ( isaCode ==  44 )     {pdg =  2000004;}
  else if ( isaCode == -44 )     {pdg = -2000004;}
  else if ( isaCode ==  45 )     {pdg =  2000005;}
  else if ( isaCode == -45 )     {pdg = -2000005;}
  else if ( isaCode ==  46 )     {pdg =  2000006;}
  else if ( isaCode == -46 )     {pdg = -2000006;}
  else if ( isaCode ==  52 )     {pdg =  2000011;} 
  else if ( isaCode == -52 )     {pdg = -2000011;}
  else if ( isaCode ==  51 )     {pdg =  2000012;} 
  else if ( isaCode == -51 )     {pdg = -2000012;}
  else if ( isaCode ==  54 )     {pdg =  2000013;} 
  else if ( isaCode == -54 )     {pdg = -2000013;} 
  else if ( isaCode ==  53 )     {pdg =  2000014;} 
  else if ( isaCode == -53 )     {pdg = -2000014;}
  else if ( isaCode ==  56 )     {pdg =  2000015;} 
  else if ( isaCode == -56 )     {pdg = -2000015;}
  else if ( isaCode ==  55 )     {pdg =  2000016;} 
  else if ( isaCode == -55 )     {pdg = -2000016;}
  else if ( isaCode ==  29 )     {pdg =  1000021;} 
  else if ( isaCode ==  30 )     {pdg =  1000022;} 
  else if ( isaCode ==  40 )     {pdg =  1000023;} 
  else if ( isaCode ==  39 )     {pdg =  1000024;} 
  else if ( isaCode == -39 )     {pdg = -1000024;} 
  else if ( isaCode ==  50 )     {pdg =  1000025;} 
  else if ( isaCode ==  60 )     {pdg =  1000035;} 
  else if ( isaCode ==  49 )     {pdg =  1000037;} 
  else if ( isaCode == -49 )     {pdg = -1000037;} 
  else if ( isaCode ==  91 )     {pdg =  1000039;}
  else if ( isaCode ==  110 )    {pdg =  111;}
  else if ( isaCode ==  120 )    {pdg =  211;}
  else if ( isaCode == -120 )    {pdg = -211;}
  else { 
    cout<<"ERROR: in TParticleCodeConverter::GetPdgFromIsaCode, This isaCode "<<isaCode<<" was not implemented. Exit!"<<endl;
    exit(1);
  }
  return pdg;
}
