Stripe.api_key             = "sk_test_GDxIyob2yYrppZ0bN8W1kHzY" #ENV['STRIPE_SECRET_KEY']
StripeEvent.signing_secret = "pk_test_iRcTotsaBsT8DUWwP87h1u4S" #ENV['STRIPE_SIGNING_SECRET']

# StripeEvent.configure do |events|
#   events.subscribe(
#     'invoice.payment_failed',
#     # PaymentGateway::Events::InvoicePaymentFailed.new)
# end