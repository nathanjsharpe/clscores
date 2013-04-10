require 'time'

module CLScores
  class Settings
    attr_reader :team_colors, :base_url, :only

    def initialize(opts = {})
      @opts = opts
      @config_path = File.expand_path('../../config', __FILE__)
      @team_colors = (YAML.load_file(file 'team_colors.yml') || {}).inject({}){|new,(t,c)| new[t.to_sym] = %w[black red green yellow blue magenta cyan white default].include?(c) ? c.to_sym : c; new}
      opts[:highlight].split(' ').each { |team| @team_colors[team.to_sym] = :yellow } unless opts[:highlight].nil?
      @only = opts[:only][/\s/] ? opts[:only].upcase.split(" ") : [opts[:only].upcase] unless opts[:only].nil?

      @base_url = "http://scores.espn.go.com/mlb/scoreboard"

      if opts[:today]
        @date = Date.today
      elsif opts[:yesterday]
        @date = Date.yesterday
      elsif opts[:date]
        @date = Date.parse(opts[:date])
      else
        @date = Date.today
      end
    end

    def date(format = "%Y%m%d")
      @date.strftime(format)
    end

    def method_missing(m, *args, &block)
      if @opts.has_key? m.to_sym
        @opts[m.to_sym]
      else
        super
      end
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
    attr_reader :abbr

    def initialize(abbr, settings)
      @settings = settings
      @team_colors = @settings.team_colors

      @abbr = abbr
      @color = @team_colors[abbr.downcase.to_sym] || :default
    end

    def to_s
      @abbr.color(@color)
    end
  end

  class Game
    attr_reader :status

    def initialize(game_box, settings)
      @settings = settings
      game = game_box.css('table.game-details')
      @id = game.at_css('tr:nth-child(1) td:nth-child(2)')[:id].gsub(/-als./, '')
      @teams = {
        away: Team.new(game.at_css('tr:nth-child(1) td:nth-child(1)').text, settings),
        home: Team.new(game.at_css('tr:nth-child(2) td:nth-child(1)').text, settings)
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
      game_status = game_box.at_css('div.game-status').text
      @status = case game_status
      when /Final/
        :final
      when /ET/
        @game_time = game_status
        :future
      when /Delayed/
        :delayed
      when /Postponed/
        :postponed
      else
        @inning = game_status
        @outs = "0 Outs"
        @outs = "1 Out" if game_box.at_css("##{@id}-out-1")["src"][/circle_on/]
        @outs = "2 Outs" if game_box.at_css("##{@id}-out-2")["src"][/circle_on/]
        @runners = game_box.css('span.baseball-diamond-img').first["class"][/\d+/].scan(/1/).size
        :in_progress
      end
      @innings = []
      1.upto(9).each do |i|
        @innings << Inning.new(game, i, id: @id)
      end
    end

    def time
      Time.parse(@game_time || "0:00")
    end

    def teams
      @teams.map { |k, team| team.abbr }
    end

    def summary
      puts "\n"
      if @status == :future || @status == :delayed || @status == :postponed
        puts "#{@teams[:away]} @ #{@teams[:home]}".pad(10) + "| #{@game_time || @status.to_s.capitalize}"
      elsif @settings.short
        [:away, :home].each do |status|
          print @teams[status].pad(4) + @score[status].pad(3)
          if status == :away
            puts @inning || "F"
          elsif @status == :in_progress and (@inning[/Top/] || @inning[/Bot/])
            puts @outs # , #{@runners} On"
          else
            puts "\n"
          end
        end
      else
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
      end
    end
  end
end