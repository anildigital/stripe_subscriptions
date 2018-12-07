require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "As a user, I should be able to see stripe plans" do
    stripe_plans = Stripe::Plan.list(limit: 3)

    assert_equal stripe_plans.data[0].id, "logicboard-enterprise"
    assert_equal stripe_plans.data[1].id, "logicboard-team"
    assert_equal stripe_plans.data[2].id, "logicboard-personal"
  end

  test "As a user I should be able to subscribe to particular stripe plan" do

    stripe_plans = Stripe::Plan.list(limit: 3)

    plan = stripe_plans.data[2]

    user = User.first

    # create stripe customer
    customer = Stripe::Customer.create(:description => "Email anil@xyz.com")
    card = customer.sources.create(source: "tok_mastercard")

    user.stripe_customer_id = customer.id
    user.save!

    # create stripe subscription with particular user and a plan

    subscription = Stripe::Subscription.create(
      :customer => customer.id,
      :items => [
        {
          :plan => plan.id,
        },
      ]
    )

    # assert that there is a subscription for the given stripe customer id

    stripe_customer = Stripe::Customer.retrieve(customer.id)

    puts stripe_customer
    # assert that subscription has proper plan assigned
  end
end
