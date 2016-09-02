require 'faker'

FactoryGirl.define do
    factory :request_result do |f|
      
        f.job_id        { 1 }
        f.status        { "Job Complete" }
        f.status_class  { "2" }
        f.content_type  { "text/plain"}
        f.content_name  { "Hi" }
        f.data          { "Lorem Ipsum"}
    end
    
end