module MonikerTestUtils

  private

  def auth_admin
    OpenStack::Keystone::Public::Base.site = TEST_CONFIG[:public_base_site]
    OpenStack::Keystone::Admin::Base.site = TEST_CONFIG[:public_admin_site]

    auth = OpenStack::Keystone::Public::Auth.new :username => TEST_CONFIG[:admin_username],
                                                 :password => TEST_CONFIG[:admin_password],
                                                 :tenant_id => TEST_CONFIG[:admin_tenant_id]

    if auth.save
      Moniker::Base.token = auth.token
      Moniker::Base.site = auth.endpoint_for('dns').publicURL
      Moniker::Base.sudo_tenant = TEST_CONFIG[:user_tenant_id]
    else
      raise "Cannot authenticate as admin!"
    end
  end

  def auth_user
    OpenStack::Keystone::Public::Base.site = TEST_CONFIG[:public_base_site]

    auth = OpenStack::Keystone::Public::Auth.new :username => TEST_CONFIG[:user_username],
                                                 :password => TEST_CONFIG[:user_password],
                                                 :tenant_id => TEST_CONFIG[:user_tenant_id]

    if auth.save
      Moniker::Base.token = auth.token
      Moniker::Base.site = auth.endpoint_for('dns').publicURL
    else
      raise "Cannot authenticate!"
    end

  end

  def keystone_admin_test_possible?
    TEST_CONFIG[:admin_username] and TEST_CONFIG[:admin_password] and TEST_CONFIG[:admin_tenant_id]
  end

  def keystone_user_test_possible?
    TEST_CONFIG[:user_username] and TEST_CONFIG[:user_password] and TEST_CONFIG[:user_tenant_id]
  end

  def active_resource_errors_to_s(active_resource)
    message = ""
    active_resource.errors.messages.each_pair { |k, v|
      message += "#{k}: " + v.join(",") + ". \n"
    }

    message
  end

end