require 'ruby-jmeter'

test do
  
  defaults  domain: '172.31.2.77', 
            protocol: 'http', 
            image_parser: false,
            concurrentDwn: false,
            implementation: 'HttpClient4',
            port: 8000

  with_user_agent :chrome

  header [ 
    { name: 'Accept-Encoding', value: 'gzip,deflate,sdch' },
    { name: 'Accept', value: 'text/javascript, text/html, application/xml, text/xml, */*' }
  ]

  cache

  cookies

  threads count: "${__P(threads,5000)}",
          rampup: "${__P(rampup,300)}", 
          scheduler: true,
          duration: "${__P(duration,1800)}", 
          continue_forever: true,
          delayedStart: true  do

    constant_timer delay: 15000

    # get a slow resource 20% of the time
    throughput_controller percent: 20 do
      get name: 'get_slow', url: '/slow'
    end

    # get a cacheable resource 40% of the time
    throughput_controller percent: 40 do
      get name: 'get_cacheable', url: '/plain_text.html'
    end

    # get a non-cacheable resource 30% of the time
    throughput_controller percent: 30 do
      get name: 'get_non_cacheable', url: '/non_cacheable?id=${__counter(true,counter)}' do
        extract name: 'response_value', regex: 'Little Blind (\w+)'
        assert contains: 'Little Blind Text'
      end
    end

    # post to a cacheable resource 10% of the time
    throughput_controller percent: 10 do
      post name: 'post_cacheable', url: '/?id=${__counter(true,counter)}' do
        assert contains: '200|304', test_field: 'Assertion.response_code'
      end
    end

  end

end.jmx
