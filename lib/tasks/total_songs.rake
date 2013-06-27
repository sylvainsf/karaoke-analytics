require 'csv'
namespace :totals do

  desc "Create all_time_song_totals.csv"
  task :all_time => [:environment] do


    butter_totals = {}
    totals = {}

    singers = Hash.from_xml(Nokogiri::XML(File.open("lib/DataMain.xml")).to_xml)["dsMain"]["dtSingers"]
    singers.each do |s|
      begin
        singer_history = Hash.from_xml(Nokogiri::XML(File.open("lib/singer_history/#{s["ID"]}.xml")).to_xml)["dsSingerHistory"]["dtSingerHistory"]
      rescue
      end
      singer_history = [singer_history].flatten
      next if singer_history == [nil]
      singer_history.each do |song|
        if totals["#{song["Artist"]}: #{song["Title"]}"]
          totals["#{song["Artist"]}: #{song["Title"]}"] += song["Count"].to_i
        else
          totals["#{song["Artist"]}: #{song["Title"]}"] = song["Count"].to_i
        end
        if Date.parse(song["DateTimeSang"]).sunday? || (Date.parse(song["DateTimeSang"]).monday? && DateTime.parse(song["DateTimeSang"]).hour < 4)
          if butter_totals["#{song["Artist"]}: #{song["Title"]}"]
            butter_totals["#{song["Artist"]}: #{song["Title"]}"] += song["Count"].to_i
          else
            butter_totals["#{song["Artist"]}: #{song["Title"]}"] = song["Count"].to_i
          end
        end
      end
    end
    CSV.open("all_time_song_totals.tsv", "wb", {:col_sep => "\t"}) {|csv| totals.to_a.each {|line| csv << line} }
    CSV.open("butter_song_totals.tsv", "wb", {:col_sep => "\t"}) {|csv| butter_totals.to_a.each {|line| csv << line} }

  end



end
  
