require File.dirname(__FILE__) + '/../test_helper'

class RollTest < ActiveSupport::TestCase
  fixtures :elections
  
  def setup
    setup_elections
    @roll = elections(:current).rolls.create( :name => 'Test Role')
  end

  def test_import_users
    import_result = @roll.import_users([ ['abc1', 'abc1@example.com','Alpha','Beta'] ])
    assert_equal 1, import_result
    assert_equal 'abc1', @roll.users.last.user.net_id
    assert_equal 1, @roll.users.size
    @roll.users.delete(user.find_by_user_id(User.find_by_net_id('abc1').id))
  end
  
  def test_import_users_multiple
    @roll.import_users( [ [ 'abc1','abc1@example.com','Alpha','Beta-Gamma' ],
                          [ 'abc2','abc2@example.com','Alpha','Omega' ] ] )
    assert_equal "Beta-Gamma", User.find_by_net_id('abc1').last_name
    assert_equal true, @roll.users.include?(User.find_by_net_id('abc1'))
    assert_equal true, @roll.users.include?(User.find_by_net_id('abc2'))
    assert_equal 2, @roll.users.size
    @roll.users.delete(user.find_by_user_id(User.find_by_net_id('abc1').id))
    @roll.users.delete(user.find_by_user_id(User.find_by_net_id('abc2').id))
  end
  
  def test_import_users_from_csv_file
    @roll.import_users_from_csv_file(
      uploaded_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/users.csv")
    )
    assert_equal true, @roll.users.include?(User.find_by_net_id('abc1'))
    assert_equal true, @roll.users.include?(User.find_by_net_id('abc2'))
    assert_equal 2, @roll.users.size
    @roll.users.delete(User.find_by_net_id('abc1'))
    @roll.users.delete(User.find_by_net_id('abc2'))
  end
  
  def test_import_users_from_csv_string
    @roll.import_users_from_csv_string(
      FasterCSV.generate do |csv|
        csv << [ 'abc1','abc1@example.com','Alpha','Beta-Gamma' ]
        csv << [ 'abc2','abc2@example.com','Alpha','Omega' ]
      end
    )
    assert_equal true, @roll.users.include?(User.find_by_net_id('abc1'))
    assert_equal true, @roll.users.include?(User.find_by_net_id('abc2'))
    assert_equal 2, @roll.users.size
    @roll.users.delete(User.find_by_net_id('abc1'))
    @roll.users.delete(User.find_by_net_id('abc2'))
  end
  
  def teardown
    @roll.destroy
  end
end
