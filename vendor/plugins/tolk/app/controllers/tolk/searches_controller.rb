module Tolk
  class SearchesController < Tolk::ApplicationController
    before_filter :find_locale
  
    def show
      if params[:qkey]
        @phrases = @locale.search_phrases_on_key(params[:qkey], params[:page])
      else
        @phrases = @locale.search_phrases(params[:q], params[:page])
      end
    end

    private

    def find_locale
      @locale = Tolk::Locale.find_by_name!(params[:locale])
    end
  end
end
