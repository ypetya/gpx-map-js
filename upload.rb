require 'rubygems'
require 'sinatra'
require 'uri'
require 'haml'

before do
  content_type "text/html", :charset => "utf-8"
end

get '/' do
  @list = []
  Dir.foreach('public'){|file| @list << file if file =~ /^.*gpx$/}
  haml :index
end

get '/upload' do
  haml :upload
end

post '/upload' do
  unless params[:f] and (tmpfile = params[:f][:tempfile]) and (name = params[:f][:filename])
    return haml(:upload)
  end
  
  tofile = "#{@@root_dir}/public/#{name}"
  File.open(tofile.untaint, 'w') { |file| file << tmpfile.read } 
  "http://#{@@server}/#{@@virtual_dir}/#{URI.encode(name)}"
end

def title(title=nil)
  @title = title.to_s unless title.nil?
  @title
end

__END__
@@ layout
!!!
%html
  %head
    %script{:src=>'jquery.js',:type=>'text/javascript',:charset=>'utf-8'}
    %script{:src=>'http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=false&amp;key=ABQIAAAAGnlgWTmjm1LcrWCYbufd8BS1LvUXpWTdIactUxZOqRxn9_40vBRc78Fkmv_JpBxXga4lFeF0Npm-4w',:type=>'text/javascript'}
    %script{:src=>'parseISO8601.js',:type=>'text/javascript',:charset=>'utf-8'}
    %script{:src=>'gpx.js',:type=>'text/javascript',:charset=>'utf-8'}
    %link{ :rel=>"stylesheet", :href=>"application.css", :type=>"text/css", :media=>"screen", :charset=>"utf-8"}
    %title= title
  %body
    #content= yield
    %a{:href=>'/wiki/GpxProject'}== Wiki 


@@ index
- title 'gpx viewer'
%h1= title
#main
  %ul#options
    - @list.each do |file|
      %li
        %a{:href=>'#'}=file
  #map_canvas
%a{:href=>'/gpx/upload'}== Upload GPX

@@ upload
- title "Upload your gpx file"
%h1= title
%form{:action=>"/#{@@virtual_dir}/upload",:method=>"post",:enctype=>"multipart/form-data"}
  %p
    %input{ :type => :file, :name => 'f' }
  %p
    %input{ :type => :submit, :value => 'go' }
