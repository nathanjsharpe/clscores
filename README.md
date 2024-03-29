CLScores
========
A small Ruby project to fetch MLB scores from the Unix command line by scraping the ESPN MLB scoreboard.

Options
-------
<table>
  <tr>
    <td style="width:130px">
      -t,<br>
      --today
    </td>
    <td>Get scores for today's games (default).</td>
  </tr>
  <tr>
    <td>
      -y,<br>
      --yesterday
    </td>
    <td>Get scores for yesterday's games.</td>
  </tr>
  <tr>
    <td>
      -d,<br>
      --date=DATE
    </td>
    <td>Get scores/schedule for a specific date.</td>
  </tr>
  <tr>
    <td>
      -s,<br>
      --short
    </td>
    <td>Display short version of scores (only score, inning, outs).</td>
  </tr>
  <tr>
    <td>
      -h,<br>
      --highlight=TEAMS
    </td>
    <td>Highlight specified team(s). Accepts a single team, e.g. -h stl, or multiple teams, e.g. -h "stl cin".</td>
  </tr>
  <tr>
    <td>
      -o,<br>
      --only=TEAMS
    </td>
    <td>Show only scores involving specified team(s). Accepts a single team, e.g. -o stl, or multiple teams, e.g. -o "stl cin".</td>
  </tr>
  <tr>
    <td>
      -r,<br>
      --sort
    </td>
    <td>Sort games that haven't start yet by start time rather than order of appearance on the ESPN scoreboard.</td>
  </tr>
  <tr>
    <td>
      -e,<br>
      --help
    </td>
    <td>Show command line options.</td>
  </tr>
</table>

Other Configuration
-------------------
Edit config/team_colors.yml to specify colors for teams. Colors can be specified by name in some cases or by hex code. The --highlight option will override any colors specified here with yellow.

Dependencies
------------
Requires Ruby 1.9+ and the following gems:

* [Nokogiri](http://nokogiri.org/)
* [Rainbow](https://github.com/sickill/rainbow)
* [Trollop](http://trollop.rubyforge.org/)