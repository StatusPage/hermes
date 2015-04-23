require 'test_helper'

describe Hermes::Provider do
  it "enforces required credentials" do
    # missing all
    assert_raises Hermes::InsufficientCredentialsError do
      Hermes::FakeVendorProvider.new(nil, {
        weight: 1
      })
    end

    # missing some
    assert_raises Hermes::InsufficientCredentialsError do
      Hermes::FakeVendorProvider.new(nil, {
        weight: 1,
        credentials: {
          api_key: 'asdf'
        }
      })
    end

    # got em all
    Hermes::FakeVendorProvider.new(nil, {
      weight: 1,
      credentials: {
        api_key: 'asdf',
        api_token: 'qwerty'
      }
    })

    # don't care about extras
    Hermes::FakeVendorProvider.new(nil, {
      weight: 1,
      credentials: {
        api_key: 'asdf',
        api_token: 'qwerty',
        extra: 'asdf'
      }
    })
  end

  it "enforces weight >= 0" do
    # negatives cant work
    assert_raises Hermes::InvalidWeightError do
      Hermes::FakeVendorProvider.new(nil, {
        weight: -1,
        credentials: {
          api_key: 'asdf',
          api_token: 'qwerty'
        }
      })
    end

    # nil is equivalent of 0
    provider = Hermes::FakeVendorProvider.new(nil, {
      weight: nil,
      credentials: {
        api_key: 'asdf',
        api_token: 'qwerty'
      }
    })
    assert_equal 0, provider.weight

    # normal
    provider = Hermes::FakeVendorProvider.new(nil, {
      weight: 5,
      credentials: {
        api_key: 'asdf',
        api_token: 'qwerty'
      }
    })
    assert_equal 5, provider.weight
  end

  it "has a common name that we can get" do
    provider = Hermes::FakeVendorProvider.new(nil, {
      weight: 5,
      credentials: {
        api_key: 'asdf',
        api_token: 'qwerty'
      }
    })
    assert_equal "fake_vendor", provider.common_name
  end

  it "requires the provider define the #send_message method" do
    provider = Hermes::NonCompliantProvider.new(nil, {})

    assert_raises Hermes::ProviderInterfaceError do
      provider.send_message(nil)
    end
  end
end