# mailgun_rails

*mailgun_rails* is an Action Mailer adapter for using [Mailgun](http://www.mailgun.com/) in Rails apps. It uses the [Mailgun HTTP API](http://documentation.mailgun.com/api_reference.html) internally.

## Installing

In your `Gemfile`

```ruby
gem 'mailgun_rails'
```

## Usage

To configure your Mailgun credentials place the following code in the corresponding environment file (`development.rb`, `production.rb`...)

```ruby
config.action_mailer.delivery_method = :mailgun
config.action_mailer.mailgun_settings = {
		api_key: '<mailgun api key>',
		domain: '<mailgun domain>'
}
```

Now you can send emails using plain Action Mailer:

```ruby
email = mail from: 'sender@email.com', to: 'receiver@email.com', subject: 'this is an email'
```

### [Mailgun variables](http://documentation.mailgun.com/user_manual.html#attaching-data-to-messages)

```ruby
email.mailgun_variables = {name_1: :value_1, name_2: value_2}
```

### [Recipient Variables (for batch sending)](http://documentation.mailgun.com/user_manual.html#batch-sending)

```ruby
email.mailgun_recipient_variables = {'user_1@email.com' => {id: 1}, 'user_2@email.com' => {id: 2}}
```

### [Custom MIME headers](http://documentation.mailgun.com/api-sending.html#sending)

```ruby
email.mailgun_headers = {foo: 'bar'}
```
## Pending

 - Sending attachments

Pull requests are welcomed






A NOTE ABOUT TESTING PLEASE READ: with caching enabled, the deliverer instance at the rails level is cached. therefore, since we're changing configs in the test suite, we need to make sure we use Hermes::Deliverer.new(@settings).deliver!(mail_msg) to avoid the caching behavior issues