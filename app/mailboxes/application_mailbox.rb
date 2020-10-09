class ApplicationMailbox < ActionMailbox::Base
  routing :all => :all_emails
end
