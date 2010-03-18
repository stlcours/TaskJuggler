#!/usr/bin/env ruby -w
# encoding: UTF-8
#
# = tj3ss_sender.rb -- The TaskJuggler III Project Management Software
#
# Copyright (c) 2006, 2007, 2008, 2009, 2010 by Chris Schlaeger <cs@kde.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#

# This script is used to send out the time sheet templates to the employees.
# It should be run from a cron job once a week.

require 'Tj3AppBase'
require 'StatusSheetSender'

# Name of the application
AppConfig.appName = 'tj3ss_sender'

class TaskJuggler

  class Tj3SsSender < Tj3AppBase

    def initialize
      super
      @optsSummaryWidth = 25
      @force = false

      @hideResource = nil
      # The default report period end is next Wednesday 0:00.
      @date = TjTime.now.nextDayOfWeek(3).to_s('%Y-%m-%d')
      @resourceList = []
    end

    def processArguments(argv)
      super do
        @opts.banner += <<'EOT'
This program can be used to out status sheets templates via email. It will
generate status sheet templates for managers of the project. The project data
will be accesses via tj3client from a running TaskJuggler server process.
EOT
        @opts.on('-r', '--resource <ID>', String,
                 format('Only generate template for given resource')) do |arg|
          @resourceList << arg
        end
        @opts.on('-f', '--force',
                format('Send out a new template even if one exists ' +
                       'already')) do |arg|
          @force = true
        end
        @opts.on('--hideresource <EXPR>', String,
                 format('Filter expression to limit the resource list')) do |arg|
          @hideResource = arg
        end
        optsEndDate
      end
    end

    def main
      super
      ts = StatusSheetSender.new('tj3ss_sender')
      @rc.configure(ts, 'global')
      @rc.configure(ts, 'statussheets')
      @rc.configure(ts, 'statussheets.sender')
      ts.workingDir = @workingDir if @workingDir
      ts.dryRun = @dryRun
      ts.force = @force
      ts.date = @date if @date
      ts.hideResource = @hideResource if @hideResource

      ts.sendTemplates(@resourceList)
    end

  end

end

TaskJuggler::Tj3SsSender.new.main()
