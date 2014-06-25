#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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
########################################################################

require File.dirname(__FILE__) + '/../spec_helper'

describe UserMailer do
      before(:each) do
        ActionMailer::Base.deliveries = []
        @defined_status=RecordStatus.find_by_name("Defined")
        @user = FactoryGirl.create(:user)    # default user language is English.

        @admin_setting = FactoryGirl.create(:notifications_email_ad, :key => "notifications_email")

        @mailer_created = UserMailer.account_created(@user)
        @mailer_validate_ldap = UserMailer.account_validate_ldap(@user)
        @mailer_account_suspended = UserMailer.account_suspended(@user)

        @mailer_new = UserMailer.new_password(@user)
        @mailer_forgotten_password = UserMailer.forgotten_password(@user)
        @mailer_account_request = UserMailer.account_request(@defined_status)
        @mailer_account_validate = UserMailer.account_validate(@user)
        @mailer_account_validate_nopwd = UserMailer.account_validate_no_pw(@user)
        I18n.locale = 'en' #we force Locale to English
      end

      describe "Created" do
        it "should have Subject ProjEstimate Account created" do
          @mailer_created.subject.should eq(I18n.t(:mail_subject_account_created))
        end
        it "should have to user mail from created mail" do
          @mailer_created.to[0].should==(@user.email)
        end
        #it "should send Account created emails" do
        #  @mailerCreated.deliver
        #end
      end
      describe "Validate LDAP" do
        it "should have Subject Your ProjEstimate account has changed" do
          @mailer_validate_ldap.subject.should eq(I18n.t(:mail_subject_account_activation))
        end
        it "should have to user mail from validateLDAP" do
          @mailer_validate_ldap.to[0].should==(@user.email)
        end
        #it "should send Account validatedLDAP emails" do
        #  @mailerValidateLDAP.deliver
        #end
      end
      describe "Account suspended" do
        it "should have Subject Your ProjEstimate account has changed" do
          @mailer_account_suspended.subject.should eq(I18n.t(:mail_subject_account_suspended))
        end
        it "should have to user mail from validateLDAP" do
          @mailer_account_suspended.to[0].should==(@user.email)
        end
        #it "should send Account suspended emails" do
        #  @mailerAccountsuspended.deliver
        #end
      end
      describe "Reset password" do
        it "should have Subject Your ProjEstimate password has changed" do
          @mailer_new.subject.should eq(I18n.t(:mail_subject_new_password))
        end
        it "should have to user mail from new password" do
          @mailer_new.to[0].should==(@user.email)
        end
        #it "should send password reseted emails" do
        #  @mailerNew.deliver
        #end
      end
      describe "Forgotten password" do
      #Don't modifie please: tests are in echec because the method FOrgotten Password is not fonctionnal'
        it "should have Subject Projestimate - New password" do
          @mailer_forgotten_password.subject.should eq(I18n.t(:mail_subject_lost_password))
        end
        it "should have to user mail from forgotten password" do
          @mailer_forgotten_password.to[0].should==(@user.email)
        end
        #it "should send reset password emails" do
        #  @mailerAccountValidate.deliver
        #end
      end
      describe "New account request" do
        it "should have Subject New account request" do
          @mailer_account_request.subject.should eq(I18n.t(:mail_subject_account_activation_request))
        end
        it "should have to user mail from New account request" do
          @mailer_account_request.to[0].should==(AdminSetting.find_by_key("notifications_email").value)
        end
        #it "should send new account request emails" do
        #  @mailerAccountRequest.deliver
        #end
      end
      describe "Account validated" do
        it "should have Subject Your ProjEstimate account is validated" do
          @mailer_account_validate.subject.should eq(I18n.t(:mail_subject_account_activation))
        end
        it "should have to user mail from Account Validate" do
          @mailer_account_validate.to[0].should==(@user.email)
        end
        #it "should send Account validated emails" do
        #  @mailerAccountValidate.deliver
        #end
      end
      describe "Account validated without password" do
        it "should have Subject Your ProjEstimate account has been validated" do
          @mailer_account_validate_nopwd.subject.should eq(I18n.t(:mail_subject_account_activation))
        end
        it "should have to user mail from Account Validate without password" do
          @mailer_account_validate_nopwd.to[0].should==(@user.email)
        end
        #it "should send Account ValidateNoPw emails" do
        #  @mailerAccountValidateNoPw.deliver
        #end
      end

end

