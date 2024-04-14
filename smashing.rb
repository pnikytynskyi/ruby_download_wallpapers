# frozen_string_literal: true

require "optparse"
require "open-uri"
require "nokogiri"

class SmashingMagazineDownloader
  def initialize(options)
    @month = options[:month].slice!(0, 2)
    @year = options[:month]
    @year_and_month = "#{@year}/#{@month}"
    @resolution = options[:resolution]
  end

  def run
    wallpapers = fetch_wallpapers
    download_wallpapers(wallpapers)
  end

  private

  def months_map
    {
      "00": "January",
      "01": "February",
      "02": "March",
      "03": "April",
      "04": "May",
      "05": "June",
      "06": "July",
      "07": "August",
      "08": "September",
      "09": "October",
      "10": "November",
      "11": "December",
    }
  end

  def fetch_wallpapers
    url = "https://www.smashingmagazine.com/#{@year_and_month}/desktop-wallpaper-calendars-#{months_map[@month.to_sym]}-#{@year}/"
    uri = URI.parse(url)
    raise ArgumentError, "Invalid URL" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    doc = Nokogiri::HTML(URI.open(uri))
    resolutions = @resolution.split("x")
    wallpapers = doc.css("ul li>a[href*='#{resolutions[0]}x#{resolutions[1]}']").map { |link| link["href"] }
    wallpapers.map { |wallpaper| URI.join(uri, wallpaper).to_s }
  end

  def download_wallpapers(wallpapers)
    wallpapers.each do |wallpaper|
      filename = File.basename(wallpaper)
      URI.open(wallpaper) do |file|
        File.open(filename, "wb") do |output_file|
          output_file.write(file.read)
        end
      end
      puts "Downloaded: #{filename}"
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: smashing.rb [options]"

  opts.on("--month MONTH", "Specify month and year (e.g. 062023)") do |month|
    options[:month] = month
  end

  opts.on("--resolution RESOLUTION", "Specify resolution (e.g. 640x480)") do |resolution|
    options[:resolution] = resolution
  end
end.parse!

if options[:month].nil? || options[:resolution].nil?
  puts "Please specify both month and resolution"
  exit 1
end

downloader = SmashingMagazineDownloader.new(options)
downloader.run
