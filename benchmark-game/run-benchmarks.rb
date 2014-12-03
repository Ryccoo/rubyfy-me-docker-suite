require 'open3'

def rvm_versions
  `rvm list`.split(/\n/).reject {|version| version =~ /^rvm rubies/ || version =~ /^\s*$/}.collect {|version| version.match(/\s*([^\s]*)/)[1].strip }
end

def run_benchmarks
  puts "Running Benchmarks"
  7.times do
    benchmarks.each do |benchmark|
      next unless benchmark_needs_run?(benchmark)
      puts "time -p ruby #{benchmark} #{benchmark_args(benchmark)}"
      stdout_str, stderr_str, status = Open3.capture3("time -p ruby #{benchmark} #{benchmark_args(benchmark)}")
      puts stderr_str if status.exitstatus > 0
      write_result(benchmark, stderr_str) if status.exitstatus == 0
    end
  end
end

def benchmark_args(benchmark)
  basename = benchmark.gsub(/\.rb/, '')
  if File.exists?("#{basename}.arg")
    File.open("#{basename}.arg", 'r') {|f| f.read }.strip
  elsif File.exists?("#{basename}.input")
    "< #{basename}.input"
  end
end

def benchmark_needs_run?(benchmark)
  `cat results.csv | grep #{benchmark} | wc -l`.to_i < 7
end

def write_result(benchmark, stats)
  time = stats.split(/\n/)[0].gsub(/real\s*/, '')
  File.open('./results.csv', 'a') do |f|
    f.puts "#{ARGV[0]},#{benchmark},#{time},#{Time.now.to_s}"
  end
end

def benchmarks
  `ls benchmarks/*.rb`.split(/\n/).collect {|benchmark| benchmark.strip }
end

run_benchmarks()