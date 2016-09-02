require 'faker'
require 'uuidtools'


FactoryGirl.define do
    factory :job do |f|
        f.Type                 { "seqJob" }       
        f.QueryString          { (0...200).map{ ['A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y','X'].to_a[rand(21)] }.join}
        f.name                 { Faker::Lorem.word }
        f.address              { Faker::Internet.email }
        f.user_id              { 0 }
        f.job_configuration_id { 16 }
        f.server_id            { 7 }
        f.ip                   { Faker::Internet.ip_v4_address }
        f.state                { 0 }
        f.program_psipred      { 1 }
        f.program_disopred     { 0 }
        f.program_mgenthreader { 0 }
        f.program_svmmemsat    { 0 }
        f.program_bioserf      { 0 }
        f.program_dompred      { 0 }
        f.program_ffpred       { 0 }
        f.program_genthreader  { 0 }
        f.program_mempack      { 0 }
        f.program_domthreader  { 0 }
        f.program_metsite      { 0 }
        f.program_maketdb      { 0 }
        f.program_hspred       { 0 }
        f.program_domserf      { 0 }
        f.program_memembed     { 0 }
        f.UUID                 { UUIDTools::UUID.timestamp_create().to_s }
    end
end