module IdentityNationBuilder
  class UnsubscribeFromNationBuilderWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'critical'

    def perform(member_id, subscription_id)
      Rails.logger.info "Unsub from NB: #{member_id}"
      member = Member.find member_id
      person_id = nb_person_id member
      if person_id.nil?
        Rails.logger.warn "Cannot find member (id ##{member.id} #{member.email}) in Nation Builder"
        return
      end

      unsubscribe(person_id, subscription_id)
    end

    def nb_person_id(member)
      ext_id = member.member_external_ids.where(system: 'nation_builder').first

      if ext_id.nil?
        resp = nil
        if member.email.present?
          resp = API.api(:people, :match, { email: member.email })
        elsif pn = member.phone_numbers.first
          resp = API.api(:people, :match, { mobile: pn.phone })
        end

        if resp.has_key? 'person'
          ext_id = member.update_external_id('nation_builder', resp['person']['id'])
        end
      end

      if ext_id.nil?
        return nil
      end

      return ext_id.external_id.to_i
    end

    def unsubscribe(person_id, subscription_id)
      if subscription_id == Subscription::EMAIL_SUBSCRIPTION.id
        attr = { email_opt_in: false }
      elsif subscription_id == Subscription::SMS_SUBSCRIPTION.id
        attr = { mobile_opt_in: false }
      else
        return
      end

      API.api(:people, :update, { id: person_id, person: attr})
    end
  end
end
