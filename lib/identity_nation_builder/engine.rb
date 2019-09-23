module IdentityNationBuilder
  class Engine < ::Rails::Engine
    isolate_namespace IdentityNationBuilder
    config.after_initialize do
      IdentityNationBuilder.sync_unsubscribes!
    end
  end
end
