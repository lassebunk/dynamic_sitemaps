class DynamicSitemapsController < ApplicationController
  def sitemap
    sitemap = ::Sitemap.where(path: request.path[1..-1]).first

    if sitemap
      render text: sitemap.content
    else
      not_found
    end
  end

  protected
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
