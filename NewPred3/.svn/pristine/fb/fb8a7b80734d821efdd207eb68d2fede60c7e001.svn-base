require 'spec_helper'

describe Job do
  #lets and befores
  validAminoAcids =  ['A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y','X'];
  outputAA = lambda {|x| (0...x).map{ validAminoAcids.to_a[rand(21)] }.join } 
  
  let(:type)             { "structJob" }
  let(:pdb_file)         {"ATOM      1  N   HIS A   1      28.690  -2.561 -13.111  1.00 43.36           N\nATOM      2  CA  HIS A   1      29.326  -1.237 -13.374  1.00 43.97           C\n ATOM      3  C   HIS A   1      29.420  -0.385 -12.092  1.00 43.94           C  \nATOM      4  O   HIS A   1      30.007   0.697 -12.126  1.00 44.30           O  \nATOM      5  CB  HIS A   1      28.550  -0.485 -14.481  1.00 44.97           C  \nATOM      6  CG  HIS A   1      29.359   0.548 -15.229  1.00 45.38           C  \nATOM      7  ND1 HIS A   1      30.564   1.054 -14.767  1.00 45.77           N  \nATOM      8  CD2 HIS A   1      29.133   1.178 -16.413  1.00 45.21           C  \nATOM      9  CE1 HIS A   1      31.039   1.937 -15.623  1.00 44.67           C  \nATOM     10  NE2 HIS A   1      30.189   2.034 -16.635  1.00 44.92           N  \nATOM     11  N   LYS A   2      28.840  -0.881 -10.983  1.00 43.70           N  \nATOM     12  CA  LYS A   2      28.884  -0.218  -9.657  1.00 42.04           C  \nATOM     13  C   LYS A   2      28.455   1.291  -9.732  1.00 40.15           C  \nATOM     14  O   LYS A   2      27.354   1.601 -10.195  1.00 39.02           O  \nATOM     15  CB  LYS A   2      30.310  -0.345  -9.059  1.00 42.11           C  \nATOM     16  CG  LYS A   2      30.879  -1.786  -8.902  1.00 41.34           C  \nATOM     17  CD  LYS A   2      32.244  -1.837  -8.156  1.00 39.53           C  \nATOM     18  CE  LYS A   2      33.351  -1.039  -8.866  1.00 40.19           C  \nATOM     19  NZ  LYS A   2      34.740  -1.227  -8.299  1.00 39.90           N  \nATOM     20  N   CYS A   3      29.354   2.196  -9.297  1.00 39.62           N  \nATOM     21  CA  CYS A   3      29.093   3.643  -9.326  1.00 37.45           C  \nATOM     22  C   CYS A   3      29.411   4.272 -10.671  1.00 34.89           C  \nATOM     23  O   CYS A   3      30.459   4.890 -10.849  1.00 34.14           O  \nATOM     24  CB  CYS A   3      29.914   4.377  -8.235  1.00 37.13           C  \nATOM     25  SG  CYS A   3      29.200   4.243  -6.559  1.00 38.41           S  \nATOM     26  N   ASP A   4      28.526   4.050 -11.637  1.00 32.87           N  \nATOM     27  CA  ASP A   4      28.712   4.631 -12.961  1.00 31.18           C  \nATOM     28  C   ASP A   4      28.149   6.043 -12.964  1.00 27.93           C  \nATOM     29  O   ASP A   4      27.550   6.458 -11.967  1.00 27.58           O  \nATOM     30  CB  ASP A   4      28.057   3.746 -14.045  1.00 32.73           C  \nATOM     31  CG  ASP A   4      26.563   3.603 -13.894  1.00 33.57           C  \nATOM     32  OD1 ASP A   4      26.017   3.762 -12.774  1.00 32.19           O  \nATOM     33  OD2 ASP A   4      25.926   3.337 -14.950  1.00 35.94           O  \nTER      33      ASP A   4\n"}
  let(:badpdb)           {"NONSENSE"}
  let(:emptypdb)         {""}
  let(:badseq)           { outputAA.call(20)+"ZZZZZZ"+outputAA.call(20) }
  let(:shortseq)         { outputAA.call(5) }
  let(:msa)              { ">test\n"+outputAA.call(40)+"\n>test2\n"+outputAA.call(40)}
  let(:msainvalidaa)     { ">test\n"+outputAA.call(39)+"Z\n>test2\n"+outputAA.call(40) }
  let(:msainvalidlength) { ">test\n"+outputAA.call(39)+"\n>test2\n"+outputAA.call(40) }
  let(:longseq1000)      { outputAA.call(1001) }
  let(:longseq1500)      { outputAA.call(1501) }
  let(:longseq3000)      { outputAA.call(3001) }
  
  #class smoke tests
  it "can be instantiated" do
    Job.new.should be_an_instance_of(Job)
  end

  it "has a valid seq factory" do
    FactoryGirl.create(:job).should be_valid
  end
  it "has a valid struct factory" do
    FactoryGirl.create(:job, Type: 'structJob', QueryString: pdb_file).should be_valid
  end
  it "accepts an MSA" do
    FactoryGirl.create(:job, QueryString: msa).should be_valid
  end
  it "seq can be saved" do
    FactoryGirl.create(:job).should be_persisted
  end
  it "struct can be saved" do
    FactoryGirl.create(:job, Type: 'structJob', QueryString: pdb_file).should be_persisted
  end
  
  #inputs that strictly should not be nil
  it "has a name" do
    FactoryGirl.build(:job, name: nil).should_not be_valid
  end
  it "has a QuerySequence" do
    FactoryGirl.build(:job, QueryString: nil).should_not be_valid
  end
  it "has a Type" do
    FactoryGirl.build(:job, Type: nil).should_not be_valid
  end
  
  #test seq input validations
  it "does not allow invalid aa code" do
    FactoryGirl.build(:job, QueryString: badseq).should_not be_valid
  end
  it "does not accept an invalid MSA: wrong lengths" do
    FactoryGirl.build(:job, QueryString: msainvalidlength).should_not be_valid
  end
  it "does not accept an invalid MSA: invalid aa code" do
    FactoryGirl.build(:job, QueryString: msainvalidaa).should_not be_valid
  end
  it "does not allow short sequences" do
    FactoryGirl.build(:job, QueryString: shortseq).should_not be_valid
  end
  it "does not allow long sequences: psipred (1500)" do
    FactoryGirl.build(:job, QueryString: longseq1500).should_not be_valid
  end
  it "does not allow long sequences: dompred (3000)" do
    FactoryGirl.build(:job, QueryString: longseq3000, program_dompred: 1).should_not be_valid
  end
  it "does not allow long sequences: genthreader (1000)" do
    FactoryGirl.build(:job, QueryString: longseq1000, program_genthreader:  1).should_not be_valid
    FactoryGirl.build(:job, QueryString: longseq1000, program_mgenthreader: 1).should_not be_valid
    FactoryGirl.build(:job, QueryString: longseq1000, program_domthreader:  1).should_not be_valid
  end
  
  #TODO: Add validations for the pdb structure input
  it "does not allow malformatted PDB files" do
    FactoryGirl.build(:job, Type: 'structJob', QueryString: badpdb).should_not be_valid
  end
  it "does not allow empty PDB files" do
    FactoryGirl.build(:job, Type: 'structJob', QueryString: emptypdb).should_not be_valid  
  end
  
  #testing methods
  it "can countJobs() which are running" do
    job = FactoryGirl.create(:job, state: 2)
    Job.countJobs(job.ip).should eql 1
  end 
  it "does not countJobs() which are not" do
    job = FactoryGirl.create(:job, state: 3)
    Job.countJobs(job.ip).should eql 0
  end 
 
  
  
end