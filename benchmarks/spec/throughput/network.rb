require 'ruby-jmeter'

test do

  threads count: 500,
          rampup: 60,
          scheduler: true,
          duration: 540,
          continue_forever: true,
          delayedStart: true  do

    constant_timer delay: 60000

    visit name: '1829kB', url: 'https://s3-ap-southeast-2.amazonaws.com/flood-loadtest/1829kb.html'
  end
end.flood(ENV['FLOOD_API_TOKEN'], {
  name: 'Throughput Test Single Node',
  tag_list: 'benchmarks',
  privacy_flag: 'public'})
