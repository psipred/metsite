NewPred3::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
	
  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  
  #we just replicate the old routes from our rails 2 app
  #map.connect '/bio_serf', :controller => 'bio_serf', :action => 'index'
  #Need to map loads more routes to this controller at some point
  #like the ones we use for CASP
  match '/bio_serf' => 'bio_serf#index'
  match '/bio_serf/newjob' => 'bio_serf#newjob'
  match '/bio_serf/submit' => 'bio_serf#submit'
  match '/bio_serf/add_model/:id' => 'bio_serf#add_model'
  match '/bio_serf/batch_destroy' => 'bio_serf#batch_destroy'
  match '/bio_serf/batchdl' => 'bio_serf#batchdl'
  match '/bio_serf/batchdl_numeric' => 'bio_serf#batchdl_numeric'
  match '/bio_serf/batchjob' => 'bio_serf#batchjob'
  match '/bio_serf/batchkill' => 'bio_serf#batchkill'
  match '/bio_serf/batchresubmit' => 'bio_serf#batchresubmit'
  match '/bio_serf/casp_10_fn_test' => 'bio_serf#casp_10_fn_test'
  match '/bio_serf/casp_10_ts_test' => 'bio_serf#casp_10_ts_test'
  match '/bio_serf/casp_8_ts_test' => 'bio_serf#casp_8_ts_test'
  match '/bio_serf/ff_demo' => 'bio_serf#ff_demo'
  match '/bio_serf/ffjob' => 'bio_serf#ffjob'
  match '/bio_serf/newjob' => 'bio_serf#newjob'
  match '/bio_serf/paramjob' => 'bio_serf#paramjob'
  match '/bio_serf/rand_sample' => 'bio_serf#rand_sample'
  match '/bio_serf/regexdl' => 'bio_serf#regexdl'
  match '/bio_serf/casp_summary' => 'bio_serf#casp_summary'
  match '/bio_serf/full_status/:id' => 'bio_serf#full_status'
  match '/bio_serf/no_id/:id' => 'bio_serf#no_id'
  match '/bio_serf/queue' => 'bio_serf#queue'
  match '/bio_serf/status/:id' => 'bio_serf#status'
  match '/bio_serf/getresultattached/:id' => 'bio_serf#getresultattached'
  match '/bio_serf/getresultattachedgenome3d/:id' => 'bio_serf#getresultattachedgenome3d'
  match '/bio_serf/download_job/:id' => 'bio_serf#download_job'
  match '/bio_serf/getthumbnail/:id' => 'bio_serf#getthumbnail'
  match '/bio_serf/destroy_job/:id' => 'bio_serf#destroy_job'
  match '/bio_serf/kill_job/:id' => 'bio_serf#kill_job'
    
  match '/psipred' => 'psipred#index'
  match '/psipred/submit/' => 'psipred#submit'
  match '/psipred/result/:id' => 'psipred#result'
  match '/psipred/ongoing/:id' => 'psipred#ongoing'
  match '/psipred/image' => 'psipred#image'
  match '/psipred/buildzip/:id' => 'psipred#buildzip'


  match '/structure' => 'structure#index'
  match '/structure/submit' => 'structure#submit'
  match '/structure/result/:id' => 'structure#result'
  match '/structure/ongoing/:id' => 'structure#ongoing'
  
  match '/psipredtest' => 'psipredtest#index'
  match '/psipredtest/submit' => 'psipredtest#submit'
  match '/psipredtest/result' => 'psipredtest#result'
  match '/psipredtest/ongoing' => 'psipredtest#ongoing'
  
  match '/structtest' => 'structtest#index'
  match '/structtest/submit' => 'structtest#submit'
  match '/structtest/result/:id' => 'structtest#result'
  match '/structtest/ongoing/:id' => 'structtest#ongoing'
  
  match 'simple_modeller' => 'simple_modeller#index'
  match 'simple_modeller/submit' => 'simple_modeller#submit'
  match 'simple_modeller/result/:id' => 'simple_modeller#result'
  match 'simple_modeller/ongoing/:id' => 'simple_modeller#ongoing'
  
  match 'job_configurations' => 'job_configurations#index'
  match 'job_configurations/update/:id' => 'job_configurations#update'
  match 'job_configurations/show/:id' => 'job_configurations#show'
  match 'job_configurations/edit/:id' => 'job_configurations#edit'
  match 'job_configurations/destroy/:id' => 'job_configurations#destroy'
  match 'job_configurations/new_server' => 'job_configurations#new_server'
  match 'job_configurations/new' => 'job_configurations#new'
  match 'job_configurations/list' => 'job_configurations#list'
  match 'job_configurations/create' => 'job_configurations#create'
  match 'job_configurations/do_create_server' => 'job_configurations#do_create_server'
  
  match 'function/' => 'function#index'
  
  match 'genome3d/' => 'genome3d#index'
  match 'genome3d/read/' => 'genome3d#read'
  
  NewPred3::Application.routes.draw do
  	wash_out :psipred_api
  end
  
  
  #legacy routes
  match '/disopred' => 'disopred#index'
  match '/dompred' => 'dompred#index'
  match '/ffpred' => 'ffpred#index'
  match '/hspred' => 'hspred#index'
  match '/make_tdb' => 'make_tdb#index'
  match '/metsite' => 'metsite#index'
  
end
