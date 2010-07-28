namespace :universal_navigation do
  desc "Syncronize extra files for Universal Navigation."
  task :sync do
    system "rsync -ruv --exclude '.*' vendor/plugins/universal_navigation/public ."
  end
end