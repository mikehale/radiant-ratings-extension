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

      def get_yaml(filename)
        yaml_file = File.join(RatingsExtension.root, "db", filename)
        yaml = File.open(yaml_file) { |f| f.read }
        YAML.load(yaml)
      end

      namespace :update do
        desc "Updates the rating configuration settings for the ratings extension to the latest defaults"
        task :config => :environment do
          if Radiant::Config.table_exists?
            puts "Updating config settings..."
            get_yaml('config_defaults.yml').each do |key, value|
              c = Radiant::Config.find_or_initialize_by_key("ratings.#{key}")
              c.value = value
              c.save!
              puts "  - ratings.#{key} = #{value}"
            end
          else
            puts "The radiant config table does not exist.  Please create it, then re-run this migration."
          end
        end
      end

      namespace :delete do
        desc "Deletes the radiant configuration settings added by the ratings extension"
        task :config => :environment do
          if Radiant::Config.table_exists?
            puts "Deleting config settings..."
            get_yaml('config_defaults.yml').each do |key, value|
              if c = Radiant::Config.find_by_key("ratings.#{key}")
                c.destroy
                puts "  - ratings.#{key} = #{value}"
              end
            end
          end
        end
      end
    end
  end
end