test_path = File.expand_path('..', __FILE__)
$:.unshift(test_path)

require 'helper'

class TestMonikerDomains < Test::Unit::TestCase
  include MonikerTestUtils

  def _domain_create(name)

    assert_nothing_raised ActiveResource::ClientError, "Failed to create a domain for tenant #{Moniker::Base.sudo_tenant}" do
      new_domain = Moniker::Domain.create :name => name, :email => "fake@pretend.net"
      assert_not_nil new_domain.id, "Failed to create a domain:\n#{active_resource_errors_to_s(new_domain)}"
    end
  end

  def test_10_domain_create
    if keystone_admin_test_possible?
      auth_admin

      _domain_create("test.test-domain.test.")
    end
  end

  def _domain_list
    assert_nothing_raised ActiveResource::ClientError, "Failed to list domains for tenant #{Moniker::Base.sudo_tenant}" do
      domains = Moniker::Domain.all
      assert_not_nil domains
      assert_block("No domains?") do
        !domains.empty?
      end
    end
  end

  def test_20_domain_list
    if keystone_user_test_possible?
      auth_user

      _domain_list
    end

    if keystone_admin_test_possible?
      auth_admin

      _domain_list
    end
  end

  def _domain_get(name)
    assert_nothing_raised ActiveResource::ClientError, "Failed to get domain '#{name}'" do
      domain = Moniker::Domain.find_by_name name
      assert_not_nil domain, "Failed to get domain '#{name}'"
    end

    # Must use a syntactically correct UUID or Moniker will complain about a 'badly formed hexadecimal UUID string'...
    assert_raises ActiveResource::ResourceNotFound, "Domain retrieval broken?!?" do
      Moniker::Domain.find "ffffffff-ffff-ffff-ffff-ffffffffffff"
    end

  end

  def test_30_domain_get
    if keystone_user_test_possible?
      auth_user

      _domain_get("test.test-domain.test.")
    end

    if keystone_admin_test_possible?
      auth_admin

      _domain_get("test.test-domain.test.")
    end
  end

  def _domain_update(name)
    domain = Moniker::Domain.find_by_name name
    assert_nothing_raised ActiveResource::ClientError, "Failed to update domain '#{domain.id}'" do
      domain.update_attributes :ttl => 225
      assert_true domain.save, "Failed to update domain '#{domain.id}': #{active_resource_errors_to_s(domain)}"
    end
  end

  def test_40_domain_update
    if keystone_admin_test_possible?
      auth_admin

      _domain_update("test.test-domain.test.")
    end
  end

  def _domain_destroy(name)
    domain = Moniker::Domain.find_by_name name

    assert_nothing_raised ActiveResource::ClientError, "Failed to destroy domain '#{domain.id}'" do
      domain.destroy
    end
  end

  def test_50_domain_destroy
    if keystone_admin_test_possible?
      auth_admin

      _domain_destroy("test.test-domain.test.")
    end
  end

end