require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'As a user, I should be able to see stripe plans' do
    stripe_plans = Stripe::Plan.list(limit: 3)

    assert_equal stripe_plans.data[0].id, 'logicboard-enterprise'
    assert_equal stripe_plans.data[1].id, 'logicboard-team'
    assert_equal stripe_plans.data[2].id, 'logicboard-personal'
  end

  test 'As a user I should be able to subscribe to particular stripe plan' do
    stripe_plans = Stripe::Plan.list(limit: 3)
    plan = stripe_plans.data[2]
    
    user = User.first

    customer = Stripe::Customer.create(description: 'Email anil@xyz.com')
    card = customer.sources.create(source: 'tok_mastercard')

    user.stripe_customer_id = customer.id
    user.save!

    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [
        {
          plan: plan.id
        }
      ]
    )

    # assert that there is a subscription for the given stripe customer id

    stripe_customer = Stripe::Customer.retrieve(customer.id)

    assert stripe_customer.subscriptions != []
    # assert that subscription has proper plan assigned
  end

  test 'As a user, I should be able to cancel a subscription' do
    stripe_plans = Stripe::Plan.list(limit: 3)

    plan = stripe_plans.data[2]

    user = User.first

    # create stripe customer
    customer = Stripe::Customer.create(description: 'Email anil@xyz.com')
    card = customer.sources.create(source: 'tok_mastercard')

    user.stripe_customer_id = customer.id
    user.save!

    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [
        {
          plan: plan.id
        }
      ]
    )

    sub = Stripe::Subscription.retrieve(subscription.id)
    puts sub.status
    sub.delete

    sub = Stripe::Subscription.retrieve(subscription.id)
    puts sub.status
  end

  test 'As a user, I should be able to upgrade from plan A to plan B' do
    stripe_plans = Stripe::Plan.list(limit: 3)

    planA = stripe_plans.data[2]

    user = User.first

    customer = Stripe::Customer.create(description: 'Email anil@xyz.com')
    card = customer.sources.create(source: 'tok_mastercard')

    user.stripe_customer_id = customer.id
    user.save!

    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [
        {
          plan: planA.id
        }
      ]
    )

    customer = Stripe::Customer.retrieve(customer.id)

    puts customer.subscriptions

    planB = stripe_plans.data[1]

    puts planB.id

    subscription = Stripe::Subscription.retrieve(subscription.id)
    subscription.cancel_at_period_end = false

    puts subscription.items.data[0].id

    subscription.items = [{
      id: subscription.items.data[0].id,
      plan: planB.id
    }]

    subscription.save

    stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)

    puts stripe_customer.subscriptions
  end
end
