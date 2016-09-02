require 'spec_helper'
require 'uuidtools'
  
describe PsipredController do
  #TODO: add some tests to check what happen with invalid submission data.
  
  uuid = ''
  before(:all) do
    #set up some db entries for testing
    job_config = FactoryGirl.create(:job_configuration)
    job = FactoryGirl.create(:job)
    uuid = job.UUID
    r_result = FactoryGirl.create(:request_result, job_id: job.id)
  end
  
  validAminoAcids =  ['A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y','X'];
  outputAA = lambda {|x| (0...x).map{ validAminoAcids.to_a[rand(21)] }.join } 

  let(:get_index)  { get "index" }
  let(:get_submit) { get "submit", :sequence => outputAA.call(100), :email => 'test@test.com', :subject => 'test' }
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
    
  describe "GET :submit" do
    it "returns http success" do
      get_submit
      response.should be_success
    end        
    
    it "renders the submit view" do
      get_submit
      response.should render_template :submit
    end  
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