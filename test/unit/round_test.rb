require File.dirname(__FILE__) + '/../test_helper'

class RoundTest < ActiveSupport::TestCase
  def test_distribute_votes
    race = races(:vegetable)
    election = race.election
    # Voters
    voter1 = users(:voter1)
    voter2 = users(:voter2)
    voter3 = users(:voter3)
    voter4 = users(:voter4)
    voter5 = users(:voter5)
    voter6 = users(:voter6)
    voter7 = users(:voter7)
    voters = [ voter1, voter2, voter3, voter4, voter5, voter6, voter7 ]
    race.users<<voters
    # Candidates
    potato = candidates(:potato)
    celeriac = candidates(:celeriac)
    turnip = candidates(:turnip)
    beet = candidates(:beet)
    yam = candidates(:yam)
    taro = candidates(:taro)
    carrot = candidates(:carrot)
    # Votes
    ballot = election.ballots.create( :user => voter1 )
    ballot.votes.create( :candidate => yam )
    ballot.votes.create( :candidate => potato )
    ballot.votes.create( :candidate => carrot )
    ballot.votes.create( :candidate => beet )
    ballot.votes.create( :candidate => turnip )
    ballot.votes.create( :candidate => celeriac )
    ballot.votes.create( :candidate => taro )
    ballot = election.ballots.create( :user => voter2 )
    ballot.votes.create( :candidate => carrot )
    ballot.votes.create( :candidate => yam )
    ballot.votes.create( :candidate => beet )
    ballot.votes.create( :candidate => potato )
    ballot.votes.create( :candidate => taro )
    ballot.votes.create( :candidate => turnip )
    ballot.votes.create( :candidate => celeriac )
    ballot = election.ballots.create( :user => voter3 )
    ballot.votes.create( :candidate => potato )
    ballot.votes.create( :candidate => beet )
    ballot.votes.create( :candidate => carrot )
    ballot.votes.create( :candidate => yam )
    ballot.votes.create( :candidate => turnip )
    ballot.votes.create( :candidate => celeriac )
    ballot.votes.create( :candidate => taro )
    ballot = election.ballots.create( :user => voter4 )
    ballot.votes.create( :candidate => potato )
    ballot.votes.create( :candidate => carrot )
    ballot.votes.create( :candidate => beet )
    ballot.votes.create( :candidate => yam )
    ballot.votes.create( :candidate => turnip )
    ballot = election.ballots.create( :user => voter5 )
    ballot.votes.create( :candidate => potato )
    ballot.votes.create( :candidate => yam )
    ballot.votes.create( :candidate => carrot )
    ballot.votes.create( :candidate => beet )
    ballot.votes.create( :candidate => celeriac )
    ballot.votes.create( :candidate => turnip )
    ballot.votes.create( :candidate => taro )
    ballot = election.ballots.create( :user => voter6 )
    ballot.votes.create( :candidate => yam )
    ballot.votes.create( :candidate => carrot )
    ballot.votes.create( :candidate => beet )
    ballot.votes.create( :candidate => potato )
    ballot.votes.create( :candidate => taro )
    ballot.votes.create( :candidate => celeriac )
    ballot.votes.create( :candidate => turnip )
    ballot = election.ballots.create( :user => voter7 )
    ballot.votes.create( :candidate => yam )
    ballot.votes.create( :candidate => potato )
    ballot.votes.create( :candidate => beet )
    ballot.votes.create( :candidate => carrot )
    ballot.votes.create( :candidate => turnip )
    ballot.votes.create( :candidate => celeriac )
    ballot.votes.create( :candidate => taro )
    # Tabulate results
    race.rounds.create
    round1 = race.rounds[0]
    assert_equal 3, round1.tallies.for_candidate(potato).tally
    assert_equal 0, round1.tallies.for_candidate(celeriac).tally
    assert_equal 0, round1.tallies.for_candidate(turnip).tally
    assert_equal 0, round1.tallies.for_candidate(beet).tally
    assert_equal 3, round1.tallies.for_candidate(yam).tally
    assert_equal 0, round1.tallies.for_candidate(taro).tally
    assert_equal 1, round1.tallies.for_candidate(carrot).tally
    assert_equal 4, round1.tallies.exhaustable.size
    assert_equal 7, round1.candidates.remaining.size
    assert_equal Vote.find(:all, :conditions => { :exhausted => round1.position } ).size,
                 Vote.find(:all, :conditions => 
                   { :candidate_id => Vote.find( :first,
                                                 :conditions => 
                                                   { :exhausted => round1.position } ).
                                                     candidate_id } ).size,
                 "Number of votes exhausted in first round should == " +
                   "votes cast for candidate of any vote in the first round:"
    round2 = race.rounds[1]
    assert_equal 2, round2.position
    assert_equal 6, round2.tallies.size
    assert_equal 3, round2.tallies.for_candidate(potato).tally
    assert_equal 3, round2.tallies.for_candidate(yam).tally
    assert_equal 1, round2.tallies.for_candidate(carrot).tally
    assert_equal 6, round2.candidates.remaining.size
    assert_equal 3, round2.tallies.exhaustable.size
    round3 = race.rounds[2]
    assert_equal 5, round3.tallies.size
    assert_equal 2, round3.tallies.exhaustable.size
    round4 = race.rounds[3]
    assert_equal 4, round4.tallies.size
    assert_equal 1, round4.tallies.exhaustable.size
    assert_equal 3, round4.tallies.for_candidate(potato).tally
    assert_equal 3, round4.tallies.for_candidate(yam).tally
    assert_equal 1, round4.tallies.for_candidate(carrot).tally
    round5 = race.rounds[4]
    assert_equal 3, round5.tallies.size
    assert_equal 1, round5.tallies.exhaustable.size
    assert_equal 3, round5.tallies.for_candidate(potato).tally
    assert_equal 3, round5.tallies.for_candidate(yam).tally
    assert_equal 1, round5.tallies.for_candidate(carrot).tally
    round6 = race.rounds[5]
    assert_equal 2, round6.tallies.size
    assert_equal 1, round6.tallies.exhaustable.size
    assert_equal 3, round6.tallies.for_candidate(potato).tally
    assert_equal 4, round6.tallies.for_candidate(yam).tally
    round7 = race.rounds[6]
    assert_equal 1, round7.tallies.size
    assert_equal 7, round7.tallies.for_candidate(yam).tally
  end

  def test_may_user
    setup_elections
    @rounds ||= {}
    @rounds[:past] = Round.new(:race => @races[:past])
    # For past election when results released
    # Unprivileged user rights
    assert_equal false, @rounds[:past].may_user?(@users[:public],:create)
    assert_equal false, @rounds[:past].may_user?(@users[:public],:delete)
    assert_equal true, @rounds[:past].may_user?(@users[:public],:show)
    assert_equal true, @rounds[:past].may_user?(@users[:public],:index)
    # Voter rights
    assert_equal false, @rounds[:past].may_user?(@users[:voter],:create)
    assert_equal false, @rounds[:past].may_user?(@users[:voter],:delete)
    assert_equal true, @rounds[:past].may_user?(@users[:voter],:show)
    assert_equal true, @rounds[:past].may_user?(@users[:voter],:index)
    # Manager rights
    assert_equal true, @rounds[:past].may_user?(@users[:manager],:create)
    assert_equal true, @rounds[:past].may_user?(@users[:manager],:delete)
    assert_equal true, @rounds[:past].may_user?(@users[:manager],:show)
    assert_equal true, @rounds[:past].may_user?(@users[:manager],:index)
    # Admin rights
    assert_equal true, @rounds[:past].may_user?(@users[:admin],:create)
    assert_equal true, @rounds[:past].may_user?(@users[:admin],:delete)
    assert_equal true, @rounds[:past].may_user?(@users[:admin],:show)
    assert_equal true, @rounds[:past].may_user?(@users[:admin],:index)
    # For past election when results not yet released
    @elections[:past].results_available_at = Time.now + 1.days
    # Unprivileged user rights
    assert_equal false, @rounds[:past].may_user?(@users[:public],:create)
    assert_equal false, @rounds[:past].may_user?(@users[:public],:delete)
    assert_equal false, @rounds[:past].may_user?(@users[:public],:show)
    assert_equal false, @rounds[:past].may_user?(@users[:public],:index)
    # Voter rights
    assert_equal false, @rounds[:past].may_user?(@users[:voter],:create)
    assert_equal false, @rounds[:past].may_user?(@users[:voter],:delete)
    assert_equal false, @rounds[:past].may_user?(@users[:voter],:show)
    assert_equal false, @rounds[:past].may_user?(@users[:voter],:index)
    # Manager rights
    assert_equal true, @rounds[:past].may_user?(@users[:manager],:create)
    assert_equal true, @rounds[:past].may_user?(@users[:manager],:delete)
    assert_equal true, @rounds[:past].may_user?(@users[:manager],:show)
    assert_equal true, @rounds[:past].may_user?(@users[:manager],:index)
    # Admin rights
    assert_equal true, @rounds[:past].may_user?(@users[:admin],:create)
    assert_equal true, @rounds[:past].may_user?(@users[:admin],:delete)
    assert_equal true, @rounds[:past].may_user?(@users[:admin],:show)
    assert_equal true, @rounds[:past].may_user?(@users[:admin],:index)
  end
end
