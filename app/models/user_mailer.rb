class UserMailer < ActionMailer::Base
  helper :application

  def ballot_verification(ballot)
    recipients "#{ballot.user.name} <#{ballot.user.email}>"
    from ballot.election.contact_email
    subject "Confirmation of #{ballot.election.name} ballot"
    body :ballot => ballot
  end
end

