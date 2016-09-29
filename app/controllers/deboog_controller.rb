class DeboogController < ApplicationController

  def index
    search_params = CaptureSocialSearch::Search::ParamMap.as_hash(params)
    @resp         = CaptureSocialSearch::Search::Runner.execute(search_params)
  rescue Exception => e
    e.backtrace.each do |tr|
      Rails.logger.error tr
    end

    raise "#{e.message}, please see logs for details"
  end

end
