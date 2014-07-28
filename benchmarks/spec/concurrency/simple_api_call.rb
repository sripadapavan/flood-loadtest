require 'ruby-jmeter'

test do

  defaults  domain: 's3-ap-southeast-2.amazonaws.com',
            protocol: 'https'

  with_user_agent :iphone

  header [
    { name: 'Accept-Encoding', value: 'gzip,deflate,sdch' },
    { name: 'Accept', value: 'text/javascript, text/html, application/xml, text/xml, */*' }
  ]

  threads count: 5000,
          rampup: 240,
          scheduler: true,
          duration: 1800,
          continue_forever: true,
          delayedStart: true  do

    constant_timer delay: 10000

    get name: 'api', url: '/flood-loadtest/api.json'
  end
end.jmx
# end.flood(ENV['FLOOD_API_TOKEN'], {
#   name: 'High API Concurrency JMeter',
#   tag_list: 'benchmarks',
#   privacy_flag: 'public'})
