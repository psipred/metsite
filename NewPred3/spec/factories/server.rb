require 'faker'

FactoryGirl.define do
    factory :server do |f|
       f.name     { 'localhost'}
       f.address  { 'http://127.0.0.1:8080/' }
       f.service  { 'org.ucl.shared.NewPredInterface' }
       f.description    { 'default connection to localhost' }
       f.maxjobs    { 1000 }
       
    end
    
end