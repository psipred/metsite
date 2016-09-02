require 'spec_helper'

describe StructureController do
  
  uuid = ''
  pdb_file = "ATOM      1  N   HIS A   1      28.690  -2.561 -13.111  1.00 43.36           N\nATOM      2  CA  HIS A   1      29.326  -1.237 -13.374  1.00 43.97           C\n ATOM      3  C   HIS A   1      29.420  -0.385 -12.092  1.00 43.94           C  \nATOM      4  O   HIS A   1      30.007   0.697 -12.126  1.00 44.30           O  \nATOM      5  CB  HIS A   1      28.550  -0.485 -14.481  1.00 44.97           C  \nATOM      6  CG  HIS A   1      29.359   0.548 -15.229  1.00 45.38           C  \nATOM      7  ND1 HIS A   1      30.564   1.054 -14.767  1.00 45.77           N  \nATOM      8  CD2 HIS A   1      29.133   1.178 -16.413  1.00 45.21           C  \nATOM      9  CE1 HIS A   1      31.039   1.937 -15.623  1.00 44.67           C  \nATOM     10  NE2 HIS A   1      30.189   2.034 -16.635  1.00 44.92           N  \nATOM     11  N   LYS A   2      28.840  -0.881 -10.983  1.00 43.70           N  \nATOM     12  CA  LYS A   2      28.884  -0.218  -9.657  1.00 42.04           C  \nATOM     13  C   LYS A   2      28.455   1.291  -9.732  1.00 40.15           C  \nATOM     14  O   LYS A   2      27.354   1.601 -10.195  1.00 39.02           O  \nATOM     15  CB  LYS A   2      30.310  -0.345  -9.059  1.00 42.11           C  \nATOM     16  CG  LYS A   2      30.879  -1.786  -8.902  1.00 41.34           C  \nATOM     17  CD  LYS A   2      32.244  -1.837  -8.156  1.00 39.53           C  \nATOM     18  CE  LYS A   2      33.351  -1.039  -8.866  1.00 40.19           C  \nATOM     19  NZ  LYS A   2      34.740  -1.227  -8.299  1.00 39.90           N  \nATOM     20  N   CYS A   3      29.354   2.196  -9.297  1.00 39.62           N  \nATOM     21  CA  CYS A   3      29.093   3.643  -9.326  1.00 37.45           C  \nATOM     22  C   CYS A   3      29.411   4.272 -10.671  1.00 34.89           C  \nATOM     23  O   CYS A   3      30.459   4.890 -10.849  1.00 34.14           O  \nATOM     24  CB  CYS A   3      29.914   4.377  -8.235  1.00 37.13           C  \nATOM     25  SG  CYS A   3      29.200   4.243  -6.559  1.00 38.41           S  \nATOM     26  N   ASP A   4      28.526   4.050 -11.637  1.00 32.87           N  \nATOM     27  CA  ASP A   4      28.712   4.631 -12.961  1.00 31.18           C  \nATOM     28  C   ASP A   4      28.149   6.043 -12.964  1.00 27.93           C  \nATOM     29  O   ASP A   4      27.550   6.458 -11.967  1.00 27.58           O  \nATOM     30  CB  ASP A   4      28.057   3.746 -14.045  1.00 32.73           C  \nATOM     31  CG  ASP A   4      26.563   3.603 -13.894  1.00 33.57           C  \nATOM     32  OD1 ASP A   4      26.017   3.762 -12.774  1.00 32.19           O  \nATOM     33  OD2 ASP A   4      25.926   3.337 -14.950  1.00 35.94           O  \nTER      33      ASP A   4\n"
  
  before(:all) do
    #set up some db entries for testing
    server = FactoryGirl.create(:server)
    job_config = FactoryGirl.create(:job_configuration, name: 'structJob')
    job = FactoryGirl.create(:job, Type: 'structJob', QueryString: pdb_file, program_hspred: 1, program_psipred: 0, server_id: server.id)
    uuid = job.UUID
    r_result = FactoryGirl.create(:request_result, job_id: job.id)
  end
  
  let(:get_index)  { get "index" }
  let(:post_submit) { post "submit", :pdbFile => Rack::Test::UploadedFile.new("spec/test_files/test.pdb", 'text/ascii'), :email => 'test@test.com', :name => 'test', :program_hspred => 1, :chain => "A", :chainsA => 'A',:chainsB => 'B'}
  let(:get_result) { get "result", :id => uuid}
  let(:get_random_result) { get "result", :id => UUIDTools::UUID.timestamp_create().to_s}
  
  #mostly smoke tests for rendering the views
  describe "GET :index" do 
    it "returns http success" do
      get_index
      response.should be_success
    end
    
    it "renders the :index view" do
      get_index
      response.should render_template :index
    end  
  end
    
  describe "POST :submit" do
    it "returns http success" do
      post_submit
      response.should be_success
    end        
    
    #commented this out as it requires a fully working underlying db to realise
    #it "renders the submit view" do
    #  post_submit
    #  response.should render_template :submit
    #end  
  end
  
  describe "GET :result" do
    it "returns http success" do
      get_result
      response.should be_success
    end
    
    it "renders the result view" do
      get_result
      response.should render_template :result
    end
    
    it "renders the no_id view" do
      get_random_result
      response.should render_template :no_id
    end      
  end
  
end