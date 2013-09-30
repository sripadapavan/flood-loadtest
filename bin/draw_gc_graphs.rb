#!/usr/bin/env ruby
require 'googlecharts'

def render_chart(log, heap_size_before, heap_size_after, allocated_heap)
  chart = Gchart.new( type: 'line',
                      size: '800x200', 
                      title: log,
                      theme: :pastel,
                      data: [heap_size_before, heap_size_after, allocated_heap], 
                      line_colors: 'e0440e,e62ae5,287eec',
                      legend: ['MB Heap Size Before','MB Heap Size After','MB Allocated Heap'],
                      axis_with_labels: ['y'],
                      filename: "#{Dir.pwd}/benchmarks/results/charts/#{log}.png")

  chart.file
end

def number_to_human(line, pattern)
  unit = line[/([A-Z]+)->/, 1]
  value = line[pattern, 1]
  bytes = case unit
  when /K/
    value.to_f / 1024.0
  when /M/
    value.to_f
  when /G/
    value.to_f * 1024.0
  else
    value.to_f / 1024.0
  end
end


if File.file?("#{Dir.pwd}/benchmarks/results/gc/#{ARGV[0]}.log")

  File.open("#{Dir.pwd}/benchmarks/results/README.md", 'a') do |file| 
    file.puts "![](./charts/#{ARGV[0]}.png?raw=true)"
    file.puts
  end

  gc_count = 0
  full_gc_count = 0
  heap_size_before = []
  heap_size_after = []
  allocated_heap = []
  gc_duration = []
  
  File.open("#{Dir.pwd}/benchmarks/results/gc/#{ARGV[0]}.log").each do |line|
    gc_count += 1
    full_gc_count += 1 if line =~ /Full GC/
    heap_size_before << number_to_human(line, /\[\w+ (\d+)/)
    heap_size_after << number_to_human(line, /->(\d+)/)
    allocated_heap << number_to_human(line, /\((\d+)/)
    gc_duration << line[/(\d+\.\d+) secs/, 1].to_i
  end

  render_chart ARGV[0], heap_size_before, heap_size_after, allocated_heap  

end