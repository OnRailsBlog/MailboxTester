#Readme

Do you send lots of emails with your Rails app, and wish you had a way to spot check them? Fix those typos, and make sure the dynamic content looks correct? It’s easy to verify there are no code bugs with [Rail’s builtin Mailer preview](https://guides.rubyonrails.org/action_mailer_basics.html#previewing-emails). But how do you prevent sending someone’s wrong order or personal information, especially if it’s in a batch of emails? You need to generate those emails, and make sure they match everything.

## Introducing MailboxTester
Using the new [ActionMailbox framework](https://guides.rubyonrails.org/action_mailbox_basics.html), you can create an app that easily accepts emails. Since the goal is to see what arrived in the inbox, you’ll need an SMTP server to receive the email from your other app. Thankfully, there is no need for Postfix when you can use a ruby library, [MidiSmtpServer](https://midi-smtp-server.readthedocs.io) to receive the emails, and route them to ActionMailbox.  

## Configuring your app
You need to tell your server to send mail to the SMTP service. MailboxTest listens at port 2525:
```bash
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { address: '127.0.0.1', port: 2525 } 
```

MailboxTester uses foreman to start the smtp service and the rails app that receives the emails from the SMTP service.
```bash
$ foreman start
```

Start sending emails from your app, and watch them appear on the MailboxTester page. You can see the text and html views, and make sure that every looks correct.

Let me know how this works for you!

Here are some commands that were used to set this up.

```shell script
rails new MailboxTester --database=postgresql --webpack=stimulus
yarn add bulma
```

You’ll need to create a Postgres user:
```shell script
$ createuser --createdb --login -P mailbox_tester
```

## Install ActionMailbox 

This follows some of the commands from https://edgeguides.rubyonrails.org/action_mailbox_basics.html

```shell script
bin/rails action_mailbox:install
bin/rails db:create
bin/rails db:migrate
bin/rails generate mailbox all_emails
```

Run everything with Foreman:
```shell script
foreman start
```

