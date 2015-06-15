# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

require 'spec_helper'

describe User, type: :model  do

  before :each do
    @admin1 = FactoryGirl.build(:user)
    @admin_setting = FactoryGirl.create(:notifications_email_ad, :key => 'notifications_email', :value => 'AdminEmail@domaine.com' )

    @master_group = FactoryGirl.create(:master_admin_group)
    @everyone_group = FactoryGirl.create(:everyone_group)
    @admin_group = FactoryGirl.create(:admin_group)

    @admin = FactoryGirl.build(:user, :last_name => 'Projestimate', :first_name => 'Administrator', :login_name => 'administrator', :email => 'admin@yourcompany.net', :auth_type => 6, :password => 'testme_testme', :password_confirmation => 'testme_testme') ###User.new(admin_user_hash)  #defined below
    @user = FactoryGirl.build(:user, :last_name => 'test_last_name', :first_name => 'test_first_name', :login_name => 'test', :email => 'email@test.fr', :auth_type => 1, :password => 'testme_testme', :password_confirmation => 'testme_testme') ###User.new(valid_user_hash)   #defined below
    @admin1.confirm!
    @admin.confirm!
    @user.confirm!

    @admin1.save!
    @admin.save!
    @user.save!

  end

  it 'should be valid' do
    @admin.should be_valid
    @user.should be_valid
    @admin1.should be_valid
  end

  it 'should return the name of user' do
    @admin1.to_s.should eql(@admin1.name())
  end

  #ATTRIBUTES AND FORMAT VALIDATIONS

  it 'should not be valid without last_name' do
    @user.last_name=''
    @user.should_not be_valid
  end

  it 'should not be valid without first_name' do
    @user.first_name=''
    @user.should_not be_valid
  end

  #Validating login_name
  it 'should not be valid without login_name' do
    @user.login_name=''
    @user.should_not be_valid
  end

  describe 'when login_name is already taken' do

    it 'should not be_valid' do
      #@user_with_same_login = @user
      #@user_with_same_login.should_not be_valid
      u1 = @admin1.dup
      u1.login_name = @admin1.login_name
      u1.save
      u1.should_not be_valid
    end
  end

  #Validating Email address
  it 'should not be valid without email' do
    @user.email =''
    @user.should_not be_valid
  end

  it 'should not be valid when email is nil' do
    @user.email = 'test@moi.fr'
    @user.email.should match(/\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/i)
  end

  it 'should check for email format validation' do
    @user.email = ""
    #@user.should have_at_least(1).errors_on(:email)
    ###expect { @user.save }.to raise_error
    @user.should_not be_valid
  end

  describe 'when email address is already taken' do

    it 'should not be valid' do
      #@user_with_same_email = @user
      #@user_with_same_email.should_not be_valid

      u1 = @admin1.dup
      u1.email = @admin1.email
      u1.save
      u1.should_not be_valid
    end
  end

  it 'should not be valid without auth_type' do
    @user.auth_type = ''
    @user.should_not be_valid
  end

  it 'should not be valid without password' do
    if @user.auth_method
      @user.password = ''
      @user.should_not be_valid if @user.auth_method.name.include?('Application')
    end
  end

  it 'should not be valid without password_confirmation' do
    if @user.auth_method
      @user.password_confirmation=''
      @user.save
      @user.should_not be_valid  if @user.auth_method.name.include?('Application')
    end
  end

  # This can happen at the Console: because when password_confirmation is 'nil', Rails doesn't run validation
  it 'should not be valid when password confirmation is nil' do
    if @admin.auth_method
      @admin.password_confirmation = nil
      @admin.should_not be_valid if @admin.auth_method.name.include?('Application')
    end
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation= 'changed_pass' }
    it 'should not be valid' do
      if @user.auth_method
        @user.should_not be_valid if @user.auth_method.name.include?('Application')
      end
    end
  end

  #it "sends a e-mail" do
  #  @user.send_password_reset()
  #  ActionMailer::Base.deliveries.last.to.should == [@user.email]
  #end
  #describe "when password is too short" do
  #  before do
  #    #password_min_length = AdminSetting.new(:key => "password_min_length", :value => "4")
  #    #password_min_length.save
  #    @user.password = @user.password_confirmation = "abc"
  #  end
  #  it "should not be valid when password is too short" do
  #    @user.password_length.should_not be_valid
  #  end
  #end

  #AUTHENTICATION VALIDATION

  describe 'return value of authenticate method' do
    before { @new_user = User.first }

    let(:found_user) { User.find_by_email(@new_user.email) }
    subject {found_user}

    describe 'with valid password' do
      #it { should == User.authenticate(@new_user.login_name, @new_user.password)}
      ###it { should == User.authenticate(found_user.login_name, 'projestimate')}
    end

    #describe 'with invalid password' do
    #  let(:user_with_invalid_password) { User.authenticate(found_user.login_name, 'invalid') }
    #  it { should_not == user_with_invalid_password }
    #  specify { expect(user_with_invalid_password).to be_falsey }
    #end

    describe 'ldap authentication' do
      #@new_user.ldap_authentication("fauxmotdepasse", @new_user.login_name).should be_nil
    end

  end


  #METHODS AND OTHERS VALIDATIONS

  #check admin status
  it 'should be in Admin or MasterAdmin groups to be an admin account' do
    @admin1.groups = [@master_group, @everyone_group, @admin_group]
    @admin1.save
    ###expect([@master_group, @everyone_group, @admin_group]).to include(@admin1.groups)
  end

  #it 'should not be an suspending account' do
  #  @user.user_status.should_not eql('suspending')
  #  @user.user_status = 'active'
  #  @user.should be_valid
  #end

  it 'should be blacklisted' do
    @user.locked_at = Time.now
    @user.should be_valid
  end

  it 'should have a valid name =  first_name + ' ' + last_name' do
    @user.name.should eql(@user.first_name+ ' ' + @user.last_name)
  end


  #AASM STATES

  it 'should confirme account' do
    #@user.user_status = "active"
    @user.confirmed_at.should_not be_nil
  end

  it 'should be have LastName FirstName' do
    @admin.name.should eq('Administrator Projestimate')
  end

  it 'should return groups array (globals permissions)' do
    user_groups = @user.group_for_global_permissions
    user_groups.each do |grp|
      grp.for_global_permission.should eql('true')
    end
  end

  it 'should return groups array (project securities)' do
    user_groups = @user.group_for_project_securities
    user_groups.each do |grp|
      grp.for_project_security.should eql('true')
    end
  end

  it 'should return groups array (specific permissions)' do
  end

  it 'should be authenticate by the application' do
    @admin1.auth_method.name.should match(/Application_\d/)
  end

  #it "should be authenticate by the a LDAP directory" do
  #  if (@user.auth_method.certificate)==true
  #      use_ssl=:simple_tls
  #  else
  #      use_ssl=""
  #  end
  #end

  it 'should return admin group' do
    @admin1.groups = [@master_group, @everyone_group, @admin_group]
    @admin1.save
    ###expect([@master_group, @everyone_group, @admin_group]).to include(@admin1.groups)  #Admin and MasterAdmin
  end

  it 'should be an admin if he had admin right' do
  end

  it 'should be delete recent projects' do
  end

  it 'should return last projects' do
    user_last_project = @admin1.ten_latest_projects
  end

  it 'should return a search result (using for data-tables plugins)' do
  end

  def valid_user_hash
    {:last_name => 'test_last_name', :first_name => 'test_first_name', :login_name => 'test', :email => 'email@test.fr', :user_status => 'pending', :auth_type => 1, :password => 'test_me', :password_confirmation => 'test_me'}
  end


  def admin_user_hash
    {:last_name => 'Projestimate', :first_name => 'Administrator', :login_name => 'administrator', :email => 'admin@yourcompany.net', :user_status => 'active', :auth_type => 6, :password => 'test_me', :password_confirmation => 'test_me'}
  end

end