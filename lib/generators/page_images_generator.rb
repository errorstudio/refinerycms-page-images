require 'refinery/generators'

module Refinery
  class PageImagesGenerator < ::Refinery::Generators::EngineInstaller

    source_root File.expand_path('../../../', __FILE__)
    engine_name "page_images"

  end
end