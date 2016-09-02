class PopulateUsers < ActiveRecord::Migration
  def self.up
    
    if !User.exists?(1)
      admin = User.create(:login => "admin", :email => "d.buchan@imperial.ac.uk",
        :crypted_password => "d969b1c68f534d1f10da3d7668857c4d9dd0f352",
        :salt => "66385bdf30328ba61644a0552c1806bf9a11faa2",
        :created_at => "2009-04-01 13:47:48", :updated_at => "2009-04-01 13:47:48",
        :user_class => 10, :admin => 1, :id => 1)
    end
    

    if !User.exists?(2)
      admin_alt = User.create(:login => "admin_alt", :email => "dbuchan@cs.ucl.ac.uk",
        :crypted_password => "d969b1c68f534d1f10da3d7668857c4d9dd0f352",
        :salt => "66385bdf30328ba61644a0552c1806bf9a11faa2",
        :created_at => "2010-02-03 11:45:54", :updated_at => "2010-02-03 11:45:54",
        :user_class => 10, :admin => 1, :id => 2)
    end

    if !User.exists?(3)
      dan_b = User.create(:login => "dan.buchan", :email => "d.buchan@cs.ucl.ac.uk",
        :crypted_password => "d527f62b8989e586ff449d3154657fd006bb5dc5",
        :salt => "8642a686c1a82b2eafc662c13b1b0b32e385e2f2",
        :created_at => "2010-02-03 11:47:15", :updated_at => "2010-02-03 11:47:15",
        :user_class => 10, :admin => 0, :id => 3)
    end

    if !User.exists?(4)
      casp = User.create(:login => "casp", :email => "casp@cs.ucl.ac.uk",
        :crypted_password => "07e5ac2f269e9b1b7b5966e932e75e30a383ca8a",
        :salt => "6d373a0b667307780e3930bbb9d1f9269698f5ba",
        :created_at => "2010-02-03 11:47:41", :updated_at => "2010-02-03 11:47:41",
        :user_class => 8, :admin => 0, :id => 4)
    end

    if !User.exists?(5)
      ucl_user = User.create(:login => "ucl_user", :email => "ucl@cs.ucl.ac.uk",
        :crypted_password => "37005efcc836cf9d464298ba954b811333b9d086",
        :salt => "d9ca8e46cf7e414e6210a37d5823591d9ae3b1c5",
        :created_at => "2010-02-03 11:48:02", :updated_at => "2010-02-03 11:48:02",
        :user_class => 8, :admin => 0, :id => 5)
    end

    if !User.exists?(6)
      cs_user = User.create(:login => "cs_user", :email => "cs@cs.ucl.ac.uk",
        :crypted_password => "0976c1c23f52520148c9c49c0b49add3091a0114",
        :salt => "72bdd73c5ca34e54f36ad73689ee8a7b309b8de7",
        :created_at => "2010-02-03 11:48:29", :updated_at => "2010-02-03 11:48:29",
        :user_class => 9, :admin => 0, :id => 6)
    end

    if !User.exists?(7)
      commercial_account = User.create(:login => "commercial_account", :email => "commercial@cs.ucl.ac.uk",
        :crypted_password => "70c74d4abaaeedb27fbec1d4a4ce13bccd5321ee",
        :salt => "623c15ce90dc333efe289bc79650ece584978ee8",
        :created_at => "2010-02-03 11:48:51", :updated_at => "2010-02-03 11:48:51",
        :user_class => 20, :admin => 0, :id => 7)
    end

    if !User.exists?(8)
      abusers = User.create(:login => "abusers", :email => "abusers@cs.ucl.ac.uk",
        :crypted_password => "fe3181c040037a8b023943dc1ee639c35ba796e3",
        :salt => "33db6cf67170ece63c9165842bd70814321c6332",
        :created_at => "2010-02-03 11:49:13", :updated_at => "2010-02-03 11:49:13",
        :user_class => 0, :admin => 0, :id => 8)
    end

  end

  def self.down
    # Leave the admin user..
    User.delete(2)
    User.delete(3)
    User.delete(4)
    User.delete(5)
    User.delete(6)
    User.delete(7)
    User.delete(8)
  end
end
