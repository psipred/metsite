#include <iomanip>
#include <sstream>
#include <iostream>
#include <fstream>
#include <string>
#include <cstdio>
#include <cstring>
#include <vector>
#include <cstdlib>
#include <cmath>
#include <map>

using namespace std;

const int PTH= 75;
const int PLEN =5000;
const int UCAP = 20;
const int CAP= 26;

enum amacid{ala, arg, asn, asp, cys,
               gln, glu, gly, his, ile,
               leu, lys, met, phe, pro,
               ser, thr, trp, tyr, val};

class protein {
   private:
     int arr[PLEN][UCAP], unarr[CAP];
     int plen;
     char seq[PLEN];
   public:
     protein(char path[]);
     void display(char name[]);
   };

protein::protein(char path[PTH])   {

   char buffer[PLEN];
   int temp;
   int count;

   ifstream infile(path);
   infile >> plen;

   for(int i=0; i<plen; i++)
      infile >> seq[i];

   for(int i=0; i<13; i++)  {

      infile.getline(buffer, PLEN);  //eat rubbish
      //cout << buffer << endl;

   }

   for(int i=0; i<plen; i++)   {
    
     count =0;
      for(int j=0; j<26; j++)   {
     
	infile >> temp;
	if(!(j==0 || j==2 || j==21 || j>22))
	  unarr[count++]=temp;
      }

      arr[i][ala]= unarr[0];
      arr[i][arg]= unarr[14];
      arr[i][asn]= unarr[11];
      arr[i][asp]= unarr[2];
      arr[i][cys]= unarr[1];
      arr[i][gln]= unarr[13];
      arr[i][glu]= unarr[3];
      arr[i][gly]= unarr[5];
      arr[i][his]= unarr[6];
      arr[i][ile]= unarr[7];
      arr[i][leu]= unarr[9];
      arr[i][lys]= unarr[8];
      arr[i][met]= unarr[10];
      arr[i][phe]= unarr[4];
      arr[i][pro]= unarr[12];
      arr[i][ser]= unarr[15];
      arr[i][thr]= unarr[16];
      arr[i][trp]= unarr[18];
      arr[i][tyr]= unarr[19];
      arr[i][val]= unarr[17];
      }
}

void protein::display(char name[])   {

  ofstream outfile;

   outfile.open(name);

   

   for(int i=0; i<plen; i++)   {
     outfile << setw(4) <<i+1 << " ";
     outfile << seq[i] << ' ';
      for(int j=0; j<UCAP; j++)   {
         outfile << setw(7) << arr[i][j];
         }
      outfile << endl;
      }
   }

int main(int argc, char* argv[]) {

  if(argc !=3){

    cerr << "ERROR" << endl;
    cerr << "mtx_pro .mtx .out" << endl;
    exit(1);
  }

   protein p1(argv[1]);  //stick input filename here(checkpoint file)
   p1.display(argv[2]);  //output file
   return 0;

   }

