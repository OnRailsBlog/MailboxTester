# frozen_string_literal: true

require 'midi-smtp-server'
require 'mail'
require "action_mailbox/relayer"

# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("mail received at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}] from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message once to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message source
    url, password = ENV.values_at("URL", "INGRESS_PASSWORD")

    ActionMailbox::Relayer.new(url: url, password: password).relay(@mail.to_s).tap do |result|
      case
      when result.success?
        logger.debug "success"
      when result.transient_failure?
        logger.debug "EX_TEMPFAIL"
      else
        logger.debug "EX_UNAVAILABLE"
      end
    end
  end
end

# try to gracefully shutdown on Ctrl-C
trap('INT') do
  puts 'Interrupted, exit now...'
  exit 0
end

# Output for debug
puts "#{Time.now}: Starting SMTP Server [#{MidiSmtpServer::VERSION::STRING}|#{MidiSmtpServer::VERSION::DATE}]"

url, password = ENV.values_at("URL", "INGRESS_PASSWORD")

if url.nil? || password.nil?
  print "URL and INGRESS_PASSWORD are required"
  exit -1 # EX_USAGE
end

# Create a new server instance listening at localhost interfaces 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections
server = MySmtpd.new

# setup exit code
at_exit do
  # check to shutdown connection
  if server
    # Output for debug
    puts "#{Time.now}: Shutdown SMTP..."
    # stop all threads and connections gracefully
    server.stop
  end
  # Output for debug
  puts "#{Time.now}: SMTP down!\n"
end

# Start the server
server.start

# Run on server forever
server.join