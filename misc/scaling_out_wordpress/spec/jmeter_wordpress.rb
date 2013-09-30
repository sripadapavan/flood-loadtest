require 'ruby-jmeter'

Scenarios = {
  shakeout: {
    users: 5,
    rampup: 5,
    duration: 120
  },

  baseline: {
    users: 50,
    rampup: 60*2,
    duration: 600
  },

  load: {
    users: 1000,
    rampup: 1800,
    duration: 1800
  },

  stress: {
    users: 2000,
    rampup: 1800,
    duration: 1800
  }
}

test do
  
  defaults  domain: (ARGV[1] || 'loadtest.flood.io'), 
            protocol: 'http', 
            image_parser: true,
            concurrentDwn: true,
            concurrentPool: 1,
            implementation: 'HttpClient4',
            port: 80

  cache

  # cookies

  with_user_agent :chrome

  header [ 
    { name: 'Accept-Encoding', value: 'gzip,deflate,sdch' },
    { name: 'Accept', value: 'text/javascript, text/html, application/xml, text/xml, */*' }
  ]
  
  threads Scenarios[ARGV[0].to_sym][:users], {
    rampup: Scenarios[ARGV[0].to_sym][:rampup], 
    scheduler: true,
    duration: Scenarios[ARGV[0].to_sym][:duration], 
    continue_forever: true,
    delayedStart: true
    } do

    random_timer 10000, 5000

    visit name: 'app_home', url: '/wordpress/'
    
    visit name: 'app_sample_page', url: '/wordpress/sample-page/'
    
    visit name: 'app_search_random_word', url: '/wordpress/?s=Staircase'

  end

# end.jmx
end.flood ENV['FLOOD_API_TOKEN'], {
  region: 'us-west-2',
  name: "#{ARGV[0].capitalize} with JMeter for Wordpress",
  tag_list: ARGV[0]
}
