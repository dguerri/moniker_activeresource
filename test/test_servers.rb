test_path = File.expand_path('..', __FILE__)
$:.unshift(test_path)

require 'helper'

class TestMonikerServers < Test::Unit::TestCase
  include MonikerTestUtils

  def _server_create(name)

    assert_nothing_raised ActiveResource::ClientError, "Failed to create a server for tenant #{Moniker::Base.sudo_tenant}" do
      new_server = Moniker::Server.create :name => name
      assert_not_nil new_server.id, "Failed to create a server:\n#{active_resource_errors_to_s(new_server)}"
    end
  end

  def test_10_server_create
    if keystone_admin_test_possible?
      auth_admin

      _server_create("test.test-server.test.")
    end
  end

  def _server_list
    assert_nothing_raised ActiveResource::ClientError, "Failed to list servers for tenant #{Moniker::Base.sudo_tenant}" do
      servers = Moniker::Server.all
      assert_not_nil servers
      assert_block("No servers?") do
        !servers.empty?
      end
    end
  end

  def test_20_server_list
    if keystone_admin_test_possible?
      auth_admin

      _server_list
    end
  end

  def _server_get(name)
    assert_nothing_raised ActiveResource::ClientError, "Failed to get server '#{name}'" do
      server = Moniker::Server.find_by_name name
      assert_not_nil server, "Failed to get server '#{name}'"
    end

    # Must use a syntactically correct UUID or Moniker will complain about a 'badly formed hexadecimal UUID string'...
    assert_raises ActiveResource::ResourceNotFound, "Server retrieval broken?!?" do
      Moniker::Server.find "ffffffff-ffff-ffff-ffff-ffffffffffff"
    end

  end

  def test_30_server_get
    if keystone_admin_test_possible?
      auth_admin

      _server_get("test.test-server.test.")
    end
  end

  def _server_update(name)
    server = Moniker::Server.find_by_name name
    assert_nothing_raised ActiveResource::ClientError, "Failed to update server '#{server.id}'" do
      server.update_attributes :name => "upd-" + name
      assert_true server.save, "Failed to update server '#{server.id}': #{active_resource_errors_to_s(server)}"
    end
    assert_nothing_raised ActiveResource::ClientError, "Failed to update server '#{server.id}'" do
      server.update_attributes :name => name
      assert_true server.save, "Failed to update server '#{server.id}': #{active_resource_errors_to_s(server)}"
    end
  end

  def test_40_server_update
    if keystone_admin_test_possible?
      auth_admin

      _server_update("test.test-server.test.")
    end
  end

  def _server_destroy(name)
    server = Moniker::Server.find_by_name name

    assert_nothing_raised ActiveResource::ClientError, "Failed to destroy server '#{server.id}'" do
      server.destroy
    end
  end

  def test_50_server_destroy
    if keystone_admin_test_possible?
      auth_admin

      _server_destroy("test.test-server.test.")
    end
  end

end