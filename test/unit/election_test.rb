require File.dirname(__FILE__) + '/../test_helper'

class ElectionTest < ActiveSupport::TestCase
  def setup
    setup_elections
  end
  
  def test_may_user
    # For current election
    # Unprivileged user rights
    assert_equal false, @elections[:current].may_user?(@users[:public],:create)
    assert_equal false, @elections[:current].may_user?(@users[:public],:update)
    assert_equal false, @elections[:current].may_user?(@users[:public],:delete)
    assert_equal true, @elections[:current].may_user?(@users[:public],:show)
    assert_equal true, @elections[:current].may_user?(@users[:public],:index)
    # Voter rights
    assert_equal false, @elections[:current].may_user?(@users[:voter],:create)
    assert_equal false, @elections[:current].may_user?(@users[:voter],:update)
    assert_equal false, @elections[:current].may_user?(@users[:voter],:delete)
    assert_equal true, @elections[:current].may_user?(@users[:voter],:show)
    assert_equal true, @elections[:current].may_user?(@users[:voter],:index)
    # Manager rights
    assert_equal false, @elections[:current].may_user?(@users[:manager],:create)
    assert_equal false, @elections[:current].may_user?(@users[:manager],:update)
    assert_equal false, @elections[:current].may_user?(@users[:manager],:delete)
    assert_equal true, @elections[:current].may_user?(@users[:manager],:show)
    assert_equal true, @elections[:current].may_user?(@users[:manager],:index)
    # Admin rights
    assert_equal true, @elections[:current].may_user?(@users[:admin],:create)
    assert_equal true, @elections[:current].may_user?(@users[:admin],:update)
    assert_equal true, @elections[:current].may_user?(@users[:admin],:delete)
    assert_equal true, @elections[:current].may_user?(@users[:admin],:show)
    assert_equal true, @elections[:current].may_user?(@users[:admin],:index)
    # For past election
    # Unprivileged user rights
    assert_equal false, @elections[:past].may_user?(@users[:public],:create)
    assert_equal false, @elections[:past].may_user?(@users[:public],:update)
    assert_equal false, @elections[:past].may_user?(@users[:public],:delete)
    assert_equal true, @elections[:past].may_user?(@users[:public],:show)
    assert_equal true, @elections[:past].may_user?(@users[:public],:index)
    # Voter rights
    assert_equal false, @elections[:past].may_user?(@users[:voter],:create)
    assert_equal false, @elections[:past].may_user?(@users[:voter],:update)
    assert_equal false, @elections[:past].may_user?(@users[:voter],:delete)
    assert_equal true, @elections[:past].may_user?(@users[:voter],:show)
    assert_equal true, @elections[:past].may_user?(@users[:voter],:index)
    # Manager rights
    assert_equal false, @elections[:past].may_user?(@users[:manager],:create)
    assert_equal false, @elections[:past].may_user?(@users[:manager],:update)
    assert_equal false, @elections[:past].may_user?(@users[:manager],:delete)
    assert_equal true, @elections[:past].may_user?(@users[:manager],:show)
    assert_equal true, @elections[:past].may_user?(@users[:manager],:index)
    # Admin rights
    assert_equal true, @elections[:past].may_user?(@users[:admin],:create)
    assert_equal true, @elections[:past].may_user?(@users[:admin],:update)
    assert_equal true, @elections[:past].may_user?(@users[:admin],:delete)
    assert_equal true, @elections[:past].may_user?(@users[:admin],:show)
    assert_equal true, @elections[:past].may_user?(@users[:admin],:index)
    # For future election
    # Unprivileged user rights
    assert_equal false, @elections[:future].may_user?(@users[:public],:create)
    assert_equal false, @elections[:future].may_user?(@users[:public],:update)
    assert_equal false, @elections[:future].may_user?(@users[:public],:delete)
    assert_equal false, @elections[:future].may_user?(@users[:public],:show)
    assert_equal false, @elections[:future].may_user?(@users[:public],:index)
    # Voter rights
    assert_equal false, @elections[:future].may_user?(@users[:voter],:create)
    assert_equal false, @elections[:future].may_user?(@users[:voter],:update)
    assert_equal false, @elections[:future].may_user?(@users[:voter],:delete)
    assert_equal false, @elections[:future].may_user?(@users[:voter],:show)
    assert_equal false, @elections[:future].may_user?(@users[:voter],:index)
    # Manager rights
    assert_equal false, @elections[:future].may_user?(@users[:manager],:create)
    assert_equal false, @elections[:future].may_user?(@users[:manager],:update)
    assert_equal false, @elections[:future].may_user?(@users[:manager],:delete)
    assert_equal true, @elections[:future].may_user?(@users[:manager],:show)
    assert_equal true, @elections[:future].may_user?(@users[:manager],:index)
    # Admin rights
    assert_equal true, @elections[:future].may_user?(@users[:admin],:create)
    assert_equal true, @elections[:future].may_user?(@users[:admin],:update)
    assert_equal true, @elections[:future].may_user?(@users[:admin],:delete)
    assert_equal true, @elections[:future].may_user?(@users[:admin],:show)
    assert_equal true, @elections[:future].may_user?(@users[:admin],:index)
  end
  
  def teardown
  end
end
