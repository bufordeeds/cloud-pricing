namespace :pricing do
  desc "Import pricing data from all providers"
  task import: :environment do
    Provider.seed!

    %w[aws gcp azure].each do |slug|
      begin
        Rake::Task["pricing:import:#{slug}"].invoke
      rescue => e
        puts "Failed to import #{slug}: #{e.message}"
      end
    end
  end

  namespace :import do
    desc "Import AWS EC2 pricing"
    task aws: :environment do
      Provider.seed!
      puts "Importing AWS pricing..."
      count = Pricing::AwsImporter.new.import!
      puts "AWS: imported #{count} instances"
    end

    desc "Import GCP Compute Engine pricing"
    task gcp: :environment do
      Provider.seed!
      puts "Importing GCP pricing..."
      count = Pricing::GcpImporter.new.import!
      puts "GCP: imported #{count} instances"
    end

    desc "Import Azure VM pricing"
    task azure: :environment do
      Provider.seed!
      puts "Importing Azure pricing..."
      count = Pricing::AzureImporter.new.import!
      puts "Azure: imported #{count} instances"
    end
  end
end
