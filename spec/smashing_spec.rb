# frozen_string_literal: true

require_relative "../smashing"

# TODO: fix OptionParser::InvalidOption: invalid option: --require

describe(SmashingMagazineDownloader) do
  describe "#initialize" do
    it "sets month, year, year_and_month, and resolution" do
      options = { month: "062023", resolution: "640x480" }
      downloader = SmashingMagazineDownloader.new(options)

      expect(downloader.instance_variable_get(:@month)).to(eq("06"))
      expect(downloader.instance_variable_get(:@year)).to(eq("2023"))
      expect(downloader.instance_variable_get(:@year_and_month)).to(eq("2023/06"))
      expect(downloader.instance_variable_get(:@resolution)).to(eq("640x480"))
    end
  end

  describe "#fetch_wallpapers" do
    it "returns an array of wallpaper URLs" do
      options = { month: "062023", resolution: "640x480" }
      downloader = SmashingMagazineDownloader.new(options)
      allow(downloader).to(receive(:months_map).and_return({ "06": "June" }))

      expect(downloader.fetch_wallpapers).to(all(match(%r{https://www\.smashingmagazine\.com/})))
    end
  end
end
