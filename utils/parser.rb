require 'httparty'
require 'nokogiri'

if ARGV.size < 2
  puts "usage: ruby parser.rb [path] [output file]"
  exit
end

path = ARGV[0]
file = ARGV[1]

versions = {}


print "Parsing URL..."
page = HTTParty.get(path.match(/http/) ? path : "http://www.useragentstring.com/#{path}")
parser = Nokogiri::HTML(page.body)

parser.css('h4').each do |h4|
  version = h4.text.split.last.to_s
  versions[version] = []
  
  h4.next.css('li').each do |li|
    versions[version].push li.text
  end
end
print " done\n"



print "Writing File... "
File.open(file, 'w+') { |file|
  file.puts YAML.dump(:verions => versions)
}
print " done\n"