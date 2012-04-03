require 'bundler/setup'

libraries = %w(grape bishl)
libraries.each {|library| require library }

begin
  # Set up load paths for all bundled gems
  #ENV["BUNDLE_GEMFILE"] = File.expand_path("../../Gemfile", __FILE__)
  Bundler.setup
rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems." +
    "Did you run `bundle install`?"
end


module IRVB
  module Helpers

    def hashify(ary)
      ary.map(&:hashify)
    end

  end
end

class IRVB::API < Grape::API

  version 'v1', :using => :path

  format :json
  default_format :json

  helpers IRVB::Helpers

  resource :teams do
    
    # GET /teams/show/:id
    get '/show/:id' do
      logo = BISHL.logo_for(:team => params[:id])
    end

    get '/logo/:id' do
      logo = BISHL.logo_for(:team => params[:id])
      {:logo => logo}
    end

  end

  resource :games do

    # GET /games/team/10/year/2012
    get '/league/:league/team/:team/year/:year' do
      schedule = BISHL.schedule(:season => params[:year], :cs => params[:league], :team => params[:team])
      {:games => hashify(schedule)}
    end

    # GET /games/league/LLA/season/2010
    get '/league/:id/season/:year' do
      schedule = BISHL.schedule(:season => params[:year], :cs => params[:id])
      {:games => hashify(schedule)}
    end

    # GET /games/team/:id/:league_id/next
    get '/team/:id/league/:league_id/next' do
      games = BISHL.next_game_for(:season => Time.now.year, :cs => params[:league_id],  :team => params[:id])
      {:games => hashify(games)}
    end

    # GET /games/team/:id/last
    get '/team/:id/league/:league_id/last' do
      games = BISHL.last_game_for(:season => Time.now.year, :cs => params[:league_id],  :team => params[:id])
      {:games => hashify(games)}
    end
  end

  resource :standings do

    # GET /standings/league/12
    get '/league/:league_id/year/:year' do
      standings = BISHL.standings(:season => params[:year], :cs => params[:league_id])
      {:standings => hashify(standings)}
    end
  end

end