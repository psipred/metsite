class FunctionController < ApplicationController

require 'soap/wsdlDriver'
require 'pp'

def index
  @structure_code = params[:code]
  @lookup_failure = 0

  if @structure_code =~ /\d.{6}/
    ##we're dealing with a cath domain id
    begin
      #@funcat_data = lookup_funcat(@structure_code)
      @uniprot_data = lookup_uniprot(@structure_code)
      #@kortho_data = lookup_kegg_ortholog(@structure_code)
      #@kpathway_data = lookup_kegg_pathway(@structure_code)
    rescue
      @lookup_failure = 1
    end
  elsif @structure_code =~ /\d.{4}/
    #we're dealing with a pdb with chain id
    @funcat_data = Hash.new(0)
    @uniprot_data = Hash.new(0)
    @kortho_data = Hash.new(0)
    @kpathway_data = Hash.new(0)
    begin
      @domain_ids = lookup_domain_ids(@structure_code)
    rescue
      @lookup_failure = 1
    end

    if @domain_ids["ChainId2DomainIdsRecord"].nil?
      render :action => 'no_data'
    elsif @lookup_failure == 1
      render :action => 'cath_down'
    else
      wsdl_failure = 0
      if @domain_ids.chainId2DomainIdsRecord.instance_of?(Array)
        for datum in @domain_ids.chainId2DomainIdsRecord
          domain = datum.domain_id
          begin
            #@funcat_data[domain] = lookup_funcat(domain)
            @uniprot_data[domain] = lookup_uniprot(domain)
            #@kortho_data[domain] = lookup_kegg_ortholog(domain)
            #@kpathway_data[domain] = lookup_kegg_pathway(domain)
          rescue
            wsdl_failure = 1
          end
        end
      else
        domain = @domain_ids.chainId2DomainIdsRecord.domain_id
        begin
          #@funcat_data[domain] = lookup_funcat(domain)
          @uniprot_data[domain] = lookup_uniprot(domain)
          #@kortho_data[domain] = lookup_kegg_ortholog(domain)
          #@kpathway_data[domain] = lookup_kegg_pathway(domain)
        rescue
          wsdl_failure = 1
        end
      end

      if wsdl_failure == 1
        render :action => 'cath_down'
      else
       render :action => 'multi_function'
      end
    end
  end
  	
end

def lookup_domain_ids(code)
  factory = SOAP::WSDLDriverFactory.new('http://api.cathdb.info/api/soap/dataservices/wsdl')
  driver = factory.create_rpc_driver
  return driver.ChainId2DomainIds('ChainId2DomainIdsRequestRecord' => {'chain_id' => code})
end

def lookup_funcat(code)
  factory = SOAP::WSDLDriverFactory.new('http://api.cathdb.info/api/soap/dataservices/wsdl')
  driver = factory.create_rpc_driver
  return driver.DomainId2Funcats('DomainId2FuncatsRequestRecord' => {'domain_id' => code})
end

def lookup_uniprot(code)
  factory = SOAP::WSDLDriverFactory.new('http://api.cathdb.info/api/soap/dataservices/wsdl')
  driver = factory.create_rpc_driver
  data = driver.DomainId2UniprotIds('DomainId2UniprotIdsRequestRecord' => {'domain_id' => code})
  return data
end

def lookup_kegg_ortholog(code)
  factory = SOAP::WSDLDriverFactory.new('http://api.cathdb.info/api/soap/dataservices/wsdl')
  driver = factory.create_rpc_driver
  return driver.DomainId2KeggOrthologs('DomainId2KeggOrthologsRequestRecord' => {'domain_id' => code})
end

def lookup_kegg_pathway(code)
  factory = SOAP::WSDLDriverFactory.new('http://api.cathdb.info/api/soap/dataservices/wsdl')
  driver = factory.create_rpc_driver
  return driver.DomainId2KeggPathways('DomainId2KeggPathwaysRequestRecord' => {'domain_id' => code})
end


end
