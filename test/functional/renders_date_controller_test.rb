require './test/test_helper'
require 'action_controller'
require 'action_controller/test_case'

class RendersDateControllerTest < ActionController::TestCase

  setup do
    @previous_supported_version_numbers = VersionCake::Configuration.supported_version_numbers
    @previous_version_format            = VersionCake::Configuration.version_format
    VersionCake::Configuration.supported_version_numbers = [Date.parse("2013-01-01"), Date.parse("2013-05-01"), Date.parse("2013-09-01")]
    VersionCake::Configuration.version_format = :date
    VersionCake::Configuration.extraction_strategy = :query_parameter
  end

  teardown do
    VersionCake::Configuration.supported_version_numbers = @previous_supported_version_numbers
    VersionCake::Configuration.version_format            = @previous_version_format
  end

  test "render latest version of partial" do
    get :index
    assert_equal "template v2013-09-01", @response.body
  end

  test "requesting version retrieves the matching version" do
    get :index, "api_version" => "2013-01-01"
    assert_equal "template v2013-01-01", @response.body
  end

  test "requesting version retrieves the closest previous version" do
    get :index, "api_version" => "2013-06-01"
    assert_equal "template v2013-05-01", @response.body
  end
end
