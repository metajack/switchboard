module Switchboard
  module Commands
    class PubSub
      class Subscriptions < Switchboard::Command
        description "List pubsub subscriptions"

        def self.run!
          switchboard = Switchboard::Client.new do
            # this executes in the main loop, so it doesn't really matter that this runs in a different thread
            defer :subscriptions_received do
              subscriptions(settings["pubsub.node"])
            end

            # define here or as hydrant.subscriptions_received
            def subscriptions_received(subscriptions)
              if subscriptions && subscriptions.any?
                puts "Subscriptions:"
                puts subscriptions.collect { |subscription| [subscription.subid, "#{subscription.jid || settings["jid"]} => #{subscription.node} (#{subscription.state})"].compact * ": " } * "\n"
              else
                puts "No subscriptions."
              end
            end
          end

          if defined?(OAuth) && OPTIONS["oauth"]
            switchboard.plug!(OAuthPubSubJack)
          else
            switchboard.plug!(PubSubJack)
          end
          switchboard.run!
        end
      end
    end
  end
end