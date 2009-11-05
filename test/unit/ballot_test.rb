require File.dirname(__FILE__) + '/../test_helper'

class BallotTest < ActiveSupport::TestCase
  def setup
    setup_elections
    @ballot = Ballot.create(:election => elections(:current), :user => users(:xyz1))
  end
  
  def test_votes_for_race
    race = races(:ranked)
    first_vote = @ballot.votes.create(:candidate => candidates(:beta))
    second_vote = @ballot.votes.create(:candidate => candidates(:alpha))
    race.is_ranked = true; @ballot.save
    assert_equal first_vote, @ballot.votes.for_race(race).first
    assert_equal second_vote, @ballot.votes.for_race(race).last
    race.is_ranked = false; @ballot.save
    assert @ballot.votes.for_race(race).first == second_vote
    assert @ballot.votes.for_race(race).last == first_vote
  end
  
  def test_choices_setter
    @ballot.choices = { candidates(:alpha).id.to_s => "1",
                        candidates(:beta).id.to_s => "2" }
    assert_equal( @ballot.votes.first.candidate, candidates(:alpha) )
    assert_equal( @ballot.votes.last.candidate, candidates(:beta) )
  end
  
  def test_racify_choices
    @ballot.choices = { candidates(:alpha).id.to_s => "1",
                        candidates(:beta).id.to_s => "2",
                        candidates(:apple).id.to_s => "1",
                        candidates(:pear).id.to_s => "1" }
    raw_choices = Hash.new
    raw_choices[candidates(:alpha).id] = 1
    raw_choices[candidates(:beta).id] = 2
    raw_choices[candidates(:apple).id] = 1
    raw_choices[candidates(:pear).id] = 1
    assert_equal raw_choices, @ballot.choices
    racified_choices = Hash.new
    racified_choices[races(:ranked).id] = { candidates(:alpha).id => 1,
                                            candidates(:beta).id => 2 }
    racified_choices[races(:unranked).id] = { candidates(:apple).id => 1,
                                              candidates(:pear).id => 1 }
    assert_equal racified_choices, @ballot.racify_choices
  end
  
  def test_cast
    @ballot.updated_at=(Time.now)
    assert_equal true, @ballot.save
    assert_equal false,
                 @ballot.cast(2.days.ago),
                 "Ballot should not cast if modified since confirmation:"
    @ballot.updated_at=(2.days.ago)
    assert_equal true, @ballot.save
    assert_equal true, @ballot.cast(Time.now)
    assert_equal true, @ballot.cast_at?
    assert_equal false, @ballot.cast(Time.now)
  end
  
  def test_votes_left_for_race
    race=races(:ranked)
    assert_equal race.candidates.size, @ballot.votes.left_for_race(race)
    @ballot.votes.create(:candidate => candidates(:alpha))
    assert_equal race.candidates.size-1, @ballot.votes.left_for_race(race)
    second_vote = @ballot.votes.create(:candidate => candidates(:beta))
    assert_equal race.candidates.size-2, @ballot.votes.left_for_race(race)
    @ballot.votes.delete(second_vote)
    assert_equal race.candidates.size-1, @ballot.votes.left_for_race(race)
  end
  
  def test_may_user
    # For current election
    # Unprivileged user rights
    assert_equal false, @ballots[:current].may_user?(@users[:public],:create)
    assert_equal false, @ballots[:current].may_user?(@users[:public],:update)
    assert_equal false, @ballots[:current].may_user?(@users[:public],:delete)
    assert_equal false, @ballots[:current].may_user?(@users[:public],:show)
    assert_equal false, @ballots[:current].may_user?(@users[:public],:index)
    # Voter rights
    assert_equal true, @ballots[:current].may_user?(@users[:voter],:create)
    assert_equal true, @ballots[:current].may_user?(@users[:voter],:update)
    assert_equal true, @ballots[:current].may_user?(@users[:voter],:delete)
    assert_equal true, @ballots[:current].may_user?(@users[:voter],:show)
    assert_equal false, @ballots[:current].may_user?(@users[:voter],:index)
    # Manager rights
    assert_equal false, @ballots[:current].may_user?(@users[:manager],:create)
    assert_equal false, @ballots[:current].may_user?(@users[:manager],:update)
    assert_equal true, @ballots[:current].may_user?(@users[:manager],:delete)
    assert_equal false, @ballots[:current].may_user?(@users[:manager],:show)
    assert_equal true, @ballots[:current].may_user?(@users[:manager],:index)
    # Admin rights
    assert_equal false, @ballots[:current].may_user?(@users[:admin],:create)
    assert_equal false, @ballots[:current].may_user?(@users[:admin],:update)
    assert_equal true, @ballots[:current].may_user?(@users[:admin],:delete)
    assert_equal false, @ballots[:current].may_user?(@users[:admin],:show)
    assert_equal true, @ballots[:current].may_user?(@users[:admin],:index)
    # For past election
    # Unprivileged user rights
    assert_equal false, @ballots[:past].may_user?(@users[:public],:create)
    assert_equal false, @ballots[:past].may_user?(@users[:public],:update)
    assert_equal false, @ballots[:past].may_user?(@users[:public],:delete)
    assert_equal false, @ballots[:past].may_user?(@users[:public],:show)
    assert_equal false, @ballots[:past].may_user?(@users[:public],:index)
    # Voter rights
    assert_equal false, @ballots[:past].may_user?(@users[:voter],:create)
    assert_equal false, @ballots[:past].may_user?(@users[:voter],:update)
    assert_equal false, @ballots[:past].may_user?(@users[:voter],:delete)
    assert_equal false, @ballots[:past].may_user?(@users[:voter],:show)
    assert_equal false, @ballots[:past].may_user?(@users[:voter],:index)
    # Manager rights
    assert_equal false, @ballots[:past].may_user?(@users[:manager],:create)
    assert_equal false, @ballots[:past].may_user?(@users[:manager],:update)
    assert_equal false, @ballots[:past].may_user?(@users[:manager],:delete)
    assert_equal false, @ballots[:past].may_user?(@users[:manager],:show)
    assert_equal true, @ballots[:past].may_user?(@users[:manager],:index)
    # Admin rights
    assert_equal false, @ballots[:past].may_user?(@users[:admin],:create)
    assert_equal false, @ballots[:past].may_user?(@users[:admin],:update)
    assert_equal true, @ballots[:past].may_user?(@users[:admin],:delete)
    assert_equal false, @ballots[:past].may_user?(@users[:admin],:show)
    assert_equal true, @ballots[:past].may_user?(@users[:admin],:index)
    # For future election
    # Unprivileged user rights
    assert_equal false, @ballots[:future].may_user?(@users[:public],:create)
    assert_equal false, @ballots[:future].may_user?(@users[:public],:update)
    assert_equal false, @ballots[:future].may_user?(@users[:public],:delete)
    assert_equal false, @ballots[:future].may_user?(@users[:public],:show)
    assert_equal false, @ballots[:future].may_user?(@users[:public],:index)
    # Voter rights
    assert_equal false, @ballots[:future].may_user?(@users[:voter],:create)
    assert_equal false, @ballots[:future].may_user?(@users[:voter],:update)
    assert_equal false, @ballots[:future].may_user?(@users[:voter],:delete)
    assert_equal false, @ballots[:future].may_user?(@users[:voter],:show)
    assert_equal false, @ballots[:future].may_user?(@users[:voter],:index)
    # Manager rights
    assert_equal false, @ballots[:future].may_user?(@users[:manager],:create)
    assert_equal false, @ballots[:future].may_user?(@users[:manager],:update)
    assert_equal true, @ballots[:future].may_user?(@users[:manager],:delete)
    assert_equal false, @ballots[:future].may_user?(@users[:manager],:show)
    assert_equal true, @ballots[:future].may_user?(@users[:manager],:index)
    # Admin rights
    assert_equal false, @ballots[:future].may_user?(@users[:admin],:create)
    assert_equal false, @ballots[:future].may_user?(@users[:admin],:update)
    assert_equal true, @ballots[:future].may_user?(@users[:admin],:delete)
    assert_equal false, @ballots[:future].may_user?(@users[:admin],:show)
    assert_equal true, @ballots[:future].may_user?(@users[:admin],:index)
  end
  
  def teardown
    @ballot.destroy
  end
end
