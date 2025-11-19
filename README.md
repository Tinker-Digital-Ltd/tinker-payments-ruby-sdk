# Tinker Payments Ruby SDK

Official Ruby SDK for [Tinker Payments API](https://payments.tinker.co.ke/docs).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tinker-pay-ruby-sdk'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install tinker-pay-ruby-sdk
```

## Requirements

- Ruby 3.0 or higher
- No external runtime dependencies (uses standard library)

## Quick Start

```ruby
require 'tinker'

tinker = Tinker::Payments.new(
  api_public_key: 'your-public-key',
  api_secret_key: 'your-secret-key'
)
```

## Usage

### Initiate a Payment

```ruby
require 'tinker'

begin
  initiate_request = Tinker::Model::Dto::InitiatePaymentRequestDto.new(
    amount: 100.00,
    currency: 'KES',
    gateway: Tinker::Enum::Gateway::MPESA,
    merchant_reference: 'ORDER-12345',
    return_url: 'https://your-app.com/payment/return',
    customer_phone: '+254712345678',
    transaction_desc: 'Payment for order #12345',
    metadata: { order_id: '12345' }
  )

  transaction = tinker.transactions.initiate(initiate_request)
  initiation_data = transaction.initiation_data

  if initiation_data&.authorization_url
    # Redirect user to authorization URL (Paystack, Stripe, etc.)
    redirect_to initiation_data.authorization_url
  end
rescue Tinker::Exception::ApiException => e
  puts "API Error: #{e.message}"
rescue Tinker::Exception::NetworkException => e
  puts "Network Error: #{e.message}"
end
```

**Note:** The `return_url` is where users are redirected after payment completion. Webhooks are configured separately in your dashboard.

### Query a Transaction

```ruby
query_request = Tinker::Model::Dto::QueryPaymentRequestDto.new(
  payment_reference: 'TXN-abc123xyz',
  gateway: Tinker::Enum::Gateway::MPESA
)

transaction = tinker.transactions.query(query_request)

if transaction.successful?
  query_data = transaction.query_data
  puts "Amount: #{query_data.amount} #{query_data.currency}"
end
```

### Handle Webhooks

Webhooks support multiple event types: payment, subscription, invoice, and settlement. Check the event type and handle accordingly:

```ruby
require 'tinker'

event = tinker.webhooks.handle_from_request(request.body.read)

# Check event type
if event.payment_event?
  payment_data = event.get_payment_data
  # Handle payment.completed, payment.failed, etc.
elsif event.subscription_event?
  subscription_data = event.get_subscription_data
  # Handle subscription.created, subscription.cancelled, etc.
elsif event.invoice_event?
  invoice_data = event.get_invoice_data
  # Handle invoice.paid, invoice.failed
elsif event.settlement_event?
  settlement_data = event.get_settlement_data
  # Handle settlement.processed
end

# Access event details
puts "Event type: #{event.type}"        # e.g., "payment.completed"
puts "Event source: #{event.source}"    # e.g., "payment"
puts "App ID: #{event.meta.app_id}"
puts "Signature: #{event.security.signature}"
```

For payment events only, you can convert to a `Transaction` object:

```ruby
transaction = tinker.webhooks.handle_as_transaction(request.body.read)
if transaction && transaction.successful?
  callback_data = transaction.callback_data
  puts "Payment successful: #{callback_data.reference}"
end
```

## Custom HTTP Client

You can use your own HTTP client by passing it to the constructor:

```ruby
require 'tinker'

# Create a custom HTTP client that responds to #post(url, headers:, body:)
# and returns an object with #status_code, #body, and #json methods
custom_client = MyCustomHttpClient.new

tinker = Tinker::Payments.new(
  api_public_key: 'your-public-key',
  api_secret_key: 'your-secret-key',
  http_client: custom_client
)
```

## Documentation

For detailed API documentation, visit [Tinker Payments API Documentation](https://payments.tinker.co.ke/docs).

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tinker/payments-ruby-sdk.

## License

MIT License

