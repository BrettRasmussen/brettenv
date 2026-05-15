#!/usr/bin/env ruby

# dkr: Like the name, it's "docker for short". In other words, it's a shortcut utility to quickly
# run some of the most common docker commands used while building docker images, but hopefully with
# as little to type on the command line as possible.
#
# By default, it builds and runs a docker image, but with some "extras" for convenience.
# Specifically, runs the docker commands "build", "container prune", "image prune", "images", and
# "run" in that sequence. The build command is timed so you can see how long it took each time. The
# pruning makes it so that a bunch of used-only-once containers and images aren't piling up while
# building and running the same image many times in a row to develop a Dockerfile. Listing the
# images allows you to see the size of the image you're developing. The image listing is limited to
# the first 10 lines of the "docker images" output.
#
# Also by default, this script will build the file called simply "Dockerfile" in the current
# directory and tag and run it as "current", and it will be run in interactive mode with the
# entrypoint "sh". This script accepts command-line options or environment variables to override the
# defaults. The environment-variable approach allows you to just export them once and then keep
# running "dkr" bare over and over to keep working on the same image. If both are found,
# command-line options override environment variables.

require "optparse"
require "shellwords"

class Dkr
  KEYVAL_REGEX = /^[\w\-:."'\/]+=[\w\-:."'\/]+$/

  def initialize(argv)
    # Set up timing for both the initialization phase and the whole script execution.
    @start_time = Time.now
    # A list of all possible stages (maybe unused later and just for reference).
    @all_stages = [:build, :run, :prune, :list, :push, :release]
    # Stages requiring a Dockerfile and/or tag, therefore needing options set from a shorcut, etc.
    @smart_stages = [:build, :run, :push, :release]
    # A counter to keep track of which round of option parsing is current or most recent.
    @optparse_round = 0

    # Figure out what type of run of the script the current one will be, and set up all of the
    # commands, options, and arguments that will be passed to external programs.
    set_defaults
    parse_options(argv.dup)
    show_env if @options[:show_env]
    show_section("init")
    if @options[:stages].any? {|stg| @smart_stages.include?(stg)}
      load_shortcut_file
      parse_options(argv)
    else
      puts "No shortcut or Dockerfile needed for the given stages."
    end
    finalize_docker_args
    define_commands

    # Show duration of init phase.
    time("init", Time.now - @start_time)
  end

  # Set defaults for the options this script uses. Throughout the script, we prioritize option
  # setting in this order: command-line options, command-line shortcut-mode values, values from a
  # shortcut file, defaults from set_defaults.
  def set_defaults
    @options = {
      shortcut: nil,
      shortcut_origin: nil,
      dockerfile: "Dockerfile",
      tag: "current",
      entrypoint: "sh",
      stages: [:build, :prune, :list, :run],
      build_args: [],
      run_args: [],
      direct_run_args: [],
      run_mode: :direct,
      heroku_mode: false,
      heroku_procs: [],
      show_env: false,
      dry_run: false,
    }
    set_shortcut(ENV["DKR_SHORTCUT"], :env) if ENV["DKR_SHORTCUT"].is_a?(String)
  end

  # Fill out the @options hash based on what the user has specified on the command line or in the
  # shortcut file. argv is an array of arguments as passed to the script on the command line and
  # parsed into an array the way Ruby does for us with ARGV (but doesn't have to be only ARGV thanks
  # to Shellwords).
  #
  # Throughout the run of the script, this method will be run once to get "initial" options and
  # possibly a second and a third time depending on what comes out of the initial options. If run,
  # the second round is to set options from a shortcut or shortcut file, and the third round
  # is to override previously set options with whatever is provided on the command line.
  #
  # We keep track of which round we're on using @optparse_round, and when necessary we give
  # that round treatment specific to its purposes.
  def parse_options(argv)
    @optparse_round += 1
    current_stages = []

    OptionParser.new do |opts|
      opts.banner = <<~EOS
        dkr ("docker for short"): quick access to the most common commands used while
        developing a Dockerfile. Default sequence of stages: build image, prune
        containers, prune images, list recent images, run the new image. Option setting
        prioritized: CLI arguments, shortcut file, CLI shortcut mode, defaults.

        If SHORTCUT provided (either on the CLI or via env var DKR_SHORTCUT), first looks
        for a shortcut file, which can contain any options accepted by the script (needs
        flags), on one or multiple lines. If shortcut file not found, sets CLI shortcut
        mode, invoking commands as such:
          $ docker build -f Dockerfile.SHORTCUT -t SHORTCUT; ...; docker run SHORTCUT

        Usage: dkr [options] [SHORTCUT]

        Options:
      EOS

      opts.on("-f", "--dockerfile FILE",
              %{Dockerfile to build. Default: "Dockerfile".}) do |val|
        @options[:dockerfile] = val
      end

      opts.on("-t", "--tag TAG", %{Tag to assign to image. Default: "current".}) do |val|
        @options[:tag] = val
      end

      opts.on("-e", "--entrypoint ENTRYPOINT", %{Interactive run entrypoint. Default: "sh".}) do |val|
        @options[:entrypoint] = val
      end

      opts.on("-b", "--build", %{Only build, or with -brpl choices (ordered).}) do
        current_stages << :build
      end

      opts.on("-p", "--prune", %{Only prune, or with -brpl choices (ordered).}) do
        current_stages << :prune
      end

      opts.on("-l", "--list", %{Only list images, or with -brpl choices (ordered).}) do
        current_stages << :list
      end

      opts.on("-r", "--run", %{Only run, or with -brpl choices (ordered).}) do
        current_stages << :run
      end

      opts.on("-B", "--build-arg ARG_STRING",
              %{Command-line argument to be passed to "docker build". If},
              %{formatted "key=val", will be prepended with "--build-arg".},
              %{Otherwise, full string will be passed as is. Examples:},
              %{  -B NODE_VERSION=20},
              %{  -B "--pull"},
              %{  -B "--secret 'id=mysecret'"}) do |val|
        val.prepend("--build-arg ") if val.match(KEYVAL_REGEX)
        @options[:build_args] << val
      end

      opts.on("-R", "--run-arg ARG_STRING",
              %{Command-line argument to be passed to "docker run". If},
              %{formatted "key=val", will be prepended with "--env".},
              %{Otherwise, full string will be passed as is. Examples:},
              %{  -R RAILS_ENV=staging},
              %{  -R "--detach"},
              %{  -R "--add-host 'batman:10.0.0.2'"}) do |val|
        val.prepend("--env ") if val.match(KEYVAL_REGEX)
        @options[:run_args] << val
      end

      opts.on("-i", "--interactive-run",
              %{Launch an interactive shell in the container instead of},
              %{running it directly.}) do
        @options[:run_mode] = :interactive
      end

      opts.on("-d", "--direct-run",
              %{Run the image directly. This is the default, but the flag},
              %{can override a --interactive-run set previously.}) do
        @options[:run_mode] = :direct
      end

      opts.on("-C", "--cmd-arg ARG_STRING",
              %{When directly running the image, pass ARG_STRING as a},
              %{trailing argument, so it will be handed off to the},
              %{image's CMD or ENTRYPOINT executable. ARG_STRING can},
              %{contain everything, or pass multiple -C's. Examples},
              %{with an image with CMD or ENTRYPOINT "ls":},
              %{  dkr -C "-l --color=auto /usr/local" ls_img},
              %{  dkr -C "-l" -C "--color=auto" -D "/usr/local" ls_img}) do |val|
        @options[:direct_run_args] << val
      end

      opts.on("-j", "--push-heroku",
              %{Do a "heroku container:push", using the tag as the heroku app},
              %{name. Alone it runs exclusively, and logically would be},
              %{instead of the -brpl stuff, but can go with them if you want.}) do
        current_stages << :push
      end

      opts.on("-k", "--release-heroku",
              %{Do a "heroku container:release", working the same as -j.}) do
        current_stages << :release
      end

      opts.on("-K", "--proc-type-heroku PROC_STR",
              %{Heroku process type(s) (web, worker, release, etc.) on},
              %{which to run any "heroku container" commands.},
              %{Comma-separated list or one per -K given.}) do |val|
        val.split(",").each {|proc| @options[:heroku_procs] << proc}
      end

      opts.on("-E", "--env",
              %{Show environment variables used by the script, and},
              %{their current values}) do
        @options[:show_env] = true
      end

      opts.on("-n", "--dry-run", %{Just list the commands that would run but don't run them.}) do
        @options[:dry_run] = true
      end
    end.parse!(argv)

    # Keep the necessary pieces in case the first round becomes the only one.
    set_initial_opts(argv) if @optparse_round == 1

    # Overwrite the whole previous set of stages if the current set is populated.
    @options[:stages] = current_stages if current_stages.size > 0
  end

  # Set the options that figure into whether or not we'll proceed with everything else as normal,
  # and reset the rest to defaults for the subsequent parse_options rounds.
  def set_initial_opts(argv)
    keepers = [:show_env, :dry_run]
    initial_opts = @options.select {|key, _| keepers.include?(key)}
    set_defaults
    @options.merge!(initial_opts)
    set_shortcut(argv.shift, :cli) if argv.count > 0
  end

  # Sets @options[:shortcut] to the provided value, and also sets :dockerfile and :tag
  # based on the shortcut. This must not be called on the final parse_options run because
  # that needs to override any shortcut-defined stuff with the command-line stuff.
  def set_shortcut(shortcut, origin)
    @options[:shortcut] = shortcut
    @options[:shortcut_origin] = origin
    @options[:dockerfile] = "Dockerfile.#{shortcut}"
    @options[:tag] = shortcut
  end

  # Show all the environment variables used by the script and their current values, then exit.
  def show_env
    msg = <<~EOS
      DKR_SHORTCUT=#{ENV["DKR_SHORTCUT"]}
    EOS
    puts msg
    exit
  end

  # Looks for a file from which to load options and triggers a second option parsing if found.
  def load_shortcut_file
    return if !@options[:shortcut]

    msg = {
      cli: %{Shortcut "#{@options[:shortcut]}" received from the command line.},
      env: %{Shortcut "#{@options[:shortcut]}" found in environment variable DKR_SHORTCUT.},
    }[@options[:shortcut_origin]]
    puts msg

    shortcut_file = "#{Dir.pwd}/dkr.#{@options[:shortcut]}"
    if !File.exist?(shortcut_file)
      puts "No shortcut file found; falling back on CLI shortcut mode."
      return false
    end

    puts %{Shortcut file "#{File.basename(shortcut_file)}" found. Loading options.}
    args = File.readlines(shortcut_file).map do |line|
      line = line.strip.chomp
      next if line.start_with?("#")
      line
    end
    argv = Shellwords.shellwords(args.join(" "))
    parse_options(argv)
  end

  def exit_with_message(msg)
    puts msg
    exit(1)
  end

  # Finalize the arguments we'll pass to docker, adjusting formats of the data as needed and
  # overriding defaults based on command-line user input.
  def finalize_docker_args
    @build_args = @options[:build_args].count > 0 ? @options[:build_args].join(" ") : ""
    @run_args = @options[:run_args].count > 0 ? @options[:run_args].join(" ") : ""
    @direct_run_args = @options[:direct_run_args].count > 0 ? @options[:direct_run_args].join(" ") : ""

    if @options[:run_mode] == :interactive
      @all_run_args = "-it --entrypoint #{@options[:entrypoint]} #{@run_args} #{@options[:tag]}"
    else
      @all_run_args = "#{@run_args} #{@options[:tag]} #{@direct_run_args}"
    end

    @hk_args = {
      procs: @options[:heroku_procs].join(" "),
      build: "-R --arg heroku_app=#{@options[:shortcut]}",
      app: "-a #{@options[:shortcut]}",
    }
  end

  # Set up a list of all possible commands, from which will later be selected just the ones to run.
  def define_commands
    # @commands key: name of a stage. @commands value: a single command string or an array of them.
    @commands = {
      build: "docker build -f #{@options[:dockerfile]} #{@build_args} -t #{@options[:tag]} .".squeeze(" "),
      prune: ["docker container prune -f", "docker image prune -f"],
      list: "docker images | head",
      run: "docker run #{@all_run_args}".squeeze(" "),
      push: "heroku container:push #{@hk_args[:procs]} #{@hk_args[:build]} #{@hk_args[:app]}",
      release: "heroku container:release #{@hk_args[:procs]} #{@hk_args[:app]}",
    }
  end

  # Do the main work of this script. It'll call out to other methods to select whatever commands
  # should really be used, and then either print them or run them depending on whether we're in a
  # dry run or not.
  def run
    pick_commands
    if @options[:dry_run]
      show_commands("The following commands would be run:")
    else
      run_commands
    end

    # Show overall duration in its own section
    show_section
    time("", Time.now - @start_time)
  end

  # Selects from the available commands those that will actually be run (or simulated) based on the
  # conditions established by the user. These will be in the correct final order.
  def pick_commands
    @do_commands = []
    @options[:stages].each do |stage|
      cmds = [@commands[stage]].flatten
      cmds.each.with_index do |cmd, idx|
        title = "#{stage}"
        title += ".#{idx + 1}" if cmds.size > 0
        @do_commands << {title: title, text: cmd}
      end
    end
  end

  # Runs all the commands that should be run given the conditions in which the script was run.
  def run_commands
    @do_commands.each.with_index do |command, idx|
      time(command[:title]) do
        show_section(command[:text])
        system(command[:text])
      end
      if $?.exitstatus != 0
        puts "\e[31mDKR: COMMAND FAILED!\e[0m"
        show_commands("The following remains to be done:", idx)
        break
      end
    end
  end

  # Takes a title for some arbitrary code event and a block encapsulating that event, runs and times
  # the block, and prints out a human-readable string of how long the block took to execute.
  # Alternatively takes the title and a number of seconds determined previously, in which case it
  # bypasses the whole block thing and prints with the given duration.
  def time(title = nil, seconds = nil)
    if !seconds
      start_time = Time.now
      yield
      seconds = Time.now - start_time
    end

    time_segs = [
      {unit: "d", val: (seconds / 86400).floor},
      {unit: "h", val: (seconds / 3600).floor},
      {unit: "m", val: (seconds / 60 % 60).floor},
      {unit: "s", val: (seconds % 60).round(3)},
    ].inject([]) do |res, seg|
      if res.size > 0 || seg[:val] > 0 || seg[:unit] == "s"
        res <<  "#{seg[:val]}#{seg[:unit]}"
      end
      res
    end

    msg = "dkr: #{title} completed in #{time_segs.join(' ')}".squeeze(" ")
    puts msg
  end

  # Shows a section of output delimited with a horizontal line.
  def show_section(message = nil, prefix = "executing: ")
    puts "-" * 80
    if message
      msg = message.dup
      msg.prepend(prefix) if prefix
      puts msg
    end
  end

  # Prints all the commands that would be run if nothing prevented them.
  def show_commands(message = nil, idx = 0)
    show_section
    if @do_commands.empty?
      puts "Nothing to do."
    else
      puts message if message
      @do_commands[idx..-1].each {|command| puts "  #{command[:text]}"}
    end
  end
end

Dkr.new(ARGV).run
