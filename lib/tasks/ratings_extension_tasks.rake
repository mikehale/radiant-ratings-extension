namespace :radiant do
  namespace :extensions do
    namespace :ratings do

      desc "Runs the migration of the Ratings extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          RatingsExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          RatingsExtension.migrator.migrate
        end
      end
      
      task :update do
      end

    end
  end
end