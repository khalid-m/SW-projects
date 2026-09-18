//////////////////////////////////////////////////////////
//   This class has been automatically generated 
//     (Wed Aug 13 12:29:32 2003 by ROOT version3.05/05)
//   from TTree h51/Atlfast51
//   found on file: NTUPLES/signal100000Events.root
//////////////////////////////////////////////////////////


#ifndef TTreeClass_h
#define TTreeClass_h

#include <TROOT.h>
#include <TChain.h>
#include <TFile.h>

class TTreeClass {
   public :
   TTree          *fChain;   //!pointer to the analyzed TTree or TChain
   Int_t           fCurrent; //!current Tree number in a TChain
//Declaration of leaves types
   Int_t           Nele;
   Int_t           Kfele[12];   //[Nele]
   Float_t         Pxele[12];   //[Nele]
   Float_t         Pyele[12];   //[Nele]
   Float_t         Pzele[12];   //[Nele]
   Float_t         Eeele[12];   //[Nele]
   Int_t           Nmuo;
   Int_t           Kfmuo[12];   //[Nmuo]
   Float_t         Pxmuo[12];   //[Nmuo]
   Float_t         Pymuo[12];   //[Nmuo]
   Float_t         Pzmuo[12];   //[Nmuo]
   Float_t         Eemuo[12];   //[Nmuo]
   Int_t           Npho;
   Int_t           Kfpho[12];   //[Npho]
   Float_t         Pxpho[12];   //[Npho]
   Float_t         Pypho[12];   //[Npho]
   Float_t         Pzpho[12];   //[Npho]
   Float_t         Eepho[12];   //[Npho]
   Int_t           Nmux;
   Int_t           Kfmux[12];   //[Nmux]
   Float_t         Pxmux[12];   //[Nmux]
   Float_t         Pymux[12];   //[Nmux]
   Float_t         Pzmux[12];   //[Nmux]
   Float_t         Eemux[12];   //[Nmux]
   Int_t           Njet;
   Int_t           Kfjet[40];   //[Njet]
   Float_t         Pxjet[40];   //[Njet]
   Float_t         Pyjet[40];   //[Njet]
   Float_t         Pzjet[40];   //[Njet]
   Float_t         Eejet[40];   //[Njet]
   Float_t         Ptcalo[40];   //[Njet]
   Float_t         Ptbjet[40];   //[Njet]
   Float_t         Ptujet[40];   //[Njet]
   Int_t           Njetb;
   Int_t           Kfjetb[40];   //[Njetb]
   Float_t         Pxjetb[40];   //[Njetb]
   Float_t         Pyjetb[40];   //[Njetb]
   Float_t         Pzjetb[40];   //[Njetb]
   Float_t         Eejetb[40];   //[Njetb]
   Int_t           Npart;
   Int_t           Kppart[40];   //[Npart]
   Int_t           Kspart[40];   //[Npart]
   Int_t           Kfpart[40];   //[Npart]
   Int_t           Kpmoth[40];   //[Npart]
   Int_t           Kfmoth[40];   //[Npart]
   Float_t         Pxpart[40];   //[Npart]
   Float_t         Pypart[40];   //[Npart]
   Float_t         Pzpart[40];   //[Npart]
   Float_t         Eepart[40];   //[Npart]
   Int_t           Isub;
   Int_t           Jetb;
   Int_t           Jetc;
   Int_t           Jettau;
   Float_t         Pxmiss;
   Float_t         Pymiss;
   Float_t         Pxnue;
   Float_t         Pynue;

//List of branches
   TBranch        *b_Nele;   //!
   TBranch        *b_Kfele;   //!
   TBranch        *b_Pxele;   //!
   TBranch        *b_Pyele;   //!
   TBranch        *b_Pzele;   //!
   TBranch        *b_Eeele;   //!
   TBranch        *b_Nmuo;   //!
   TBranch        *b_Kfmuo;   //!
   TBranch        *b_Pxmuo;   //!
   TBranch        *b_Pymuo;   //!
   TBranch        *b_Pzmuo;   //!
   TBranch        *b_Eemuo;   //!
   TBranch        *b_Npho;   //!
   TBranch        *b_Kfpho;   //!
   TBranch        *b_Pxpho;   //!
   TBranch        *b_Pypho;   //!
   TBranch        *b_Pzpho;   //!
   TBranch        *b_Eepho;   //!
   TBranch        *b_Nmux;   //!
   TBranch        *b_Kfmux;   //!
   TBranch        *b_Pxmux;   //!
   TBranch        *b_Pymux;   //!
   TBranch        *b_Pzmux;   //!
   TBranch        *b_Eemux;   //!
   TBranch        *b_Njet;   //!
   TBranch        *b_Kfjet;   //!
   TBranch        *b_Pxjet;   //!
   TBranch        *b_Pyjet;   //!
   TBranch        *b_Pzjet;   //!
   TBranch        *b_Eejet;   //!
   TBranch        *b_Ptcalo;   //!
   TBranch        *b_Ptbjet;   //!
   TBranch        *b_Ptujet;   //!
   TBranch        *b_Njetb;   //!
   TBranch        *b_Kfjetb;   //!
   TBranch        *b_Pxjetb;   //!
   TBranch        *b_Pyjetb;   //!
   TBranch        *b_Pzjetb;   //!
   TBranch        *b_Eejetb;   //!
   TBranch        *b_Npart;   //!
   TBranch        *b_Kppart;   //!
   TBranch        *b_Kspart;   //!
   TBranch        *b_Kfpart;   //!
   TBranch        *b_Kpmoth;   //!
   TBranch        *b_Kfmoth;   //!
   TBranch        *b_Pxpart;   //!
   TBranch        *b_Pypart;   //!
   TBranch        *b_Pzpart;   //!
   TBranch        *b_Eepart;   //!
   TBranch        *b_Isub;   //!
   TBranch        *b_Jetb;   //!
   TBranch        *b_Jetc;   //!
   TBranch        *b_Jettau;   //!
   TBranch        *b_Pxmiss;   //!
   TBranch        *b_Pymiss;   //!
   TBranch        *b_Pxnue;   //!
   TBranch        *b_Pynue;   //!

   TTreeClass(TTree *tree=0);
   ~TTreeClass();
   Int_t  Cut(Int_t entry);
   Int_t  GetEntry(Int_t entry);
   Int_t  LoadTree(Int_t entry);
   void   Init(TTree *tree);
   void   Loop();
   Bool_t Notify();
   void   Show(Int_t entry = -1);
};

#endif

#ifdef TTreeClass_cxx
TTreeClass::TTreeClass(TTree *tree)
{
// if parameter tree is not specified (or zero), connect the file
// used to generate this class and read the Tree.
   if (tree == 0) {
      TFile *f = (TFile*)gROOT->GetListOfFiles()->FindObject("NTUPLES/signal100000Events.root");
      if (!f) {
         f = new TFile("NTUPLES/signal100000Events.root");
         f->cd("NTUPLES/signal100000Events.root:/ATLFAST");
      }
      tree = (TTree*)gDirectory->Get("h51");

   }
   Init(tree);
}

TTreeClass::~TTreeClass()
{
   if (!fChain) return;
   delete fChain->GetCurrentFile();
}

Int_t TTreeClass::GetEntry(Int_t entry)
{
// Read contents of entry.
   if (!fChain) return 0;
   return fChain->GetEntry(entry);
}
Int_t TTreeClass::LoadTree(Int_t entry)
{
// Set the environment to read one entry
   if (!fChain) return -5;
   Int_t centry = fChain->LoadTree(entry);
   if (centry < 0) return centry;
   if (fChain->IsA() != TChain::Class()) return centry;
   TChain *chain = (TChain*)fChain;
   if (chain->GetTreeNumber() != fCurrent) {
      fCurrent = chain->GetTreeNumber();
      Notify();
   }
   return centry;
}

void TTreeClass::Init(TTree *tree)
{
//   Set branch addresses
   if (tree == 0) return;
   fChain    = tree;
   fCurrent = -1;
   fChain->SetMakeClass(1);

   fChain->SetBranchAddress("Nele",&Nele);
   fChain->SetBranchAddress("Kfele",Kfele);
   fChain->SetBranchAddress("Pxele",Pxele);
   fChain->SetBranchAddress("Pyele",Pyele);
   fChain->SetBranchAddress("Pzele",Pzele);
   fChain->SetBranchAddress("Eeele",Eeele);
   fChain->SetBranchAddress("Nmuo",&Nmuo);
   fChain->SetBranchAddress("Kfmuo",Kfmuo);
   fChain->SetBranchAddress("Pxmuo",Pxmuo);
   fChain->SetBranchAddress("Pymuo",Pymuo);
   fChain->SetBranchAddress("Pzmuo",Pzmuo);
   fChain->SetBranchAddress("Eemuo",Eemuo);
   fChain->SetBranchAddress("Npho",&Npho);
   fChain->SetBranchAddress("Kfpho",Kfpho);
   fChain->SetBranchAddress("Pxpho",Pxpho);
   fChain->SetBranchAddress("Pypho",Pypho);
   fChain->SetBranchAddress("Pzpho",Pzpho);
   fChain->SetBranchAddress("Eepho",Eepho);
   fChain->SetBranchAddress("Nmux",&Nmux);
   fChain->SetBranchAddress("Kfmux",Kfmux);
   fChain->SetBranchAddress("Pxmux",Pxmux);
   fChain->SetBranchAddress("Pymux",Pymux);
   fChain->SetBranchAddress("Pzmux",Pzmux);
   fChain->SetBranchAddress("Eemux",Eemux);
   fChain->SetBranchAddress("Njet",&Njet);
   fChain->SetBranchAddress("Kfjet",Kfjet);
   fChain->SetBranchAddress("Pxjet",Pxjet);
   fChain->SetBranchAddress("Pyjet",Pyjet);
   fChain->SetBranchAddress("Pzjet",Pzjet);
   fChain->SetBranchAddress("Eejet",Eejet);
   fChain->SetBranchAddress("Ptcalo",Ptcalo);
   fChain->SetBranchAddress("Ptbjet",Ptbjet);
   fChain->SetBranchAddress("Ptujet",Ptujet);
   fChain->SetBranchAddress("Njetb",&Njetb);
   fChain->SetBranchAddress("Kfjetb",Kfjetb);
   fChain->SetBranchAddress("Pxjetb",Pxjetb);
   fChain->SetBranchAddress("Pyjetb",Pyjetb);
   fChain->SetBranchAddress("Pzjetb",Pzjetb);
   fChain->SetBranchAddress("Eejetb",Eejetb);
   fChain->SetBranchAddress("Npart",&Npart);
   fChain->SetBranchAddress("Kppart",Kppart);
   fChain->SetBranchAddress("Kspart",Kspart);
   fChain->SetBranchAddress("Kfpart",Kfpart);
   fChain->SetBranchAddress("Kpmoth",Kpmoth);
   fChain->SetBranchAddress("Kfmoth",Kfmoth);
   fChain->SetBranchAddress("Pxpart",Pxpart);
   fChain->SetBranchAddress("Pypart",Pypart);
   fChain->SetBranchAddress("Pzpart",Pzpart);
   fChain->SetBranchAddress("Eepart",Eepart);
   fChain->SetBranchAddress("Isub",&Isub);
   fChain->SetBranchAddress("Jetb",&Jetb);
   fChain->SetBranchAddress("Jetc",&Jetc);
   fChain->SetBranchAddress("Jettau",&Jettau);
   fChain->SetBranchAddress("Pxmiss",&Pxmiss);
   fChain->SetBranchAddress("Pymiss",&Pymiss);
   fChain->SetBranchAddress("Pxnue",&Pxnue);
   fChain->SetBranchAddress("Pynue",&Pynue);
   Notify();
}

Bool_t TTreeClass::Notify()
{
   // Called when loading a new file.
   // Get branch pointers.
   b_Nele = fChain->GetBranch("Nele");
   b_Kfele = fChain->GetBranch("Kfele");
   b_Pxele = fChain->GetBranch("Pxele");
   b_Pyele = fChain->GetBranch("Pyele");
   b_Pzele = fChain->GetBranch("Pzele");
   b_Eeele = fChain->GetBranch("Eeele");
   b_Nmuo = fChain->GetBranch("Nmuo");
   b_Kfmuo = fChain->GetBranch("Kfmuo");
   b_Pxmuo = fChain->GetBranch("Pxmuo");
   b_Pymuo = fChain->GetBranch("Pymuo");
   b_Pzmuo = fChain->GetBranch("Pzmuo");
   b_Eemuo = fChain->GetBranch("Eemuo");
   b_Npho = fChain->GetBranch("Npho");
   b_Kfpho = fChain->GetBranch("Kfpho");
   b_Pxpho = fChain->GetBranch("Pxpho");
   b_Pypho = fChain->GetBranch("Pypho");
   b_Pzpho = fChain->GetBranch("Pzpho");
   b_Eepho = fChain->GetBranch("Eepho");
   b_Nmux = fChain->GetBranch("Nmux");
   b_Kfmux = fChain->GetBranch("Kfmux");
   b_Pxmux = fChain->GetBranch("Pxmux");
   b_Pymux = fChain->GetBranch("Pymux");
   b_Pzmux = fChain->GetBranch("Pzmux");
   b_Eemux = fChain->GetBranch("Eemux");
   b_Njet = fChain->GetBranch("Njet");
   b_Kfjet = fChain->GetBranch("Kfjet");
   b_Pxjet = fChain->GetBranch("Pxjet");
   b_Pyjet = fChain->GetBranch("Pyjet");
   b_Pzjet = fChain->GetBranch("Pzjet");
   b_Eejet = fChain->GetBranch("Eejet");
   b_Ptcalo = fChain->GetBranch("Ptcalo");
   b_Ptbjet = fChain->GetBranch("Ptbjet");
   b_Ptujet = fChain->GetBranch("Ptujet");
   b_Njetb = fChain->GetBranch("Njetb");
   b_Kfjetb = fChain->GetBranch("Kfjetb");
   b_Pxjetb = fChain->GetBranch("Pxjetb");
   b_Pyjetb = fChain->GetBranch("Pyjetb");
   b_Pzjetb = fChain->GetBranch("Pzjetb");
   b_Eejetb = fChain->GetBranch("Eejetb");
   b_Npart = fChain->GetBranch("Npart");
   b_Kppart = fChain->GetBranch("Kppart");
   b_Kspart = fChain->GetBranch("Kspart");
   b_Kfpart = fChain->GetBranch("Kfpart");
   b_Kpmoth = fChain->GetBranch("Kpmoth");
   b_Kfmoth = fChain->GetBranch("Kfmoth");
   b_Pxpart = fChain->GetBranch("Pxpart");
   b_Pypart = fChain->GetBranch("Pypart");
   b_Pzpart = fChain->GetBranch("Pzpart");
   b_Eepart = fChain->GetBranch("Eepart");
   b_Isub = fChain->GetBranch("Isub");
   b_Jetb = fChain->GetBranch("Jetb");
   b_Jetc = fChain->GetBranch("Jetc");
   b_Jettau = fChain->GetBranch("Jettau");
   b_Pxmiss = fChain->GetBranch("Pxmiss");
   b_Pymiss = fChain->GetBranch("Pymiss");
   b_Pxnue = fChain->GetBranch("Pxnue");
   b_Pynue = fChain->GetBranch("Pynue");
   return kTRUE;
}

void TTreeClass::Show(Int_t entry)
{
// Print contents of entry.
// If entry is not specified, print current entry
   if (!fChain) return;
   fChain->Show(entry);
}
Int_t TTreeClass::Cut(Int_t entry)
{
// This function may be called from Loop.
// returns  1 if entry is accepted.
// returns -1 otherwise.
   return 1;
}
#endif // #ifdef TTreeClass_cxx

