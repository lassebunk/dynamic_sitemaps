class DynamicSitemapsController < ApplicationController
  def sitemap
    sitemap = ::Sitemap.where(path: request.path).first

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
