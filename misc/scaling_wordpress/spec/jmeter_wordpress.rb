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
    users: 200,
    rampup: 480,
    duration: 600
  },

  stress: {
    users: 1000,
    rampup: 1200,
    duration: 1200
  }
}

test do
  
  defaults  domain: (ARGV[1] || 'ec2-54-252-205-252.ap-southeast-2.compute.amazonaws.com'), 
            protocol: 'http', 
            image_parser: true,
            concurrentDwn: true,
            concurrentPool: 4,
            port: 6081

  cache

  cookies

  with_user_agent :chrome

  header [ 
    { name: 'Accept-Encoding', value: 'gzip,deflate,sdch' },
    { name: 'Accept', value: 'text/javascript, text/html, application/xml, text/xml, */*' }
  ]
  
  threads Scenarios[ARGV[0].to_sym][:users], {
    rampup: Scenarios[ARGV[0].to_sym][:rampup], 
    scheduler: true,
    duration: Scenarios[ARGV[0].to_sym][:duration], 
    continue_forever: true
    } do

    random_timer 10000, 5000

    get name: '__testdata', url: 'http://54.252.206.143:8080/SRANDMEMBER/random_words?type=text' do 
      extract name: 'random_word', regex: '^.+?"(\w+)"'
    end

    visit name: 'app_home', url: '/wordpress/'
    
    visit name: 'app_sample_page', url: '/wordpress/sample-page/'
    
    visit name: 'app_search_random_word', url: '/wordpress/?s=${random_word}'

    log filename: '/var/log/flood/custom.log', error_logging: true 

  end

# end.jmx
end.flood ENV['FLOOD_API_TOKEN'], {
  region: 'ap-southeast-2',
  name: "#{ARGV[0].capitalize} with JMeter for Wordpress",
  tag_list: ARGV[0]
}
