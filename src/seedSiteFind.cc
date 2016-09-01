//Take in PDB and output a site patterns of neighbourhood CUTOFF with labels for input to MetPred

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

typedef float Point[3];

string file;
int cutoff;


void Split(const string& str,vector<string>& tokens,const string& delimiters = " ")
{
    string::size_type lastPos = str.find_first_not_of(delimiters, 0);

    string::size_type pos     = str.find_first_of(delimiters, lastPos);

    while (string::npos != pos || string::npos != lastPos)
    {

        tokens.push_back(str.substr(lastPos, pos - lastPos));

        lastPos = str.find_first_not_of(delimiters, pos);

        pos = str.find_first_of(delimiters, lastPos);
    }
}


/************ Dist bw 2 atoms ************/

double dist(Point point_1, Point point_2){

  int i=0;
  float x,y;
  double distnce;

  for(i=0; i<3; i++){

    x = point_1[i] - point_2[i];

    //cout << point_1[i] << "  " << point_2[i] << endl;

    y = x * x;

    //cout << y << endl;

    distnce += y;
  }

  distnce = sqrt(distnce);

  return distnce;
  

}

/********Sigmoid rescale temp between 0-1 *********/

double squash(double temp){


  double num;

  temp = temp/100;

  temp  = exp(temp);

  temp = 1 + temp;
  num = 1/temp;

  num = 1-num;
  return num;
}

struct Dist{
      
  int resNum;
  double dist;
  int key;
  string resName;
  Point xyz;
  int atomnum;
  int seqresNum;
      
};
  
  
struct Profile {

  string resCode;
  int pos;
  vector<double> numsV;
  double max;
  int pos2;
  

};
  
struct Atom{
  string atomName;
  string resName;
  int resNum;
  string chain;
  int atomNum;
  float distance;
  Point xyz;
  double bfac;	
  vector<Dist> distV;
  int cls;
  int seed;
  vector<double> psiV;
  int seqresNum;
  string structure;
  string code;
  int acc;
  vector<int> ligV;
};


void psi(int pos, vector<Atom>& atomV,map<int,Profile>& mapPro, ostringstream& out){

  int resnm;
   
  for(int j=0; j<cutoff; j++){

    resnm = atomV[pos].distV[j].seqresNum;

    //out << atomV[pos].distV[j].seqresNum << " ";

    for(int m=0; m<mapPro[resnm].numsV.size();m++){
      out << squash(mapPro[resnm].numsV[m]) << " ";
      //      cout << mapPro[resnm].numsV[m] << " ";
    }
    //    cout << endl;
  }
}
void dist_sort(int pos, vector<Atom>& atomV){

  string resName;
  int resNum;
  double distance;
  int key;
  Point xyz;

  for(int i=0; i<atomV[pos].distV.size(); i++){

    for(int j=i+1; j<atomV[pos].distV.size(); j++){

      if(atomV[pos].distV[i].dist > atomV[pos].distV[j].dist){

	resName = atomV[pos].distV[j].resName;
	atomV[pos].distV[j].resName = atomV[pos].distV[i].resName;
	atomV[pos].distV[i].resName = resName;

	resNum = atomV[pos].distV[j].resNum;
	atomV[pos].distV[j].resNum = atomV[pos].distV[i].resNum;
	atomV[pos].distV[i].resNum = resNum;

	resNum = atomV[pos].distV[j].atomnum;
	atomV[pos].distV[j].atomnum = atomV[pos].distV[i].atomnum;
	atomV[pos].distV[i].atomnum = resNum;

	resNum = atomV[pos].distV[j].seqresNum;
	atomV[pos].distV[j].seqresNum = atomV[pos].distV[i].seqresNum;
	atomV[pos].distV[i].seqresNum = resNum;

	key = atomV[pos].distV[j].key;
	atomV[pos].distV[j].key = atomV[pos].distV[i].key;
	atomV[pos].distV[i].key = key;

	distance = atomV[pos].distV[j].dist;
	atomV[pos].distV[j].dist = atomV[pos].distV[i].dist;
	atomV[pos].distV[i].dist = distance;

	xyz[0] = atomV[pos].distV[j].xyz[0];
	atomV[pos].distV[j].xyz[0] = atomV[pos].distV[i].xyz[0];
	atomV[pos].distV[i].xyz[0] = xyz[0];

	xyz[1] = atomV[pos].distV[j].xyz[1];
	atomV[pos].distV[j].xyz[1] = atomV[pos].distV[i].xyz[1];
	atomV[pos].distV[i].xyz[1] = xyz[1];

	xyz[0] = atomV[pos].distV[j].xyz[2];
	atomV[pos].distV[j].xyz[2] = atomV[pos].distV[i].xyz[2];
	atomV[pos].distV[i].xyz[2] = xyz[2];




      }


    }
  }

}

void geom(int pos, vector<Atom>& atomV,ostringstream& out){

  Point ca_atom,test;

  for(int j=0; j<cutoff; j++){

    ca_atom[0] = atomV[pos].distV[j].xyz[0];
    ca_atom[1] = atomV[pos].distV[j].xyz[1];
    ca_atom[2] = atomV[pos].distV[j].xyz[2];
    
    for(int k=j+1; k<cutoff; k++){

      test[0] = atomV[pos].distV[k].xyz[0];
      test[1] = atomV[pos].distV[k].xyz[1];
      test[2] = atomV[pos].distV[k].xyz[2];

      if(dist(ca_atom,test) > 200){ 
	//out << "**"<< file << endl;
      }
      out <<squash(dist(ca_atom,test))<<" ";
    }
    //ut << atomV[pos].cls << " ";
    
  }
}

void solv_out(int pos, vector<Atom>& atomV, map<double,Atom>& atom_map,ostringstream& out){

  for(int j=0; j<cutoff; j++){
    out << squash(atom_map[atomV[pos].distV[j].atomnum].acc) << " ";
    //cout << atom_map[hetV[pos].distMV[j].atomnum].bfac << " ";
  }
	
}

void struc_out(int pos, vector<Atom>& atomV, map<double,Atom>& atom_map, ostringstream& out){
	
  string struc;

  for(int j=0; j<cutoff; j++){
	   
    struc = atom_map[atomV[pos].distV[j].atomnum].structure;

    if(struc == "H" || struc == "I" || struc == "G"){
      
      out << 1 << " " << 0 <<" " <<  0 << " ";
      
    }

    if(struc == "E" || struc == "B"){

      out << 0 << " " << 1 <<" " <<  0 << " ";
    }

    if(struc == "C"){

      out << 0 << " " << 0 <<" " <<  1 << " ";

    }

    if(struc == "T" || struc == "S" ||  struc == " "){

        out << 0 << " " << 0 <<" " <<  1 << " ";

    }

	   
    //cout <<  atom_map[atomV[pos].distV[j].atomnum].structure << "*";

    // cout << atom_map[hetV[i].distMV[j].atomnum].acc << " ";
  }
   
}


/********************************************
*                                           *
*          M   A   I   N                    * 
*                                           *  
*********************************************/




int main(int argc, char* argv[]){

  //d.buchan: we've added a chain ID thing too so we only read in data from a 
  //given chain
  if (argc != 7) {
    cerr << "Command Line Error" << endl;
    cerr << "Example usage: ./prog code.pdb type cut code.pro code.dssp chainID" << endl;
    exit(1);
  }
  
  ifstream infile(argv[1]);
  if (!infile) {
    cerr << "cannot open file " << argv[1] << endl;
    exit(1);
  }
 
  string line;
  string chain;
  int num;
  string atom;
  Atom atoms;
  vector<Atom> atomV;
  vector<Atom> hetV;
  map <double,Atom> atom_map;

  string metType = argv[2];
  cutoff = atoi(argv[3]);
  //d.buchan assign chainID variable
  string chainID = argv[6];
  file = argv[1];

  string pdb = argv[1];
  string pdbc = pdb.substr(0,pdb.length()-4);


  int siteSize = cutoff;

  int geomD = (siteSize * (siteSize-1))/2;

  int sizeT = 3*siteSize + siteSize + geomD + 20*siteSize;


    /******* CB atoms only + atoms of specified ligand **********/

  int check_cunt=0;
  string resname;

 
  int resnm;

  map<string,int> seedResMap;
  
  
  /** BEGIN PARSING PDB FILE **/
  while (getline(infile,line))
  {

	//cout << line << endl;
    if(line.substr(0,4) == "EXPD")
	{
      //    cout << line << endl;
      //cout << line.substr(10,3) << "*" << endl;
      if(line.substr(10,3) == "NMR")
	  {
		//cout << line << endl;
		//	exit(1);
	  }

    }

    if(line.substr(0,4) == "ATOM")
	{
		//d.buchan ok, we only want to read in data from the chain we care about
		if(line.substr(21,1) != chainID)
		{
			continue;
		}
		
	  atom = line.substr(13,3); 
	  resname = line.substr(17,3);
	  if(atom == "CB ")
	  {
	  	atoms.atomName = line.substr(13,3);
		//d.buchan fixed this point where it reads in only 3 chracters from the residue number
		//atoms.resNum = atoi(line.substr(23,3).c_str());
		//cout << "Initial: " << atoms.resNum << endl;
		atoms.resNum = atoi(line.substr(22,4).c_str());
		//cout << "InitialSec: " << atoms.resNum << endl;
	
		atoms.atomNum = atoi(line.substr(7,6).c_str());
		atoms.resName=line.substr(17,3);
		atoms.xyz[0]=atof(line.substr(30,8).c_str());    
		atoms.xyz[1]=atof(line.substr(38,8).c_str());   
		atoms.xyz[2]=atof(line.substr(46,8).c_str());
		atoms.cls =0;
		atoms.seqresNum = atomV.size()+1;
	
		seedResMap[atoms.resName] = 0;
	
		num = atoms.atomNum;
		atomV.push_back(atoms);
      
		atom_map[num] = atoms;
		//atom_map[atoms.resNum] = atoms;
      }
      
      if(resname == "GLY" && atom == "CA ")
	  {
	  	atoms.atomName = line.substr(13,3);
		//d.buchan fixed this point where it reads in only 3 chracters from the residue number
		//atoms.resNum = atoi(line.substr(23,3).c_str());
		//cout << "Alt: " << atoms.resNum << endl;
		atoms.resNum = atoi(line.substr(22,4).c_str());
		//cout << "Alt: " << atoms.resNum << endl;
	
		atoms.atomNum = atoi(line.substr(7,6).c_str());
		atoms.resName=line.substr(17,3);
		atoms.xyz[0]=atof(line.substr(30,8).c_str());    
		atoms.xyz[1]=atof(line.substr(38,8).c_str());   
		atoms.xyz[2]=atof(line.substr(46,8).c_str());
		atoms.distance = 100;
		atoms.bfac = atof(line.substr(60,8).c_str());
        atoms.cls =0;
		atoms.seqresNum = atomV.size()+1;
		num = atoms.atomNum;
		atomV.push_back(atoms);
		
		//seedResMap[atoms.resName] = 0;
		
		atom_map[num] = atoms;
		//atom_map[atoms.resNum] = atoms;
      }
    }
	//cout << num << endl;
  }
  /** FINISH PARSING PDB FILE **/
  
  infile.close();
    
  Point p1,p2;
  double distance;
  Dist distdat;
  int i,j;
  //cout << hetV.size() << endl;

  /************* Set Seed ResID's *******/

  if(metType == "_CA"){
    seedResMap["ASP"] = 1;
    seedResMap["GLU"] = 1;
    seedResMap["GLN"] = 1;
    seedResMap["THR"] = 1;
    seedResMap["GLY"] = 1;
    seedResMap["SER"] = 1;
    seedResMap["ASN"] = 1;
  }

   if(metType == "_CU"){
    seedResMap["CYS"] = 1;
    seedResMap["HIS"] = 1;
    seedResMap["GLY"] = 1;
    seedResMap["MET"] = 1;
 
  }

 if(metType == "_MN"){
    seedResMap["ASP"] = 1;
    seedResMap["GLU"] = 1;
    seedResMap["GLY"] = 1;
    seedResMap["HIS"] = 1;
  }

 if(metType == "_FE"){
    seedResMap["CYS"] = 1;
    seedResMap["MET"] = 1;
    seedResMap["GLY"] = 1;
    seedResMap["HIS"] = 1;
  }

 if(metType == "_ZN"){
   seedResMap["ASP"] = 1;
   seedResMap["CYS"] = 1;
   seedResMap["GLY"] = 1;
   seedResMap["GLU"] = 1;
   seedResMap["ARG"] = 1;
   seedResMap["HIS"] = 1;
 }

 if(metType == "_MG"){
   seedResMap["ASP"] = 1;
   seedResMap["GLU"] = 1;
   seedResMap["GLY"] = 1;
   seedResMap["SER"] = 1;
   seedResMap["THR"] = 1;
 }
            
 
  
/************* Assign psi-blast profile no. *****************/

 string prof = argv[4];
 
 ifstream inpro(prof.c_str());;
 

 vector<string> tokens;
 vector<double> numsV;
 double nums;
 vector<string> resacross;
 int pos;
 int k;
 string line2;
 Profile data;
 vector<Profile> dataV;
 map<int,Profile> mapPro;
 string tempo;


 int min_res = atomV[0].resNum;
 
 //cout << atomV.size() << endl;

 /** BEGING PSI-BLAST PROFILE PARSING **/
 while (getline(inpro,line))
 {

   //dbuchan, errrr, this was never correctly reading the residue code
   data.resCode = line.substr(5,1);
   //data.resCode = line.substr(4,1);
   
   //dbuchan, likewise this was totally misparsing the residue numbering
   data.pos = atoi(line.substr(0,4).c_str());
   //data.pos = atoi(line.substr(0,3).c_str());
   
   //   data.pos = data.pos + min_res;
   //data.pos = data.pos -1;
   //   cout << data.pos << "  " << data.resCode << endl;
   
   line = line.substr(8,140);
   //cout << line << endl;
   Split(line, tokens);

   //cout <<"*"<< data.pos <<"*"<< endl;
   for(j=0; j<tokens.size(); j++)
   {
	 tempo = tokens[j];
	  nums = atof(tempo.c_str());
	 //cout << nums << endl;
	 //nums = nums/100;
	 //nums = squash(nums);
 	 //nums = 1-nums;
	
	 //atomV[data.pos-1].psiV.push_back(nums);
	 data.numsV.push_back(nums);
   }

     mapPro[data.pos] = data;
     dataV.push_back(data);
     tokens.clear();
     data.numsV.clear();
 }
 /** FINISH PBD PROFILE PARSING **/
 
 
 //cout << mapPro[5].resCode << "  " << mapPro[5].numsV[3] << endl;
 //cout << atomV[2].psiV[8] <<"*"<< endl;

 /***************************************************************/


 string dssp_id = argv[5];
  

  /********* Extract information for each residue stored from DSSP file **********/
   

 ifstream infi(dssp_id.c_str());
 string line_two, struc;
 int res_number;
 int solv;
 string code ="";
 string null=" ";

 chain = "";

 i=0;
 /** BEGIN PARSING DSSP FILE **/
 while (getline(infi,line_two))
 {

   if(line_two.substr(2,1)=="#")
   {
     getline(infi,line_two);
     i=11;
   }

   if(i==11)
   {
     
	 chain = line_two.substr(11,1);
	 //cout << chain << endl;
	 //d.buchan: skip the chain we are not interested in
     if(chain != chainID){continue;}
	 
     if(chain == " ")
	 {
        chain = "0";
     }
	
	 if(line_two.substr(9,1)!= " ")
	 {//test if there is a number in the residue number position and only parse if that is the case
       
	   struc = line_two.substr(16,1);
	   if(struc == " ")
	   {	 
		 struc = "C";
       }
 
	   //d.buchan fixed this point where it reads in only 3 characters from the residue number
	   res_number = atoi(line_two.substr(6,4).c_str());
	   
	   solv = atoi(line_two.substr(35,3).c_str());
       code = line_two.substr(13,1);
	   //cout << code << endl;
	   
       //cout << line_two << endl;
        
       
	   for(j=1;j<=atomV.size();j++)
	   {
	      if(res_number == atomV[j].resNum)
		  {
	   	   atomV[j].structure = struc;
	  	   atomV[j].code = code;
	   	   atomV[j].acc = solv;
		   
		   atom_map[atomV[j].atomNum] = atomV[j];
		  }
	   	}

      }
    } 
 }
 /** STOP PARSING DSSP FILE **/
 
 
 /*************************************************/

/****** Check if residue is within interacting distance of target Het Group ***************/


   for(int j=0; j<hetV.size(); ++j)
   {
      p1[0] = hetV[j].xyz[0];
      p1[1] = hetV[j].xyz[1];
      p1[2] = hetV[j].xyz[2];

     for(int i=0; i < atomV.size(); ++i)
	 {
      p2[0] = atomV[i].xyz[0];
      p2[1] = atomV[i].xyz[1];
      p2[2] = atomV[i].xyz[2];

      distance = dist(p1,p2);

      if(distance < 7.1)
	  {
		//cout << atomV[i].resNum << endl;
		hetV[j].distance = distance;
		hetV[j].seed = i;
		atomV[i].cls = 1;
		atomV[i].seed = hetV[j].resNum;
      }
     } 
   }


   /*
   for(int j=0; j<hetV.size(); ++j){

     atomV[hetV[j].seed].cls =1;
     atomV[hetV[j].seed].seed = hetV[j].resNum;
 // cout << atomV[hetV[j].seed].resNum << endl;
   }
   */


 /************ DISTANCE MATRIX ****************/ 

 int ckpnt=0;

  for(int i=0; i < atomV.size(); ++i){
  
      p1[0] = atomV[i].xyz[0];
      p1[1] = atomV[i].xyz[1];
      p1[2] = atomV[i].xyz[2];
      
      for(int j=0; j < atomV.size(); ++j){
  
	p2[0] = atomV[j].xyz[0];
	p2[1] = atomV[j].xyz[1];
	p2[2] = atomV[j].xyz[2];
	
	distance = dist(p1,p2);
	
	if(distance < 15) {
	
	  distdat.resNum = atomV[j].resNum;
	  distdat.resName = atomV[j].resName;
	  distdat.key = j;
	  distdat.dist= distance;
	  distdat.xyz[0] = atomV[j].xyz[0];
	  distdat.xyz[1] = atomV[j].xyz[1];
	  distdat.xyz[2] = atomV[j].xyz[2];
	  distdat.atomnum = atomV[j].atomNum;
	  distdat.seqresNum = atomV[j].seqresNum;
	  
	  atomV[i].distV.push_back(distdat);
	    
	}
      }
	dist_sort(i,atomV);
  }  


  string patsp = pdb + ".DATA";

  string patsn = pdb + ".neg";

  ofstream outSI(patsp.c_str());


  vector<string> checkV;

  int count =0;

  //cout << atomV.size() << endl;
  for(int i=0; i < atomV.size(); ++i){
	//cout << i;
	if(seedResMap[atomV[i].resName] == 1){
		//cout << " here" << atomV[i].resName << atomV[i].resNum << endl;
      ostringstream outn;
      outn.precision(4);

      struc_out(i,atomV,atom_map,outn);	
      geom(i,atomV,outn);
      solv_out(i,atomV,atom_map,outn);
      psi(i,atomV,mapPro,outn);

      string t = outn.str();


      Split(t,checkV);
		//cout << checkV.size() << " " << sizeT << endl;	 
      if(checkV.size() == sizeT){

	 	outSI << atomV[i].resName << atomV[i].resNum << " " << outn.str() << endl;
			 
      }
	  

    	 
    checkV.clear();		
    }

  }    


  //END of Script

}
 

 












