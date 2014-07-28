require 'ruby-jmeter'

test do

  defaults  domain: 's3-ap-southeast-2.amazonaws.com',
            protocol: 'https',
            image_parser: true,
            concurrentDwn: true,
            implementation: 'HttpClient4',
            urls_must_match: 'https://s3-ap-southeast-2\.amazonaws.com.*'

  with_user_agent :chrome

  header [
    { name: 'Accept-Encoding', value: 'gzip,deflate,sdch' },
    { name: 'Accept', value: 'text/javascript, text/html, application/xml, text/xml, */*' }
  ]

  cache clear_each_iteration: true

  cookies clear_each_iteration: true

  threads count: 1000,
          rampup: 240,
          scheduler: true,
          duration: 300,
          continue_forever: true,
          delayedStart: true  do

    constant_timer delay: 20000

    extract name: 'viewstate', regex: 'id="__VIEWSTATE" value="(.+?)"'

    Once do
      visit name: 'home', url: '/flood-loadtest/index.html' do
        assert substring: 'beautiful', scope: 'main'
      end
    end

    exists 'viewstate' do
      visit name: 'blog', url: '/flood-loadtest/blog.html'
      visit name: 'blog-post', url: '/flood-loadtest/blog-post.html'
      visit name: 'faq', url: '/flood-loadtest/faq.html'
      visit name: 'features', url: '/flood-loadtest/features.html'
      visit name: 'about', url: '/flood-loadtest/aboutus.html'
      visit name: 'contact', url: '/flood-loadtest/contact.html'
      visit name: 'coming-soon', url: '/flood-loadtest/coming-soon.html'
      visit name: 'portfolio', url: '/flood-loadtest/portfolio.html'
    end

  end
# end.run(path: '/usr/share/jmeter-2.11/bin/', gui: true)
end.flood(ENV['FLOOD_API_TOKEN'], {
  name: 'High Concurrency JMeter',
  tag_list: 'benchmarks',
  override_parameters: '-Jhttpsampler.ignore_failed_embedded_resources=true',
  privacy_flag: 'public'})
