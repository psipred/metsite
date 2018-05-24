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


double logsig(double x){


  double a = 1 + exp(-x);

  double xsq = 1/a;

  return xsq;

}

double tansig(double x){

  double a = 1 + exp(-2*x);
  double xsq = 2/a;
  xsq = xsq -1;

  return xsq;

}

struct Patts{

  vector<double> inpatV;
  int patNo;
  string pdb;
  string resS;
};

struct Weights{

  vector<double> weightsV;

};


struct Atom{

  string atomName;
  string resName;
  int resNum;
  string chain;
  int atomNum;
  Point xyz;
  double bfac;

};


/******** HIDDEN LAYER WEIGHTS *********/

map <int,Weights> mapIL;
map <int,double> mapBias;

vector<double> hidLayCalc(vector<double> patV){

  vector<double> hidLayer(25,0);

  for(int i=0; i<hidLayer.size(); ++i){

    Weights IL = mapIL[i+1];

      for(int j=0; j<patV.size(); ++j){

	double update =  patV[j] * IL.weightsV[j];

	hidLayer[i]+=update;


    }
  }

  for(int i=0; i<hidLayer.size(); ++i){

    hidLayer[i] += mapBias[i+1];

    hidLayer[i] = tansig(hidLayer[i]);
    //   cout << hidLayer[i] << endl;

  }

  return hidLayer;
}

/******************/
/****** MAIN ******/
/******************/

int main(int argc, char* argv[]){

	//d.buchan; added input for the chain ID we care about
  if (argc != 7) {

    cerr << "Command Line Error" << endl;
    cerr << "Example usage: ./prog query Metalname Cut-off out chain data_path" << endl;
    exit(1);
  }

  string chainID = argv[5];
  string met = argv[2];
  string name = "";

 ifstream infile(argv[1]);
  if (!infile) {
    cerr << "cannot open file query " << argv[1] << endl;
    exit(1);
  }

  name = argv[6]+met+"_.IL";

  ifstream infileIL(name.c_str());
  if (!infileIL) {
    cerr << "cannot open file ILweights: " << name << endl;
    exit(1);
  }

  name = argv[6]+met+"_.OL";
  ifstream infileOL(name.c_str());
  if (!infileOL) {
    cerr << "cannot open file OLweigths: " << name << endl;
    exit(1);
  }

  name = argv[6]+met+"_.BI";

  ifstream infileBI(name.c_str());
  if (!infileBI) {
    cerr << "cannot open file bias: " << name << endl;
    exit(1);
  }

  name = argv[6]+met+"_.BI2";

  ifstream infileBI2(name.c_str());
  if (!infileBI2) {
    cerr << "cannot open file bias output layer: " << name << endl;
    exit(1);
  }

  string line;
  vector<string> dataV;
  int count =0;

  double cut = atof(argv[3]);

  map <int,Patts> patMap;


  /********* Read input patterns to map  ********/

  while (getline(infile,line)){

    ++count;

    Split(line,dataV);

    Patts data;
    data.pdb = dataV[0];
    data.resS = dataV[0];

  for(int i=1; i<dataV.size(); ++i){

      double patemp = atof(dataV[i].c_str());

      data.inpatV.push_back(patemp);

    }


    patMap[count] = data;
    data.inpatV.clear();
    dataV.clear();

  }

  int patNO = count;

  /******** Read input layer weigths *********/

  count = 0;

  while (getline(infileIL,line)){

    ++count;

    Split(line,dataV);
    Weights ILdata;

    for(int i=0; i<dataV.size(); ++i){

      double patemp = atof(dataV[i].c_str());

      //  cout << patemp << " * " << endl;

      ILdata.weightsV.push_back(patemp);

    }

    mapIL[count] = ILdata;

    ILdata.weightsV.clear();
    dataV.clear();
  }


 /******** Read output layer weigths *********/

  map <int,Weights> mapOL;
  count = 0;

  while (getline(infileOL,line)){

    ++count;

    Split(line,dataV);

    Weights OLdata;

    for(int i=0; i<dataV.size(); ++i){

      float patemp = atof(dataV[i].c_str());

      OLdata.weightsV.push_back(patemp);

    }

    mapOL[count] = OLdata;

    OLdata.weightsV.clear();
    dataV.clear();
  }


 /********** read bias weights ********/

 count = 0;

 while (getline(infileBI,line)){

   ++count;

   float patemp = atof(line.c_str());

   mapBias[count] = patemp;

 }

 double biasOL=0;

 while (getline(infileBI2,line)){

   float patemp = atof(line.c_str());

   biasOL = patemp;

 }


 map<int,Weights> mapHL;
 float cack =0;

 /******** Go thorugh all patterns apply weights to hidden layer and save hidden layer values ******/

  for(int i=0; i<patNO; ++i){

    Patts patterns = patMap[i+1];
    vector<double> patV= patterns.inpatV;

    vector<double> HiddenLayerVec;

    HiddenLayerVec = hidLayCalc(patterns.inpatV);


    //cout << HiddenLayerVec[24] << endl;


    Weights HLW;
    HLW.weightsV = HiddenLayerVec;

    mapHL[i+1] = HLW;


  }

  /********** Output Layer weights calculation ***********/

  map<string,double> pdbScoresM;


  map<int,Weights> mapRL;

  for(int i=0; i<patNO; ++i){

    vector<double> OutputLayerVec(1,0);

    Weights HLW = mapHL[i+1];

    for(int j=0; j<HLW.weightsV.size(); ++j){

       Weights OL = mapOL[j+1];

       for(int k=0; k<OL.weightsV.size(); ++k){

	 //cout <<   HLW.weightsV[j] << " " <<  OL.weightsV[k] << endl;

	 double update = HLW.weightsV[j] * OL.weightsV[k];

	 OutputLayerVec[k]+=update;


       }
    }

    for(int k=0; k<OutputLayerVec.size(); ++k){


      double temp = OutputLayerVec[k] + biasOL;
      double pred = logsig(temp);

      string keyP = patMap[i+1].resS;
      pdbScoresM[keyP] = 0;

      if(pred >= cut){

	pdbScoresM[keyP] = pred;
	cout << setw(5) << i +1 << " " << setw(7) <<  pred << " ";
       	cout << " " << setw(10) << patMap[i+1].resS << endl;

      }

    }
  }

  /*************** READ IN PDB DATA ***************/

  string pdb = argv[1];
  //cout << pdb;
  pdb = pdb.substr(0,pdb.length()-5);
  name = pdb; // + ".pdb";


  ifstream infileStr(name.c_str());
  if (!infileStr) {
    cerr << "cannot open file pdb " << name << endl;
    exit(1);
  }

  string outf = name + ".MetPred";

  ofstream out(argv[4]);
  out.precision(3);

  out.setf(ios::fixed);

  Atom atoms;

  while (getline(infileStr,line)){
	//d.buchan: Well assign lines that don't match the incoming chainID
	//to have a minimum temperature. to indicate "Not in the prediction", couloured blue as per the heat map

	 if(line.substr(0,4) == "ATOM"){

		if(line.substr(21,1) != chainID)
		{
			out << line.substr(0,60) << "  " << "0.50" << endl;
			continue;
		}
      out << line.substr(0,60);
	  //d.buchan correctted the residue number reading mistake
      string resNo = line.substr(22,4);

      if(resNo.substr(0,1) == " " || resNo.substr(1,1) == " "){

	Split(resNo,dataV);
	resNo = dataV[0];
	dataV.clear();
      }

      string resName =  line.substr(17,3);

      resNo = resName+resNo;

      double pred = pdbScoresM[resNo];
	  //d.buchan: here we set not predictions in the predited chain to white
	  // red indicates stronger prediction.
      if(pred < 0.000000000001){
	out << "  " << "0.00" << endl;
      }

      else{
	  //d.buchan: set contact predictions to Red
	  if(pred >= cut)
	  {
	  	pred = (pred/2)+0.5;
	  	if(pred > cut)
	  	{
	  		out << "  " << "1.00" << endl;
	  	}
	  	else
	  	{
	  		out << "  " << setprecision(2) << pred << endl;
	  	}
	  }
	  else
	  {
	  	out << "  " << "0.00" << endl;
	  }
	  //out << "  " << "1.00" << endl;
      }
     /*

      atoms.atomName = line.substr(13,3);
      atoms.resNum = atoi(line.substr(23,3).c_str());
      atoms.atomNum = atoi(line.substr(7,6).c_str());
      atoms.resName=line.substr(17,3);
      atoms.xyz[0]=atof(line.substr(30,8).c_str());
      atoms.xyz[1]=atof(line.substr(38,8).c_str());
      atoms.xyz[2]=atof(line.substr(46,8).c_str());
      atoms.bfac = atof(line.substr(60,8).c_str());
      atoms.chain = line.substr(21,1);
      //      atomV.push_back(atoms);

      string resNo = line.substr(23,3);

      double pred = pdbScoresM[resNo];
      string one = "1.00";

      //      if(pred < 0.0

      out << setw(4)<< "ATOM" << "   " << setw(4) << atoms.atomNum << "  "  <<setw(3)<< atoms.atomName <<setw(0) << " ";
      out  << setw(3) << atoms.resName  << setw(1) << " " << atoms.chain << " " << setw(3) << atoms.resNum << "     ";
      out << setw(7) << atoms.xyz[0] << " " << setw(7) << atoms.xyz[1] <<" " << setw(7) <<  atoms.xyz[2];
      out << "  " << setw(3) << one << "  ";//<< setw(6) << pred;
      out << endl;
      */

    }


    if(line.substr(0,4) == "HETA"){

      out << line.substr(0,60) << "  " << "0.00" << endl;
    }



    if(line.substr(0,4) == "HEAD" || line.substr(0,4) == "REMA"  || line.substr(0,4) == "EXPD" ){

      out << line << endl;

    }
  }
}
