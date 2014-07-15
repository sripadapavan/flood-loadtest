require 'ruby-jmeter'

test do

  defaults  domain: '172.31.2.77',
            port: 9000

  with_user_agent :chrome

  threads count: 1000,
          rampup: 60,
          scheduler: true,
          duration: 120,
          continue_forever: true,
          delayedStart: true  do

    constant_timer delay: 1000

    visit name: 'throughput', url: '/plain_text.html'
  end
end.flood(ENV['FLOOD_API_TOKEN'], {
  name: 'Throughput Test Single Node',
  tag_list: 'benchmarks',
  privacy_flag: 'public'})
