#!/usr/bin/env ruby
require 'json'
require 'fileutils'

datapath = "data/beatmakers/"
datafiles = "*.json"
outputdir = "output/"

Dir.glob("#{datapath}*").select {|f| File.directory? f}.each do |dir|
  dirname = dir.split("/").last
  FileUtils.mkdir_p(outputdir)
  begin
    output = File.open("#{outputdir}#{dirname}-beatmakers.html", "w")
    datafilespath = "#{dir}/#{datafiles}"
    datafilescount = Dir[datafilespath].length
    output << "<em>#{datafilescount} Beatmakers in list</em>"
    Dir.glob(datafilespath).each do |file|
      puts "Parsing #{file}"
      str = File.read(file)
      d = JSON.parse(str)
      output << "<h2>"
      output << d["name"]
      output << "</h2>"
      output << "<ul>"
      d.delete_if{ |k,v| k == "name" }
      d.each { |k,v| output << "<li><a href=\"#{v}\">#{k}</a></li>" }
      output << "</ul>"
    end
  ensure
    output.close
  end
end