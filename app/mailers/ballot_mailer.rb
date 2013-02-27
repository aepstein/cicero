class BallotMailer < ActionMailer::Base
  attr_accessor :ballot
  helper :application
  helper_method :ballot

  def verification( ballot )
    self.ballot = ballot
    mail(
      to: [ ballot.user.to_email ],
      from: ballot.election.contact_email,
      subject: "Confirmation of #{ballot.election.name} ballot"
    )
  end
end

