module Admin::RegionsHelper
  def render_region(region, options={}, &block)
    lazy_initialize_region_set
    default_partials = TrustyCms::AdminUI::RegionPartials.new(self)
    if block_given?
      block.call(default_partials)
      (options[:locals] ||= {}).merge!(:defaults => default_partials)
    end
    output = @region_set[region].compact.map do |partial|
      begin
        render options.merge(:partial => partial)
      rescue ::ActionView::MissingTemplate # couldn't find template
        default_partials[partial]
      rescue ::ActionView::TemplateError => e # error in template
        raise e
      end
    end.join.html_safe
    Rails.logger.error(output)
    block_given? ? concat(output) : output
  end

  def lazy_initialize_region_set
    unless @region_set
      @controller_name ||= @_controller.controller_name
      @template_name ||= @_controller.template_name
      @region_set = admin.send(@controller_name).send(@template_name)
    end
  end
end
