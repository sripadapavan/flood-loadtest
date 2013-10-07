require 'ruby-jmeter'

test do
  
  defaults  domain: 'flood.io', 
            protocol: 'https', 
            image_parser: true,
            concurrentDwn: true,
            concurrentPool: 4,
            implementation: 'HttpClient4'

  with_user_agent :chrome

  header [ 
    { name: 'Accept-Encoding', value: 'gzip,deflate,sdch' },
    { name: 'Accept', value: 'text/javascript, text/html, application/xml, text/xml, */*' }
  ]

  cache

  cookies

  threads count: "${__P(threads,500)}",
          rampup: "${__P(rampup,300)}", 
          scheduler: true,
          duration: "${__P(duration,1800)}", 
          continue_forever: true,
          delayedStart: true  do

    constant_timer delay: 30000

    visit '/' do
      assert contains: 'Try it now for free'
    end

    visit '/blog/15-new-relic-integration' do
      assert contains: 'great for development and operations', scope: 'children'
    end

  end

end.flood(ENV['FLOOD_API_TOKEN'], {
  name: 'the flood.io blog',
  region: 'ap-southeast-2'
})
