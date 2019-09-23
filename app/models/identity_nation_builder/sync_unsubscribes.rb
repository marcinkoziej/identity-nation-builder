# not sure why this is not loaded
require_relative '../../workers/unsubscribe_from_nation_builder_worker.rb'

module IdentityNationBuilder
  module SyncUnsubscribes
    extend ActiveSupport::Concern

    included do
      after_commit :unsubscribe_from_nation_builder
    end

    def unsubscribe_from_nation_builder
      unsubscribed = previous_changes['unsubscribed_at']
      if unsubscribed
        if unsubscribed[0] == nil && unsubscribed[1] != nil &&
           self.unsubscribe_mailing_id != nil
          UnsubscribeFromNationBuilderWorker.perform_async(self.member_id)
        end
      end
    end
  end
end
