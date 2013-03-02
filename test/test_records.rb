test_path = File.expand_path('..', __FILE__)
$:.unshift(test_path)

require 'helper'

class TestMonikerRecords < Test::Unit::TestCase
  include MonikerTestUtils

  def _record_create(name)
    domain = Moniker::Domain.find TEST_CONFIG[:domain_id]
    record_name = "#{name}.#{domain.name}"
    assert_nothing_raised ActiveResource::ClientError, "Failed to create a record for domain '#{TEST_CONFIG[:record_id]}' for tenant #{Moniker::Base.sudo_tenant}" do
      new_record = Moniker::Record.create :name => record_name,
                                          :type => "A",
                                          :data => "1.1.1.1",
                                          :domain_id => TEST_CONFIG[:domain_id]
      assert_not_nil new_record.id, "Failed to create a record:\n#{active_resource_errors_to_s(new_record)}"
    end
  end

  def test_10_record_create
    if keystone_user_test_possible?
      auth_user

      _record_create("test")
    end

    if keystone_admin_test_possible?
      auth_admin

      _record_create("admin-test")
    end

  end

  def _record_list
    assert_nothing_raised ActiveResource::ClientError, "Failed to list records for domain '#{TEST_CONFIG[:record_id]}'" do
      records = Moniker::Record.all :params => {:domain_id => TEST_CONFIG[:domain_id]}
      assert_not_nil records
      assert_block("No records?") do
        !records.empty?
      end
    end
  end

  def test_20_record_list
    if keystone_user_test_possible?
      auth_user

      _record_list
    end

    if keystone_admin_test_possible?
      auth_admin

      _record_list
    end
  end

  def _record_get(name)
    domain = Moniker::Domain.find TEST_CONFIG[:domain_id]
    record_name = "#{name}.#{domain.name}"
    assert_nothing_raised ActiveResource::ClientError, "Failed to get record '#{record_name}'" do
      record = Moniker::Record.find_by_name record_name, :params => {:domain_id => domain.id}
      assert_not_nil record, "Failed to get record '#{record_name}'"
    end

    # Must use a syntactically correct UUID or Moniker will complain about a 'badly formed hexadecimal UUID string'...
    assert_raises ActiveResource::ResourceNotFound, "Record retrieval broken?!?" do
      Moniker::Record.find "ffffffff-ffff-ffff-ffff-ffffffffffff", :params => {:domain_id => domain.id}
    end

  end

  def test_30_record_get
    if keystone_user_test_possible?
      auth_user

      _record_get("test")
    end

    if keystone_admin_test_possible?
      auth_admin

      _record_get("admin-test")
    end
  end

  def _record_update(name)
    domain = Moniker::Domain.find TEST_CONFIG[:domain_id]
    record_name = "#{name}.#{domain.name}"
    record = Moniker::Record.find_by_name record_name, :params => {:domain_id => domain.id}
    assert_nothing_raised ActiveResource::ClientError, "Failed to update record '#{record.id}'" do
      record.update_attributes :ttl => 225
      assert_true record.save, "Failed to update record '#{record.id}': #{active_resource_errors_to_s(record)}"
    end
  end

  def test_40_record_update
    if keystone_user_test_possible?
      auth_user

      _record_update("test")
    end

    if keystone_admin_test_possible?
      auth_admin

      _record_update("admin-test")
    end
  end

  def _record_destroy(name)
    domain = Moniker::Domain.find TEST_CONFIG[:domain_id]
    record_name = "#{name}.#{domain.name}"
    record = Moniker::Record.find_by_name record_name, :params => {:domain_id => domain.id}

    assert_nothing_raised ActiveResource::ClientError, "Failed to destroy record '#{record.id}'" do
      record.destroy
    end
  end

  def test_50_record_destroy
    if keystone_user_test_possible?
      auth_user

      _record_destroy("test")
    end

    if keystone_admin_test_possible?
      auth_admin

      _record_destroy("admin-test")
    end
  end

end