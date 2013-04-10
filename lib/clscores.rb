module CLScores
  class Settings
    attr_reader :team_colors, :base_url

    def initialize(opts = {})
      @config_path = File.expand_path('../../config', __FILE__)
      @team_colors = YAML.load_file(file 'team_colors.yml').inject({}){|new,(t,c)| new[t.to_sym] = %w[black red green yellow blue magenta cyan white default].include?(c) ? c.to_sym : c; new}
      @base_url = "http://scores.espn.go.com/mlb/scoreboard"

      if opts[:today]
        @date = Date.today
      elsif opts[:yesterday]
        @date = Date.yesterday
      elsif opts[:date]
        @date = Date.parse(opts[:date])
      else
        @date = Date.yesterday
      end
    end

    def date(format = "%Y%m%d")
      @date.strftime(format)
    end

    private
      def file(file_name)
        @config_path + '/' + file_name
      end
  end

  class Inning
    def initialize(game, num, opts = {})
      @home_score = game.at_css("td##{opts[:id]}-hls#{num - 1}").text
      @away_score = game.at_css("td##{opts[:id]}-als#{num - 1}").text
    end

    def home
      @home_score
    end

    def away
      @away_score
    end
  end

  class Team
    def initialize(abbr)
      @settings = Settings.new
      @team_colors = @settings.team_colors

      @abbr = abbr
      @color = @team_colors[abbr.downcase.to_sym] || :default
    end

    def to_s
      @abbr.color(@color)
    end
  end

  class Game
    def initialize(game_box)
      game = game_box.css('table.game-details')
      @id = game.at_css('tr:nth-child(1) td:nth-child(2)')[:id].gsub(/-als./, '')
      @teams = {
        away: Team.new(game.at_css('tr:nth-child(1) td:nth-child(1)').text),
        home: Team.new(game.at_css('tr:nth-child(2) td:nth-child(1)').text)
      }
      @score = {
        away: game.at_css("td##{@id}-alsT").text,
        home: game.at_css("td##{@id}-hlsT").text,
      }
      @hits = {
        away: game.at_css("td##{@id}-alsH").text,
        home: game.at_css("td##{@id}-alsH").text,
      }
      @errors = {
        away: game.at_css("td##{@id}-alsE").text,
        home: game.at_css("td##{@id}-alsE").text,
      }
      @box_link = "http://scores.espn.go.com/mlb/boxscore?gameId=#{@id}"
      @status = game_box.at_css('div.game-status').text
      @innings = []
      1.upto(9).each do |i|
        @innings << Inning.new(game, i, id: @id)
      end
    end

    def summary
      puts "\n"
      if @status == "Final"
        print "".pad(4)
        1.upto(9) { |i| print i.to_s.pad(3).color(:cyan) }
        %w[| R H E].each { |h| print h.pad(3).color(:cyan) }
        puts "\n"
        [:away, :home].each do |status|
          print @teams[status].to_s.pad(4)
          @innings.each do |inning|
            print inning.send(status).pad(3)
          end
          puts '|'.pad(3) + @score[status].pad(3) + @hits[status].pad(3) + @errors[status].pad(3)
        end
      else
        puts "#{@teams[:away]} @ #{@teams[:home]}".pad(10) + "| #{@status}"
      end
    end
  end
end