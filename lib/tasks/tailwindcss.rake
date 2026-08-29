namespace :tailwindcss do
  desc "Skip Tailwind build because the project uses Bootstrap"
  task :build do
    puts "Skipping Tailwind CSS build: the project uses Bootstrap"
  end
end
