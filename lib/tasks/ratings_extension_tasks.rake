namespace :radiant do
  namespace :extensions do
    namespace :ratings do
      desc "Single task to install and update the ratings extension"
      task :install => [:environment, :migrate, 'update:all']

      desc "Single task to uninstall the ratings extension"
      task :uninstall => :environment do
        if confirm('Are you sure you want to uninstall the ratings extension?  This will revert the migration, remove the ratings assets, and delete the rating snippets and config settings.')
          ENV['FORCE'] = 'true'
          %w(revert_migration delete:all).each { |t| Rake::Task["radiant:extensions:ratings:#{t}"].invoke }
        end
      end

      def confirm(question)
        require 'highline/import' unless respond_to?(:agree)
        ENV['FORCE'] || agree("#{question} [yn]")
      end

      desc "Runs the migration of the Ratings extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          RatingsExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          RatingsExtension.migrator.migrate
        end
      end

      desc "Reverts the migrations run by the ratings extension"
      task :revert_migration => :environment do
        if Rating.table_exists? && confirm("This task will destroy all your ratings data. Are you sure you want to continue?")
          require 'radiant/extension_migrator'
          RatingsExtension.migrator.migrate(0)
        end
      end

      def get_yaml(filename)
        yaml_file = File.join(RatingsExtension.root, "db", filename)
        yaml = File.open(yaml_file) { |f| f.read }
        YAML.load(yaml)
      end

      namespace :update do
        desc "Update assets and snippets for the ratings extension."
        task :all => [:environment, :config, :assets, :snippets]

        desc "Updates the rating configuration settings for the ratings extension to the latest defaults"
        task :config => :environment do
          if Radiant::Config.table_exists?
            puts "Updating config settings..."
            get_yaml('config_defaults.yml').each do |key, value|
              c = Radiant::Config.find_or_initialize_by_key("ratings.#{key}")
              if c.new_record? || confirm("Are you sure you want to overwrite existing config setting ratings.#{key}?")
                c.value = value
                c.save!
                puts "  - ratings.#{key} = #{value}"
              end
            end
          else
            puts "The radiant config table does not exist.  Please create it, then re-run this migration."
          end
        end

        desc "Copies public assets of the ratings extension to the instance public/ directory."
        task :assets => :environment do
          puts "Copying assets for the ratings extension..."
          Dir[RatingsExtension.root + "/public/**/*"].each do |file|
            next if File.directory?(file)

            path = file.sub(RatingsExtension.root, '')
            directory = File.dirname(path)
            if !File.exists?(RAILS_ROOT + path) || confirm("Are you sure you want to overwrite existing asset #{path}?")
              mkdir_p RAILS_ROOT + directory, :verbose => false
              cp file, RAILS_ROOT + path, :verbose => false
              puts "  - #{path}"
            end
          end
        end

        desc "Creates or updates the default snippets used by the ratings extension"
        task :snippets => :environment do
          puts "Updating snippets for the ratings extension..."
          get_yaml('snippets.yml').each do |snippet_name, snippet_content|
            s = Snippet.find_or_initialize_by_name(snippet_name)
            if s.new_record? || confirm("Are you sure you want to overwrite existing snippet #{snippet_name}?")
              s.content = snippet_content
              s.save!
              puts "  - #{snippet_name}"
            end
          end
        end
      end

      namespace :delete do
        desc "Deletes the assets and snippets installed by the ratings extension."
        task :all => [:environment, :config, :assets, :snippets]

        desc "Deletes the radiant configuration settings added by the ratings extension"
        task :config => :environment do
          if Radiant::Config.table_exists?
            puts "Deleting config settings..."
            get_yaml('config_defaults.yml').each do |key, value|
              if c = Radiant::Config.find_by_key("ratings.#{key}") and confirm("Are you sure you want to delete config setting ratings.#{key}?")
                c.destroy
                puts "  - ratings.#{key} = #{value}"
              end
            end
          end
        end

        desc "Deletes the public assets installed by the ratings extension."
        task :assets => :environment do
          puts "Deleting assets installed by the ratings extension..."
          Dir[RatingsExtension.root + "/public/**/*"].each do |file|
            next if File.directory?(file)
            path = file.sub(RatingsExtension.root, '')
            if File.exists?(RAILS_ROOT + path) && confirm("Are you sure you want to delete asset #{path}?")
              rm RAILS_ROOT + path, :verbose => false
              puts "  - #{path}"
            end
          end
        end

        desc "Deletes the snippets created as part of the ratings installation"
        task :snippets => :environment do
          puts "Deleting snippets installed by the ratings extension..."
          get_yaml('snippets.yml').each do |snippet_name, snippet_content|
            if s = Snippet.find_by_name(snippet_name) and confirm("Are you sure you want to delete snippet #{snippet_name}?")
              s.destroy
              puts "  - #{snippet_name}"
            end
          end
        end
      end
    end
  end
end