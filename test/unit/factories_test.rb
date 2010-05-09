require File.dirname(__FILE__) + '/../test_helper'

class FactoriesTest < ActiveSupport::TestCase

# there can be only one ...
#  test "should create a government" do
#    government = Factory(:government)
#    assert_kind_of Government, government
#    assert !government.new_record?
#  end

  test "should create a user" do
    user = Factory(:user)
    assert_kind_of User, user
    assert !user.new_record?
  end
 
end
