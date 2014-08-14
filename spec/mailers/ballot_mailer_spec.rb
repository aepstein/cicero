require "spec_helper"

describe BallotMailer, :type => :mailer do
  include MailerSpecHelpers
  let(:election) { create( :election, name: "2012 Federal", verify_message: "You are a *good* citizen!" ) }
  let(:ballot) do
    user = create(:user)
    create(:roll, election: election).users << user
    create(:ballot, election: election, user: user)
  end

  describe "verification" do
    let(:mail) { BallotMailer.verification( ballot ) }

    it "has correct headers and content" do
      expect(mail.subject).to eq "Confirmation of 2012 Federal ballot"
      expect(mail.from).to eq([election.contact_email])
      expect(mail.to).to eq([ballot.user.email])

      both_parts_should_match /Dear #{ballot.user.first_name},/
      html_part_should_match /You are a <em>good<\/em> citizen./
      text_part_should_match /You are a \*good\* citizen\!/
    end
  end
end

