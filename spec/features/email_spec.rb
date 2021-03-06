require 'spec_helper'

feature "site changed notification" do
  before(:each) do
    @user = FactoryGirl.create(:user)

    # sign in
    visit root_path
    click_link 'navbar-signin'
    fill_in 'Login', :with => @user.email
    fill_in 'Password', :with => @user.password
    click_button 'Sign in'

    @site = FactoryGirl.create(:site, :added_by_user => @user, :status => 'unknown')
    # user will automatically be watching the site
  end

  scenario "email sent on site change" do
    visit edit_site_path(@site)
    fill_in 'Name', :with => 'This is a new name'
    expect {
      click_button 'Update Site'
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  scenario "email contents" do
    @site.name = "This is a new name"
    mail = Mailer.site_changed_notification(@site, @user)
    mail.subject.should eq "#{@site.to_s}'s details were changed"
    mail.to.should eq [@user.email]
    mail.body.encoded.should match /<strong>name<\/strong>\s+changed from\s+.*\s+to\s+&quot;This is a new name&quot;/
  end
end
