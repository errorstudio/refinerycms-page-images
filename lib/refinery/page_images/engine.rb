require 'refinery/page_images/configuration'

module Refinery
  module PageImages
    class Engine < Rails::Engine
      include Refinery::Engine

      isolate_namespace Refinery

      engine_name :refinery_page_images

      def self.register(tab)
        tab.name = ::I18n.t(:'refinery.plugins.refinery_page_images.tab_name')
        tab.partial = "/refinery/admin/pages/tabs/images"
      end

      def self.initialize_tabs!
        PageImages.config.enabled_tabs.each do |tab_class_name|
          unless (tab_class = tab_class_name.safe_constantize)
            Rails.logger.warn "PageImages is unable to find tab class: #{tab_class_name}"
            next
          end
          tab_class.register { |tab| register tab }
        end
      end

      before_inclusion do
        Refinery::Plugin.register do |plugin|
          plugin.name = 'page_images'
          plugin.pathname = root
          plugin.hide_from_menu = true
        end
      end

      initializer "include_page_images_params" do
        pp_method_builder = Proc.new do

          # Get a reference to the  original method with all previous permissions already applied.
          page_params_method = Refinery::Admin::PagesController.instance_method :page_params

          # Define the new method.
          Refinery::Admin::PagesController.send(:define_method, "page_params_with_page_image_params") do
            pi_params = params.require(:page).permit(images_attributes: [:id, :caption, :image_page_id])
            # If there is no :images_attributes hash use a blank hash (so it removes deleted images)
            pi_params = {images_attributes:{}} if pi_params[:images_attributes].nil?
            page_params_method.bind(self).call().merge(pi_params)
          end
        end

        Refinery::Admin::PagesController.alias_method_chain :page_params, :page_image_params, &pp_method_builder
      end

      config.to_prepare do
        Refinery::PageImages.attach!
      end

      config.after_initialize do
        initialize_tabs!
        Refinery.register_engine Refinery::PageImages
      end
    end
  end
end
