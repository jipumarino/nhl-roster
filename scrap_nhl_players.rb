require "nokogiri"
require "open-uri"
require "json"

def get_logo_and_players_for_roster_url(url)
  players = []

  doc = Nokogiri::HTML(open(url))

  logo_url = doc.at(".megamenu-club-logobar__logo img")["src"]

  tables = doc.css("table.data-table")

  (0..2).each do |i|
    names = tables[i*2].css("tr")[1..-1]
    datas = tables[i*2+1].css("tr")[1..-1]

    position_override = if i == 1
      "D"
    else
      "G"
    end

    players += names.zip(datas).map do |name, data|
      height_match = data.at(".height-col span").content.match(/^(\d+)'(\d+)\"$/)
      {
        first_name: name.at(".name-col__firstName").content,
        last_name: name.at(".name-col__lastName").content,
        photo_url: name.at(".player-photo")["src"],

        number: data.at(".number-col").content.to_i,
        position: data.at(".position-col").content || position_override,
        shoots: data.at(".shoots-col").content,
        height_feet: height_match[1].to_i,
        height_inches: height_match[2].to_i,
        weight: data.at(".weight-col").content,
        birthdate: Date.strptime(data.at(".birthdate-col span"), "%m/%d/%y"),
        hometown: data.at(".hometown-col").content
      }
    end

  end

  return [logo_url, players]
end


def get_teams
  doc = Nokogiri::HTML(open("https://www.nhl.com/info/teams"))
  teams_data = doc.css(".ticket-team")

  teams_data.map do |data|
    {
      city: data.at(".team-city span.team-city").content,
      name: data.at(".team-city span.team-name").content,
      roster_url: "https://www.nhl.com" + data.css(".ticket-link_link")[1]["href"]
    }
  end
end

def get_all_data
  teams = get_teams
  data = teams.each do |team|
    puts "Scrapping #{team[:city]} #{team[:name]}"
    team[:logo_url], team[:players] = get_logo_and_players_for_roster_url(team[:roster_url])
  end
  teams
end


