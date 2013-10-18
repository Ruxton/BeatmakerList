#!/usr/bin/env ruby
require 'json'
require 'fileutils'
require 'haml'

class Builder

  DATAPATH = "data/"
  DATAFILES = "*.json"
  OUTPUTDIR = "output/"
  REJECTED_KEYS = ["name","home_state","extra_states"]

  def render_file(filename,vars={})
    obj = self
    contents = File.read("templates/#{filename}.html.haml")
    if vars.size > 0
      keys = vars.keys.map{|a| a.to_sym}
      keys = keys[0] if keys.size == 1
      Haml::Engine.new(contents).def_method(obj, :to_html, keys)
    else
      Haml::Engine.new(contents).def_method(obj, :to_html)
    end
    obj.to_html(vars)
  end

  def render(*attrs)
    options = {collection: []}
    output = ""

    if attrs.first.is_a? Hash
      options.merge!(attrs.first)
      if options[:partial]
        partial = options[:partial]
        options[:collection].each do |var|
          vars={}
          vars[partial]=var
          output << render_file("_#{options[:partial]}", vars)
        end
      end
    elsif attrs.first.is_a? String
      options[:template] = attrs.first
    end
    if options[:template]
      output << render_file(options[:template])
    end
    output
  end

  def build_entity(file)
    state = File.dirname(file).split("/").last
    str = File.read(file)
    data = JSON.parse(str)
    data["home_state"] = state
    data
  end

  def states
    if @states.nil?
      @states = {}
      Dir.glob("#{DATAPATH}states/#{DATAFILES}") do |file|
        id = File.basename(file,".json")
        @states[id] = JSON.parse(File.read(file))
      end
      @states
    else
      @states
    end
  end

  def run
    Dir.glob("#{DATAPATH}beatmakers/*").select {|f| File.directory? f}.each do |dir|
      dirname = dir.split("/").last
      FileUtils.mkdir_p(OUTPUTDIR)
      datafilespath = "#{dir}/#{DATAFILES}"
      @data_count = Dir[datafilespath].length
      @data = []
      @page_title = "#{dirname.upcase} Beatmakers"
      Dir.glob(datafilespath).each do |file|
        @data << build_entity(file)
      end

      begin
        output = File.open("#{OUTPUTDIR}#{dirname}-beatmakers.html", "w")
        output << render("index")

      ensure
        output.close
      end
    end
  end
end

Builder.new().run